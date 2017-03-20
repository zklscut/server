%% @author zhangkl
%% @doc fight_srv.
%% 2016

-module(fight_srv).
-behaviour(gen_fsm).
-export([init/1, 
        state_name/3, 
        handle_event/3, 
        handle_sync_event/4, 
        handle_info/3, 
        terminate/3, 
        code_change/4]).

-export([
         state_select_card/2,
         state_daozei/2,
         state_qiubite/2,
         state_hunxueer/2,
         state_shouwei/2,
         state_langren/2,
         state_nvwu/2,
         state_yuyanjia/2,
         state_part_jingzhang/2,
         state_part_fayan/2,
         state_xuanju_jingzhang/2,
         state_night_result/2,
         state_someone_die/2,
         state_night_death_fayan/2,
         state_jingzhang/2,
         state_fayan/2,
         state_guipiao/2,
         state_toupiao/2,
         state_toupiao_death_fayan/2,
         state_day/2,
         state_night/2,
         state_fight_over/2,
         state_over/2,
         state_lapiao_fayan/2,
         state_toupiao_mvp/2,
         state_toupiao_carry/2,
         state_game_over/2]).

-include("fight.hrl").
-include("errcode.hrl").
-include("game_pb.hrl").
-include("function.hrl").
-include("resource.hrl").
-define(TEST, false).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/4,
         player_op/4,
         player_skill/4,
         player_speak/3,
         print_state/1,
         player_online/1,
         player_offline/1,
         player_leave/2
         ]).

start_link(RoomId, PlayerList, DutyList, Name) ->
    gen_fsm:start(?MODULE, [RoomId, PlayerList, DutyList, Name, ?MFIGHT], []).

player_op(Pid, PlayerId, Op, OpList) ->
    case Pid of
        undefined->
            ignore;
        _->
            gen_fsm:send_event(Pid, {player_op, PlayerId, Op, OpList})
    end.

player_speak(Pid, PlayerId, Chat) ->
    case Pid of
        undefined->
            ignore;
        _->
            gen_fsm:send_event(Pid, {player_op, PlayerId, ?OP_FAYAN, [Chat]})
    end.

player_skill(Pid, PlayerId, Op, OpList) ->
    case Pid of
        undefined->
            ignore;
        _->
            gen_fsm:send_all_state_event(Pid, {skill, PlayerId, Op, OpList})
    end.

print_state(Pid) ->
    gen_fsm:send_all_state_event(Pid, print_state).

player_online(Player) ->
    case lib_player:get_fight_pid(Player) of
        undefined ->
            ignore;
        Pid ->
            gen_fsm:send_all_state_event(Pid, {player_online, lib_player:get_player_id(Player)})
    end.    

player_offline(Player) ->
    case lib_player:get_fight_pid(Player) of
        undefined ->
            ignore;
        Pid ->
            gen_fsm:send_all_state_event(Pid, {player_offline, lib_player:get_player_id(Player)})
    end.

player_leave(Pid, PlayerId) ->
    case Pid of
        undefined ->
            lager:info("player_leave undefined"),
            net_send:send(#m__room__leave_room__s2l{result=1}, PlayerId),
            room_srv:leave_room(lib_player:get_player(PlayerId));
        Pid ->
            lager:info("player_leave defined"),
            gen_fsm:send_all_state_event(Pid, {player_leave, PlayerId})
    end.

%% ================`===================================================
%% Behavioural functions
%% ====================================================================

init([RoomId, PlayerList, DutyList, Name, State]) ->
    [global_op_srv:player_op(PlayerId, {lib_player, update_fight_pid, [self()]}) || PlayerId <- PlayerList],
    lib_room:update_fight_pid(RoomId, self()),
    lib_room:update_room_status(RoomId, 1, 0, 1, 0),
    NewState = lib_fight:init(RoomId, PlayerList, DutyList, Name, State),
    % NewStateAfterTest = ?IF(?TEST, fight_test_no_send(init, State), NewState),
    % notice_duty(NewState),
    notice_game_status_change(start, NewState),
    send_event_inner(start, b_fight_state_wait:get(start)),
    {ok, state_select_card, NewState}.

state_select_card(start, State)->
    notice_game_status_change(state_select_card, [?OP_SELECT_DUTY], State),
    send_event_inner(wait_op),
    {next_state, state_select_card, State};

state_select_card(wait_op, State)->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, lib_fight:get_op_wait(?OP_SELECT_DUTY, undefined, State)),
    SeatList = lib_fight:get_all_seat(State),
    DutySelectFun = fun(CurSeatId, CurState)->   
                        case CurSeatId =/= 0 of
                            true->
                                lib_fight:notice_rnd_select_duty(CurSeatId, CurState);
                            _->
                                CurState
                        end
                    end,
    StateNew = lists:foldl(DutySelectFun, State, SeatList),
    {next_state, state_select_card, StateNew};

state_select_card({player_op, PlayerId, ?OP_SELECT_DUTY, [Duty]}, State)->
    %%首先判断是否已经操作过
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    DutySelectSeatList = maps:get(duty_select_seat_list, State),
    NewState = 
    case lists:member(SeatId, DutySelectSeatList) of
        true->
            %%提示已经操作过
            lib_fight:send_to_seat(#m__fight__select_duty__s2l{result = 1}, SeatId, State),
            State;
        _-> 
            DiamondNum = mod_resource:get_num(?RESOURCE_DIAMOND, PlayerId),
            case DiamondNum < ?SELECT_DUTY_CAST of
                true->
                    %%提示金币不够
                    lib_fight:send_to_seat(#m__fight__select_duty__s2l{result = 2}, SeatId, State),
                    State;
                _->
                    lib_fight:do_rnd_select_duty_op(SeatId, Duty, State)
            end
    end,
    SeatList = lib_fight:get_all_seat(NewState),
    DutySelectSeatList1 = maps:get(duty_select_seat_list, NewState),
    case length(SeatList) == length(DutySelectSeatList1) of
        true->
            cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
            send_event_inner(op_over);
        _->
            ignore
    end,
    {next_state, state_select_card, NewState};

state_select_card(timeout, State)->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_select_card, State};

state_select_card(op_over, State)->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(start),
    notice_duty(State),
    {next_state, state_daozei, State}.

%% ====================================================================
%% state_daozei
%% ====================================================================
state_daozei(start, State) ->
    do_duty_state_start(?DUTY_DAOZEI, state_daozei, State);

state_daozei(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_DAOZEI, State),
    {next_state, state_daozei, NewState};

state_daozei({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_daozei, State);

state_daozei(timeout, State) ->
    DaozeiList = maps:get(daozei, State),
    Op = 
        case lists:member(?DUTY_LANGREN, DaozeiList) of
            true ->
                ?DUTY_LANGREN;
            false ->
                util:rand_in_list(DaozeiList)
        end,
    do_duty_op_timeout([Op], state_daozei, State);

state_daozei(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_daozei_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_daozei), NewState}.
            
%% ====================================================================
%% state_qiubite
%% ====================================================================
state_qiubite(start, State) ->
    do_duty_state_start(?DUTY_QIUBITE, state_qiubite, State);

state_qiubite(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_QIUBITE, State),
    {next_state, state_qiubite, NewState};

state_qiubite({player_op, PlayerId, Op, [LoverA,LoverB]}, State) ->
    do_receive_player_op(PlayerId, Op, [LoverA,LoverB], state_qiubite, State);

state_qiubite({player_op, _PlayerId, _Op, _OpList}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(timeout),
    {next_state, state_qiubite, State};

state_qiubite(timeout, State) ->
    RandLover = util:rand_in_list(lib_fight:get_alive_seat_list(State) -- 
                                  lib_fight:get_duty_seat(?DUTY_QIUBITE, State), 2),
    do_duty_op_timeout(RandLover, state_qiubite, State);    
    
state_qiubite(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_qiubite_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_qiubite), NewState}.

%% ====================================================================
%% state_hunxueer
%% ====================================================================
state_hunxueer(start, State) ->
    do_duty_state_start(?DUTY_HUNXUEER, state_hunxueer, State);

state_hunxueer(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_HUNXUEER, State),
    {next_state, state_hunxueer, NewState};

state_hunxueer({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_hunxueer, State);

state_hunxueer(timeout, State) ->
    RandTarger = util:rand_in_list(lib_fight:get_alive_seat_list(State) -- 
                                  lib_fight:get_duty_seat(?DUTY_HUNXUEER, State), 1),
    do_duty_op_timeout(RandTarger, state_hunxueer, State);    

state_hunxueer(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_hunxuer_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_hunxueer), NewState}.

%% ====================================================================
%% state_shouwei
%% ====================================================================
state_shouwei(start, State) ->
    do_duty_state_start(?DUTY_SHOUWEI, state_shouwei, State);

state_shouwei(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_SHOUWEI, State),
    {next_state, state_shouwei, NewState};

state_shouwei({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_shouwei, State);

state_shouwei(timeout, State) ->
    TimeOutOp = [0],
    do_duty_op_timeout(TimeOutOp, state_shouwei, State);

state_shouwei(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_shouwei_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_shouwei), NewState}.
            
%% ====================================================================
%% state_langren
%% ====================================================================
state_langren(start, State) ->
    do_duty_state_start(?DUTY_LANGREN, state_langren, State);

state_langren(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_LANGREN, State),
    {next_state, state_langren, NewState};

state_langren({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    %%发给狼队友
    LangRenList = lib_fight:get_duty_seat(?DUTY_LANGREN, false, State),
    lib_fight:do_send_langren_team_fayan(PlayerId, Chat, LangRenList, State),
    {next_state, state_langren, State};

state_langren({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_langren, State);

state_langren(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_langren, State};

state_langren(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_langren_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_langren), NewState}.
                 
%% ====================================================================
%% state_nvwu
%% ====================================================================
state_nvwu(start, State) ->
    do_duty_state_start(?DUTY_NVWU, state_nvwu, State);

state_nvwu(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_NVWU, State),
    {next_state, state_nvwu, NewState};

state_nvwu({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_nvwu, State);

state_nvwu(timeout, State) ->
    Op = [0, 0],
    do_duty_op_timeout(Op, state_nvwu, State);

state_nvwu(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_nvwu_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_nvwu), NewState}.
            
%% ====================================================================
%% state_yuyanjia
%% ====================================================================
state_yuyanjia(start, State) ->
    case is_over(State) of
        true ->
            send_event_inner(start),
            {next_state, state_day, State};
        false ->
            do_duty_state_start(?DUTY_YUYANJIA, state_yuyanjia, State)
    end;

state_yuyanjia(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_YUYANJIA, State),
    {next_state, state_yuyanjia, NewState};

state_yuyanjia({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_yuyanjia, State);

state_yuyanjia(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_yuyanjia, State};

state_yuyanjia(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_yuyanjia_op(State),
    send_event_inner(start, b_fight_state_over_wait:get(state_yuyanjia)),
    {next_state, get_next_game_state(state_yuyanjia), NewState}.

%% ====================================================================
%% state_day
%% ====================================================================
state_day(start, State) ->
    lib_room:update_room_status(maps:get(room_id, State), 1, maps:get(game_round, State), 1, 1),
    notice_game_status_change(state_day, State),
    send_event_inner(over, b_fight_state_wait:get(state_day)),
    {next_state, state_day, State};

state_day(over, State)->
    NextState = 
        case is_over(State) of
            true ->
                state_fight_over;
            false ->
                case maps:get(fight_mod, State) of
                    0->
                        get_next_game_state(state_day);
                    1->
                        state_night_result;
                    _->
                        get_next_game_state(state_day)
                end
        end,
    send_event_inner(start),
    {next_state, NextState, State}.

    
%% ====================================================================
%% state_part_jingzhang
%% ====================================================================
state_part_jingzhang(start, State) ->
    GameRound = maps:get(game_round, State),
    case GameRound of
        1 ->
            case ?TEST of
                true ->
                    fight_test(state_part_jingzhang, State);
                false ->
                    notice_game_status_change(state_part_jingzhang, State),
                    send_event_inner(wait_op, b_fight_state_wait:get(state_part_jingzhang)),
                    {next_state, state_part_jingzhang, State}
            end;
        2 ->
            %%如果狼人自爆中断选举过程,第二天可以再次竞选警长,但是参与者按照第一天的算
            DoPoliceSelect = maps:get(do_police_select, State),
            case DoPoliceSelect of
                0 ->
                    PartJingZhangList = maps:get(part_jingzhang, State),
                    FayanList = [SeatId || SeatId <- (PartJingZhangList -- maps:get(out_seat_list, State))],
                    send_event_inner(start),
                    {next_state, get_next_game_state(state_part_jingzhang), maps:put(part_jingzhang, FayanList, State)};
                1 ->
                   send_event_inner(start),
                   {next_state, state_night_result, State} 
            end;
        _ ->
            send_event_inner(start),
            {next_state, state_night_result, State}
    end;

state_part_jingzhang(wait_op, State) ->
    % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_PART_JINGZHANG)),
    StateAfterNotice = notice_jingxuan_jingzhang(State),
    StateAfterWait = do_set_wait_op(?OP_PART_JINGZHANG, lib_fight:get_alive_seat_list(StateAfterNotice), StateAfterNotice),
    {next_state, state_part_jingzhang, StateAfterWait};

state_part_jingzhang({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_part_jingzhang, State);

state_part_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_part_jingzhang, State};
    
state_part_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_part_jingzhang_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_part_jingzhang), NewState}.

%% ====================================================================
%% state_part_fayan
%% ====================================================================
state_part_fayan(start, State) ->    
    Send = #m__fight__notice_part_jingzhang__s2l{seat_list = maps:get(part_jingzhang, State)},
    lib_fight:send_to_all_player(Send, State),
        
    do_fayan_state_start(maps:get(part_jingzhang, State), state_part_fayan, 
                            maps:put(parting_jingzhang, maps:get(part_jingzhang, State), State));

state_part_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_PART_FAYAN, state_part_fayan, State);

state_part_fayan({player_op, PlayerId, Op, [0]}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], state_part_fayan, State);

state_part_fayan({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    do_receive_fayan(PlayerId, Chat, State),
    {next_state, state_part_fayan, State};

state_part_fayan(timeout, State) ->
    do_fayan_state_timeout(state_part_fayan, State);

state_part_fayan(op_over, State) ->
    do_fayan_state_op_over(state_part_fayan, State);

state_part_fayan(_, State) ->
    {next_state, state_part_fayan, State}.    

%% ====================================================================
%% state_xuanju_jingzhang
%% ====================================================================
state_xuanju_jingzhang(start, State) ->
    case maps:get(part_jingzhang, State) of
        [] ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_xuanju_jingzhang), State};
        _ ->
            case ?TEST of
                true ->
                    fight_test(state_xuanju_jingzhang, State);
                false ->
                    notice_game_status_change(state_xuanju_jingzhang, State),
                    send_event_inner(wait_op, b_fight_state_wait:get(state_xuanju_jingzhang)),
                    {next_state, state_xuanju_jingzhang, State}
            end
    end;

state_xuanju_jingzhang(wait_op, State) ->
    % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_XUANJU_JINGZHANG)),
    StateAfterNotice = notice_xuanju_jingzhang(State),
    ExitJingZhang = maps:get(exit_jingzhang, StateAfterNotice),

    WaitList = (lib_fight:get_alive_seat_list(StateAfterNotice) -- maps:get(part_jingzhang, StateAfterNotice)) -- ExitJingZhang,
    lager:info("state_xuanju_jingzhang ~p", [WaitList]),
    StateAfterWait = do_set_wait_op(?OP_XUANJU_JINGZHANG, WaitList, StateAfterNotice),

    {next_state, state_xuanju_jingzhang, StateAfterWait};    
    
state_xuanju_jingzhang({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_xuanju_jingzhang, State);

state_xuanju_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_xuanju_jingzhang, State};

state_xuanju_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, XuanjuResult, MaxSeatList, NewState} = lib_fight:do_xuanju_jingzhang_op(State),
    notice_xuanju_jingzhang_result(IsDraw, maps:get(jingzhang, NewState), XuanjuResult, NewState),
    case IsDraw of
        true ->
            send_event_inner(start),
            {next_state, state_part_fayan, maps:put(part_jingzhang, MaxSeatList, NewState)};
        false ->  
            StateAfterPartingJingZhang = maps:put(parting_jingzhang, [], NewState), 
            send_event_inner(start),
            {next_state, get_next_game_state(state_xuanju_jingzhang), maps:put(do_police_select, 1, StateAfterPartingJingZhang)}
    end.     

%% ====================================================================
%% state_night_result
%% ====================================================================
state_night_result(start, State)->
    notice_game_status_change(state_night_result, State),
    %%客户端判断是不是平安夜
    notice_night_result(State),
    send_event_inner(over, b_fight_state_wait:get(state_night_result)),
    StateAfterNoticeDie = maps:put(day_notice_die, maps:get(day_notice_die, State) ++ maps:get(die, State), State),
    NewState = maps:put(show_nigth_result, 1, StateAfterNoticeDie),
    {next_state, state_night_result, lib_fight:set_skill_die_list(state_night_result, NewState)};

state_night_result(over, State)->
    send_event_inner(start),
    {next_state, state_someone_die, State};

state_night_result(_, State) ->
    {next_state, state_night_result,  State}.

%% ====================================================================
%% state_someone_die
%% ====================================================================
state_someone_die(start, State) ->
    {OpName, Op, StateAfterDieOp} = lib_fight:get_someone_die_op(State),
    {NextState, StateAfterOp} = 
    case OpName of
        op_over->
            send_event_inner(op_over),
            {state_someone_die, StateAfterDieOp};
        d_delay->
            TimeTick = util:rand(4000, 10000),
            notice_game_status_change(state_someone_die, [?OP_SKILL_D_DELAY], StateAfterDieOp),
            send_event_inner(op_over, TimeTick),
            SendDelayTick = #m__fight__op_timetick__s2l{
                                                        wait_op = ?OP_SKILL_D_DELAY,
                                                        timetick = lib_fight:get_op_wait(?OP_SKILL_D_DELAY, undefined, StateAfterDieOp)},
            lib_fight:send_to_all_player(SendDelayTick, StateAfterDieOp),
            {state_someone_die, maps:put(skill_d_delay, 1, StateAfterDieOp)};
        skip->
            send_event_inner(start),
            StateAfterBoom = 
                case maps:get(langren_boom, StateAfterDieOp) == 1 of
                    true->
                        state_night;
                    false->
                        get_next_game_state(maps:get(pre_state_name, StateAfterDieOp))
                end,
            {StateAfterBoom, StateAfterDieOp}; 
        _->
            notice_game_status_change(state_someone_die, [Op], StateAfterDieOp),
            send_event_inner(wait_op),
            {state_someone_die, StateAfterDieOp}
    end,
    {next_state, NextState, maps:put(cur_skill, 0, StateAfterOp)};

state_someone_die(wait_op, State) ->
    {_OpName, Op, StateAfterDieOp} = lib_fight:get_someone_die_op(State),
    {_DieType, OpSeat} = 
    case Op == ?OP_SKILL_CHANGE_JINGZHANG of
        true->
            {?DIE_TYPE_LANGRNE, maps:get(jingzhang, StateAfterDieOp)};
        false->
            SkillDieList = maps:get(skill_die_list, State),
            hd(SkillDieList)
    end,
    StateAfterSkillSeat = maps:put(skill_seat, OpSeat, StateAfterDieOp),
    % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(Op)),
    StateAfterOp = notice_player_op(Op, [OpSeat], StateAfterSkillSeat),
    lager:info("get_someone_die_op wait_op  ~p", [Op]),
    {next_state, state_someone_die, maps:put(cur_skill, Op, StateAfterOp)};

state_someone_die(timeout, State) ->
    SeatId = maps:get(skill_seat, State),
    Skill = maps:get(cur_skill, State),
    OpList = 
        case Skill of
            ?OP_SKILL_CHANGE_JINGZHANG ->
                [0];
            ?OP_SKILL_LIEREN ->
                [0];
            _->
                [0]
        end,
    PlayerId = lib_fight:get_player_id_by_seat(SeatId, State),
    NewState = lib_fight:do_skill(PlayerId, Skill, OpList, State),

    send_event_inner(op_over),
    {next_state, state_someone_die, NewState};

state_someone_die({player_op, PlayerId, Op, OpList}, State) ->
    try 
        assert_die_skill_legal(PlayerId, Op, OpList, State),
        NewState = lib_fight:do_skill(PlayerId, Op, OpList, State),
        send_event_inner(op_over),
        {next_state, state_someone_die, NewState}        
    catch
        throw:ErrCode ->
            net_send:send_errcode(ErrCode, PlayerId),
            {next_state, state_someone_die, State}
    end;

state_someone_die(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewSkillDieList = 
        case maps:get(skill_die_list, State) of
            [] ->
                [];
            SkillDieList ->
                case maps:get(cur_skill, State) == ?OP_SKILL_CHANGE_JINGZHANG of 
                    true->
                        SkillDieList;
                    false->
                        tl(SkillDieList)
                end
        end,
    ShowNightResult = maps:get(show_nigth_result, State),
    NextState = 
    case ShowNightResult == 1 of 
        true->
            state_someone_die;
        false->
            state_night_result
    end,
    send_event_inner(start),

    NextStateAfterOver = 
        case is_over(State) of
            true ->
                state_fight_over;
            false ->
                NextState
        end,
    {next_state, NextStateAfterOver, maps:put(skill_die_list, NewSkillDieList, State)}.

%% ====================================================================
%% state_night_death_fayan
%% ====================================================================
state_night_death_fayan(start, State) ->
    DieList = maps:get(die, State),
    case maps:get(game_round, State) of
        1 ->
            do_fayan_state_start(lists:sort(DieList), state_night_death_fayan, State);
        _ ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_night_death_fayan), State}
    end;

state_night_death_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_DEATH_FAYAN, state_night_death_fayan, State);

state_night_death_fayan({player_op, PlayerId, Op, [0]}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], state_night_death_fayan, State);

state_night_death_fayan({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    do_receive_fayan(PlayerId, Chat, State),
    {next_state, state_night_death_fayan, State};

state_night_death_fayan(timeout, State) ->
    do_fayan_state_timeout(state_night_death_fayan, State);

state_night_death_fayan(op_over, State) ->
    do_fayan_state_op_over(state_night_death_fayan, State).    

%% ====================================================================
%% state_jingzhang
%% ====================================================================
state_jingzhang(start, State) ->
    case ?TEST of
        true ->
            fight_test(state_jingzhang, State);
        false ->
            StateAfterZhuQuOp = maps:put(quzhu_op, 1, State),
            case maps:get(jingzhang, State, 0) of
                0 ->
                    StateAfterNoJingZhangOp = lib_fight:do_no_jingzhang_op(StateAfterZhuQuOp),
                    send_event_inner(start),
                    {next_state, get_next_game_state(state_jingzhang), StateAfterNoJingZhangOp};
                _ ->
                    notice_game_status_change(state_jingzhang, State),
                    send_event_inner(wait_op, b_fight_state_wait:get(state_jingzhang)),
                    {next_state, state_jingzhang, StateAfterZhuQuOp}
            end
    end;

state_jingzhang(wait_op, State) ->
    % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_JINGZHANG_ZHIDING)),
    JingZhang = maps:get(jingzhang, State),
    StateAfterOp = notice_player_op(?OP_JINGZHANG_ZHIDING, maps:get(die, State), [JingZhang], State),
    StateAfterWait = do_set_wait_op(?OP_JINGZHANG_ZHIDING, [JingZhang], StateAfterOp),
    {next_state, state_jingzhang, StateAfterWait}; 

state_jingzhang({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_jingzhang, State);

state_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_jingzhang, State};

state_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_jingzhang_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_jingzhang)),
    {next_state, get_next_game_state(state_jingzhang), NewState}.

%% ====================================================================
%% state_fayan
%% ====================================================================
state_fayan(start, State) ->
    do_fayan_state_start(maps:get(fayan_turn, State), state_fayan, State);

state_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_FAYAN, state_fayan, State);

state_fayan({player_op, PlayerId, Op, [0]}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], state_fayan, State);

state_fayan({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    do_receive_fayan(PlayerId, Chat, State),
    {next_state, state_fayan, State};

state_fayan(timeout, State) ->
    do_fayan_state_timeout(state_fayan, State);

state_fayan(op_over, State) ->
    do_fayan_state_op_over(state_fayan, State);
    
state_fayan(_, State) ->
    {next_state, state_fayan, State}.    

%% ====================================================================
%% state_guipiao
%% ====================================================================
state_guipiao(start, State) ->
    case ?TEST of
        true ->
            fight_test(state_guipiao, State);
        false ->
            case maps:get(jingzhang, State, 0) of
                0 ->
                    send_event_inner(start),
                    {next_state, get_next_game_state(state_guipiao), State};
                _ ->
                    DrawCnt = maps:get(xuanju_draw_cnt, State),
                    case DrawCnt of
                        0->
                            notice_game_status_change(state_guipiao, State),
                            send_event_inner(wait_op, b_fight_state_wait:get(state_guipiao)),
                            {next_state, state_guipiao, State};
                        1->
                            %%平票投票直接跳过归票
                            send_event_inner(start),
                            {next_state, get_next_game_state(state_guipiao), State}
                    end
                
            end
    end;

state_guipiao(wait_op, State) ->
    % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_GUIPIAO)),
    JingZhang = maps:get(jingzhang, State),
    StateAfterOp = notice_player_op(?OP_GUIPIAO, [JingZhang], State),
    StateAfterWait = do_set_wait_op(?OP_GUIPIAO, [JingZhang], StateAfterOp),
    {next_state, state_guipiao, StateAfterWait}; 

state_guipiao({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_guipiao, State);

state_guipiao(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_guipiao, State};

state_guipiao(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_guipiao_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_guipiao), NewState}.

%% ====================================================================
%% state_toupiao
%% ====================================================================
state_toupiao(start, State) ->
    case ?TEST of
        true ->
            fight_test(state_toupiao, State);
        false ->
            notice_game_status_change(state_toupiao, State),
            send_event_inner(wait_op, b_fight_state_wait:get(state_toupiao)),
            {next_state, state_toupiao, maps:put(lieren_kill, 0, State)}
    end;
    
state_toupiao(wait_op, State) ->
    % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_TOUPIAO)),\
    StateAfterNotice = notice_toupiao(State),
    WaitList = (lib_fight:get_alive_seat_list(StateAfterNotice) -- 
            [maps:get(baichi, StateAfterNotice)]) -- maps:get(die, StateAfterNotice),
    StateAfterWait = do_set_wait_op(?OP_TOUPIAO, WaitList, StateAfterNotice),
    {next_state, state_toupiao, StateAfterWait};    
    
state_toupiao({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_toupiao, State);

state_toupiao(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_toupiao, State};

state_toupiao(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, TouPiaoResult, MaxSelectList, NewState} = lib_fight:do_toupiao_op(State),
    Quzhu = maps:get(quzhu, NewState),
    notice_state_toupiao_result(IsDraw, Quzhu, TouPiaoResult, NewState),
    case IsDraw andalso lib_fight:is_twice_toupiao(NewState) of
        true ->
            send_event_inner(start, b_fight_state_over_wait:get(state_toupiao)),
            {next_state, state_fayan, maps:put(fayan_turn, MaxSelectList, NewState)};
        false ->   
            %%临时6秒
            StateAfterQuzhu = 
            case (Quzhu =/= 0) andalso (?DUTY_BAICHI == lib_fight:get_duty_by_seat(Quzhu, NewState)) of
                true->
                    %%白痴直接翻牌
                    StateAfterBaichi = lib_fight:do_skill(lib_fight:get_player_id_by_seat(Quzhu, NewState), ?OP_SKILL_BAICHI, [0], NewState),
                    case maps:get(baichi, StateAfterBaichi) == 0 of
                        true->
                            StateAfterNoticeDie = maps:put(day_notice_die, maps:get(day_notice_die, StateAfterBaichi) ++ [Quzhu], StateAfterBaichi),
                            notice_toupiao_out([Quzhu], StateAfterNoticeDie),
                            lib_fight:lover_die_judge(Quzhu, StateAfterNoticeDie);
                        false->
                            StateAfterBaichi
                    end;
                false->
                    %%客户端根据通知结果判断是否平安日
                    StateAfterNoticeDie = maps:put(day_notice_die, maps:get(day_notice_die, NewState) ++ [Quzhu], NewState),
                    notice_toupiao_out([Quzhu], StateAfterNoticeDie),
                    lib_fight:lover_die_judge(Quzhu, StateAfterNoticeDie)
            end,

            send_event_inner(wait_over, b_fight_state_over_wait:get(state_toupiao)),
            {next_state, state_toupiao, lib_fight:set_skill_die_list(state_toupiao, StateAfterQuzhu)}
    end;

state_toupiao(wait_over, State)->
    send_event_inner(start),
    NextState = 
    case is_over(State) of
        true ->
            state_fight_over;
        false ->
            state_someone_die
    end,
    {next_state, NextState, lib_fight:set_skill_die_list(state_toupiao, State)}.
            
%% ====================================================================
%% state_toupiao_death_fayan
%% ====================================================================

state_toupiao_death_fayan(start, State) ->
    case is_over(State) of
        true ->
            send_event_inner(start),
            {next_state, state_fight_over, State};
        false ->
            do_fayan_state_start(([maps:get(quzhu, State)] ++ lib_fight:get_lover_kill(State)) ++ 
                lib_fight:get_lieren_kill(State) -- [maps:get(baichi, State)], state_toupiao_death_fayan, State)
    end;

state_toupiao_death_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_QUZHU_FAYAN, state_toupiao_death_fayan, State);

state_toupiao_death_fayan({player_op, PlayerId, Op, [0]}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], state_toupiao_death_fayan, State);

state_toupiao_death_fayan({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    do_receive_fayan(PlayerId, Chat, State),
    {next_state, state_toupiao_death_fayan, State};

state_toupiao_death_fayan(timeout, State) ->
    do_fayan_state_timeout(state_toupiao_death_fayan, State);

state_toupiao_death_fayan(op_over, State) ->
    do_fayan_state_op_over(state_toupiao_death_fayan, State).

%% ====================================================================
%% state_day
%% ====================================================================
state_night(start, State) ->
    NewState = out_die_player(State),
    % {IsOver, Winner, VictoryParty} = get_fight_result(NewState),
    % case IsOver of
    %     true ->
    %         send_fight_result(Winner, VictoryParty, NewState),
    %         send_event_inner(start, b_fight_state_wait:get(state_night)),
    %         {next_state, state_over, NewState};
    %     false ->
    StateAfterClear = clear_night_op(NewState),
    lib_room:update_room_status(maps:get(room_id, StateAfterClear), 1, maps:get(game_round, StateAfterClear), 1, 0),
    notice_game_status_change(state_night, StateAfterClear),
    send_event_inner(over, b_fight_state_wait:get(state_night)),
    {next_state, state_night, StateAfterClear};
    % end;

state_night(over, State)->
    send_event_inner(start),
    {next_state, get_next_game_state(state_night), State}.




%% ====================================================================
%% state_fight_over 战斗结束
%% ====================================================================
state_fight_over(start, State) ->
    NewState = out_die_player(State),
    {_, Winner, _VictoryParty} = get_fight_result(NewState),
    DutyList = [#p_duty{seat_id = SeatId,
                        duty_id = DutyId} || 
                        {SeatId, DutyId} <- maps:to_list(maps:get(seat_duty_map, NewState))], 
    %%todo:通知战斗信息
    %%send_fight_result(Winner, VictoryParty, NewState),

    notice_game_status_change(state_fight_over, NewState),
    Send = #m__fight__over_info__s2l{duty_list = DutyList, winner = Winner, 
                                                dead_list = maps:get(out_seat_list, NewState)},
    lib_fight:send_to_all_player(Send, NewState),
    send_event_inner(start, b_fight_state_wait:get(state_fight_over)),
    StateAfterMvp = maps:put(mvp_party, Winner, NewState),
    StateAfterCarry = maps:put(carry_party, lib_fight:get_all_seat(StateAfterMvp) -- Winner, StateAfterMvp),
    StateAfterFayanTurn = maps:put(fayan_turn, lib_fight:get_all_seat(StateAfterCarry), StateAfterCarry),
    StateAfterWinner = maps:put(winner, Winner, StateAfterFayanTurn),
    NextState =
    case lib_fight:is_need_mvp(StateAfterWinner) of
        true->
            state_lapiao_fayan;
        _->
            state_game_over
    end,
    {next_state, NextState, StateAfterWinner}.


%%拉票发言环节
state_lapiao_fayan(start, State) ->
    do_fayan_state_start(maps:get(fayan_turn, State), state_lapiao_fayan, State);

state_lapiao_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_LAPIAO_FAYAN, state_lapiao_fayan, State);

state_lapiao_fayan({player_op, PlayerId, Op, [0]}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], state_lapiao_fayan, State);

state_lapiao_fayan({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    do_receive_fayan(PlayerId, Chat, State),
    {next_state, state_lapiao_fayan, State};

state_lapiao_fayan(timeout, State) ->
    do_fayan_state_timeout(state_lapiao_fayan, State);

state_lapiao_fayan(op_over, State) ->
    do_fayan_state_op_over(state_lapiao_fayan, State).

%%投票mvp
state_toupiao_mvp(start, State) ->
    Mvp = maps:get(mvp, State),
    NextState = 
    case Mvp == 0 of
        true->
            notice_game_status_change(state_toupiao_mvp, State),
            send_event_inner(wait_op, b_fight_state_wait:get(state_toupiao_mvp)),
            state_toupiao_mvp;
        false->
            send_event_inner(start),
            state_toupiao_carry
    end,
    {next_state, NextState, State};
    
state_toupiao_mvp(wait_op, State) ->
    % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_TOUPIAO)),
    StateAfterNotice = notice_toupiao_mvp(State),
    WaitList = lib_fight:get_all_seat(StateAfterNotice),
    StateAfterWait = do_set_wait_op(?OP_TOUPIAO_MVP, WaitList, StateAfterNotice),
    {next_state, state_toupiao_mvp, StateAfterWait};    
    
state_toupiao_mvp({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_toupiao_mvp, State);

state_toupiao_mvp(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_toupiao_mvp, State};

state_toupiao_mvp(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, TouPiaoResult, MaxSelectList, NewState} = lib_fight:do_toupiao_mvp_op(State),
    Mvp = maps:get(mvp, NewState),
    case IsDraw of
        true ->
            notice_state_toupiao_mvp_result(IsDraw, Mvp, TouPiaoResult, NewState),
            StateAfterMvpParty = maps:put(mvp_party, MaxSelectList, NewState),
            send_event_inner(start, b_fight_state_over_wait:get(state_toupiao_mvp)),
            {next_state, state_lapiao_fayan, maps:put(fayan_turn, MaxSelectList, StateAfterMvpParty)};
        false ->   
            %%临时6秒
            SelectMvp = 
            case Mvp =/= 0 of
                true->
                    Mvp;
                _->
                    %%安装魅力值高低选择一个(如果魅力值有相同的(?是否随机一个))
                    %%lib_fight:get_max_luck_seat(maps:get(mvp_party, NewState), NewState)
                    lib_fight:get_max_luck_seat(maps:get(mvp_party, NewState), NewState)
            end,
            notice_state_toupiao_mvp_result(IsDraw, SelectMvp, TouPiaoResult, NewState),
            StateAfterMvp = maps:put(mvp, SelectMvp, NewState),
            send_event_inner(wait_over, b_fight_state_over_wait:get(state_toupiao_mvp)),
            {next_state, state_toupiao_mvp, StateAfterMvp}
    end;

state_toupiao_mvp(wait_over, State)->
    send_event_inner(start),
    {next_state, state_toupiao_carry, State}.

%%投票mvp
state_toupiao_carry(start, State) ->
    notice_game_status_change(state_toupiao_carry, State),
    send_event_inner(wait_op, b_fight_state_wait:get(state_toupiao_carry)),
    {next_state, state_toupiao_carry, State};
    
state_toupiao_carry(wait_op, State) ->
    % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_TOUPIAO)),
    StateAfterNotice = notice_toupiao_carry(State),
    WaitList = lib_fight:get_all_seat(StateAfterNotice),
    StateAfterWait = do_set_wait_op(?OP_TOUPIAO_CARRY, WaitList, StateAfterNotice),
    {next_state, state_toupiao_carry, StateAfterWait};    
    
state_toupiao_carry({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_toupiao_carry, State);

state_toupiao_carry(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_toupiao_carry, State};

state_toupiao_carry(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, TouPiaoResult, MaxSelectList, NewState} = lib_fight:do_toupiao_carry_op(State),
    Carry = maps:get(carry, NewState),
    case IsDraw of
        true ->
            notice_state_toupiao_carry_result(IsDraw, Carry, TouPiaoResult, NewState),
            StateAfterMvpParty = maps:put(carry_party, MaxSelectList, NewState),
            send_event_inner(start, b_fight_state_over_wait:get(state_toupiao_carry)),
            {next_state, state_lapiao_fayan, maps:put(fayan_turn, MaxSelectList, StateAfterMvpParty)};
        false ->   
            %%临时6秒
            SelectCarry = 
            case Carry =/= 0 of
                true->
                    Carry;
                _->
                    %%安装魅力值高低选择一个(如果魅力值有相同的(?是否随机一个))
                    %%lib_fight:get_max_luck_seat(maps:get(mvp_party, NewState), NewState)
                    lib_fight:get_max_luck_seat(maps:get(carry_party, NewState), NewState)
            end,
            notice_state_toupiao_carry_result(IsDraw, SelectCarry, TouPiaoResult, NewState),
            StateAfterCarry = maps:put(carry, SelectCarry, NewState),
            send_event_inner(wait_over, b_fight_state_over_wait:get(state_toupiao_carry)),
            {next_state, state_toupiao_carry, StateAfterCarry}
    end;

state_toupiao_carry(wait_over, State)->
    send_event_inner(start),
    {next_state, state_game_over, State}.

%% ====================================================================
%% 游戏结束
%% ====================================================================
state_game_over(start, State) ->
    NewState = out_die_player(State),
    {_, Winner, VictoryParty} = get_fight_result(NewState),
    send_fight_result(Winner, VictoryParty, NewState),
    send_event_inner(start, b_fight_state_wait:get(state_fight_over)),
    {next_state, state_over, NewState}.


%% ====================================================================
%% state_over
%% ====================================================================

state_over(start, State) ->
    lager:info("state_over++++++++++++++++++++"),
    RoomId = maps:get(room_id, State),
    PlayerList = maps:get(player_list, State),
    [global_op_srv:player_op(PlayerId, {lib_player, update_fight_pid, [undefined]}) || PlayerId <- PlayerList],
    room_srv:update_room_fight_pid(RoomId, undefined),
    lib_room:update_room_status(RoomId, 0, 0, 0, 0),
    {stop, normal, State}.


state_name(_Event, _From, StateData) ->
    Reply = next_state,
    {reply, Reply, state_name, StateData}.


handle_event({skill, _PlayerId, ?OP_SKILL_END_FIGHT, _OpList}, _StateName, State) ->
    send_event_inner(start),
    {next_state, state_over, State};

handle_event({skill, PlayerId, Op, OpList}, StateName, State) ->
    try 
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
        assert_skill_legal(SeatId, Op, OpList, StateName, State),
        NewState = lib_fight:do_skill(PlayerId, Op, OpList, State),
        NextState = get_skill_next_state(Op, StateName, State),
        lager:info("handle_event ~p", [[NextState, StateName, OpList, Op]]),
        NextStateAfterOver = 
        case is_over(NewState) of
            true ->
                state_fight_over;
            false ->
                NextState
        end,
        case NextStateAfterOver of
            StateName ->
                {next_state, StateName, NewState};
            _ ->
                StateAfterParting = maps:put(parting_jingzhang, [], NewState),
                cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
                send_event_inner(start),
                {next_state, NextStateAfterOver, StateAfterParting}
        end
    catch
        throw:ErrCode ->
            net_send:send_errcode(ErrCode, PlayerId),
            {next_state, StateName, State} 
    end;

handle_event({player_online, PlayerId}, StateName, State) ->
    OfflineList = maps:get(offline_list, State),
    NewOfflineList = OfflineList -- [PlayerId],
    NewState =  maps:put(offline_list, NewOfflineList, State),
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, NewState),
    DutyId = lib_fight:get_duty_by_seat(SeatId, NewState),
    Round = maps:get(game_round, NewState),
    GameState = maps:get(game_state, NewState),
    DieList = maps:get(out_seat_list, NewState) ++ maps:get(day_notice_die, NewState),
    JingZhang = maps:get(jingzhang, NewState),
    FlopList = maps:get(flop_list, NewState),
    LeaveList = maps:get(leave_player, NewState),
    Winner = maps:get(winner, NewState),
    WaitOp = maps:get(wait_op, NewState),
    WaitOpList = maps:get(wait_op_list, NewState),
    WaitOpAttackData = maps:get(wait_op_attack_data, NewState),
    ExitJingZhang = maps:get(exit_jingzhang, NewState),
    PartingJingZhang = maps:get(parting_jingzhang, NewState),
    OpStartTime = maps:get(op_timer_start, NewState),
    lager:info("player_online ~p", [OpStartTime]),
    OpUseTime = maps:get(op_timer_use_dur, NewState),
    
    {AttachData1, AttachData2} = get_online_attach_data(SeatId, DutyId, NewState),
    Send = #m__fight__online__s2l{duty = DutyId,
                                  fight_info = lib_fight:get_p_fight(NewState),
                                  seat_id = SeatId,
                                  game_state =GameState,
                                  round = Round,
                                  wait_op = WaitOp,
                                  wait_op_list = WaitOpList,
                                  wait_op_attach_data = WaitOpAttackData,
                                  wait_op_tick = OpUseTime - (util:get_micro_time() - OpStartTime),
                                  die_list = DieList,
                                  attach_data1 = AttachData1,
                                  attach_data2 = AttachData2,
                                  offline_list = [lib_fight:get_seat_id_by_player_id(OffPlayerId, NewState)||OffPlayerId <- NewOfflineList],
                                  leave_list = [lib_fight:get_seat_id_by_player_id(LeavePlayerId, NewState)||LeavePlayerId <- LeaveList],
                                  jingzhang = JingZhang,
                                  lover_list = get_online_lover_data(SeatId, NewState),
                                  flop_list =[#p_flop{seat_id = CurSeatId,
                                                      op = CurOp} || {CurSeatId, CurOp} <- FlopList],
                                  winner = Winner,
                                  duty_list = get_online_duty_data(Winner, NewState),
                                  parting_jingzhang = PartingJingZhang -- ExitJingZhang
                                  },
    net_send:send(Send, PlayerId),

    %%刷新离线列表
    SendOffline = #m__fight__offline__s2l{
                       offline_list = [lib_fight:get_seat_id_by_player_id(OffPlayerId, NewState)||OffPlayerId <- NewOfflineList]  
                    },
    lib_fight:send_to_all_player(SendOffline, NewState, [PlayerId]),

    StateAfterTimeUpdate = player_online_offline_wait_op_time_update(SeatId, NewState),
    {next_state, StateName, StateAfterTimeUpdate};

handle_event({player_offline, PlayerId}, StateName, State) ->
    OfflineList = maps:get(offline_list, State),
    NewOfflineList = util:add_element_single(PlayerId, OfflineList),
    NewState =  maps:put(offline_list, NewOfflineList, State),
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    lager:info("player_offline ~p", [length(NewOfflineList)]),
    Send = #m__fight__offline__s2l{
                       offline_list = [lib_fight:get_seat_id_by_player_id(OffPlayerId, NewState)||OffPlayerId <- NewOfflineList]  
                    },
    lib_fight:send_to_all_player(Send, NewState),
    StateAfterTimeUpdate = player_online_offline_wait_op_time_update(SeatId, NewState),
    {next_state, StateName, StateAfterTimeUpdate};

handle_event({player_leave, PlayerId}, StateName, State) ->
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    DieList = maps:get(out_seat_list, State) ++ maps:get(day_notice_die, State),

    StateAfterLeave = 
    case lists:member(SeatId, DieList) of
        false->
            lib_fight:send_to_seat(#m__room__leave_room__s2l{result=2}, SeatId, State),
            State;
        _->
            lib_fight:send_to_seat(#m__room__leave_room__s2l{result=1}, SeatId, State),
            room_srv:leave_room(lib_player:get_player(PlayerId)),
            NewLeavePlayerList = maps:get(leave_player, State) ++ [PlayerId],
            NewState = maps:put(leave_player, NewLeavePlayerList, State),
            Send = #m__fight__leave__s2l{
                               leave_list = [lib_fight:get_seat_id_by_player_id(LeavePlayerId, NewState)
                                                                            ||LeavePlayerId <- NewLeavePlayerList]   
                            },
            lib_fight:send_to_all_player(Send, NewState),
            player_online_offline_wait_op_time_update(SeatId, NewState)
    end,
    {next_state, StateName, StateAfterLeave};

handle_event(print_state, StateName, StateData) ->
    lager:info("state name ~p", [StateName]),
    lager:info("state data ~p", [StateData]),
    {next_state, StateName, StateData}.

handle_sync_event(_Event, _From, StateName, StateData) ->
    Reply = ok,
    {reply, Reply, StateName, StateData}.

handle_info(_Info, StateName, StateData) ->
    {next_state, StateName, StateData}.

terminate(_Reason, _StateName, _StatData) ->
    ok.

code_change(_OldVsn, StateName, StateData, _Extra) ->
    {ok, StateName, StateData}.

%% ====================================================================
%% gen_fsm Internal functions
%% ====================================================================

send_event_inner(Event) ->
    send_event_inner(Event, 0).

send_event_inner(Event, Time) ->
    gen_fsm:send_event_after(Time, Event).

%%启动一个gen_fsm定时器并将ref保存在进程字典

start_fight_fsm_event_timer({Event, Arg}, Time) ->
    TimerRef = gen_fsm:send_event_after(Time, {Event, Arg}),
    put(Event, TimerRef);

start_fight_fsm_event_timer(Event, Time) ->
    TimerRef = gen_fsm:send_event_after(Time, Event),
    put(Event, TimerRef).

%%取消一个gen_fsm定时器删除进程字典
cancel_fight_fsm_event_timer(Event) ->
    TimerRef = get(Event),
    case TimerRef of
        undefined ->
            ignore;
        _ ->
            gen_fsm:cancel_timer(TimerRef),
            erase(Event)
    end.

%% ====================================================================
%% Internal functions
%% ====================================================================

notice_duty(State) ->
    SeatDutyMap = maps:get(seat_duty_map, State),
    FightInfo = lib_fight:get_p_fight(State),
    FunNotice = 
        fun(SeatId) ->
            Duty = maps:get(SeatId, SeatDutyMap),
            Send = #m__fight__notice_duty__s2l{duty = Duty,
                                               seat_id = SeatId,
                                               fight_info = FightInfo
                                               },
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, maps:keys(SeatDutyMap))
    LangRenList = lib_fight:get_duty_seat(?DUTY_LANGREN, State),
    SendLangRenList = #m__fight__notice_langren__s2l{langren_list=LangRenList},
    [lib_fight:send_to_seat(SendLangRenList, LangRenSeatId, State) | LangRenSeatId<-LangRenList].

do_duty_state_start(Duty, GameState, State) ->
    SeatIdList = lib_fight:get_duty_seat(Duty, State),
    case SeatIdList of
        [] ->
            send_event_inner(start),
            {next_state, get_next_game_state(GameState), State};
        _ ->
            notice_game_status_change(GameState, State),
            case ?TEST of
                true ->
                    fight_test(GameState, State);
                false ->
                    send_event_inner(wait_op, b_fight_state_wait:get(GameState)),
                    {next_state, GameState, State}
            end
    end.

do_duty_state_wait_op(Duty, State) ->
    % case b_fight_op_wait:get(Duty) of
    %     0 ->
    %         ignore;
    %     WaitTime ->
    %         start_fight_fsm_event_timer(?TIMER_TIMEOUT, WaitTime)
    % end,
    SeatIdList = lib_fight:get_duty_seat(Duty, State),
    StateAfterOp = notice_player_op(Duty, SeatIdList, State),
    do_set_wait_op(Duty, SeatIdList, StateAfterOp).

do_duty_op_timeout(OpList, StateName, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    SeatId = hd(maps:get(wait_op_list, State)),
    StateAfterLogOp = do_log_op(SeatId, OpList, State),
    {_, StateAfterWaitOp} = do_remove_wait_op(SeatId, StateAfterLogOp),
    send_event_inner(op_over),
    {next_state, StateName, StateAfterWaitOp}.

do_receive_player_op(PlayerId, Op, OpList, StateName, State) ->
    try
        assert_op_in_wait(PlayerId, State),
        assert_op_legal(Op, StateName),
        assert_op_fit(Op, OpList, State),
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
        StateAfterLogOp = do_log_op(SeatId, OpList, State),
        {IsWaitOver, StateAfterWaitOp} = do_remove_wait_op(SeatId, StateAfterLogOp),
        case IsWaitOver of
            true ->
                send_event_inner(op_over);
            false ->
                ignore
        end,
        {next_state, StateName, StateAfterWaitOp}
    catch 
        throw:ErrCode ->
            net_send:send_errcode(ErrCode, PlayerId),
            {next_state, StateName, State}
    end.    

do_fayan_state_start(InitFayanList, StateName, State) ->
    FayanList = [SeatId || SeatId <- InitFayanList, SeatId =/= 0],
    case FayanList == [0] orelse FayanList == [] of
        true ->
            send_event_inner(start),
            {next_state, get_next_game_state(StateName), State};
        false ->
            case ?TEST of
                true ->
                    fight_test(StateName, State);
                false ->
                    DrawCnt = maps:get(xuanju_draw_cnt, State),
                    notice_game_status_change(StateName, [DrawCnt], State),
                    NewState = maps:put(fayan_turn, FayanList, State),
                    send_event_inner(wait_op, b_fight_state_wait:get(StateName)),
                    {next_state, StateName, NewState}
            end
    end.

do_fayan_state_wait_op(Op, StateName, State) ->
    % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_FAYAN)),
    Fayan = hd(maps:get(fayan_turn, State)),
    notice_start_fayan(Fayan, State),
    StateAfterOp = notice_player_op(Op, [Fayan], State),
    StateAfterWait = do_set_wait_op(Op, [Fayan], StateAfterOp),
    {next_state, StateName, lib_fight:do_fayan_op(StateAfterWait)}.

do_fayan_state_timeout(StateName, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    notice_stop_fayan(hd(maps:get(wait_op_list, State)), State),
    send_event_inner(op_over),
    {next_state, StateName, State}.

do_fayan_state_op_over(StateName, State) ->
    % StateAfterFayan = lib_fight:do_fayan_op(State),
    StateAfterFayan = lib_fight:clear_last_op(State),
    case maps:get(fayan_turn, StateAfterFayan) of
        [] ->
            send_event_inner(start),
            {next_state, get_next_game_state(StateName), StateAfterFayan};
        _ ->
            send_event_inner(wait_op),
            {next_state, StateName, StateAfterFayan}
    end.

do_receive_fayan(PlayerId, Chat, State) ->
    try
        assert_op_in_wait(PlayerId, State),
        lib_fight:do_send_fayan(PlayerId, Chat, State)
    catch
        throw:ErrCode ->
            net_send:send_errcode(ErrCode, PlayerId)
    end.       

notice_player_op(?DUTY_LANGREN, SeatList, State) ->
    notice_player_op(?DUTY_LANGREN, lib_fight:get_alive_seat_list(State), SeatList, State);

notice_player_op(?DUTY_DAOZEI, SeatList, State) ->
    notice_player_op(?DUTY_DAOZEI, maps:get(daozei, State), SeatList, State);

notice_player_op(?DUTY_SHOUWEI, SeatList, State) ->
    notice_player_op(?DUTY_SHOUWEI, [maps:get(shouwei, State)], SeatList, State);

notice_player_op(?DUTY_NVWU, SeatList, State) ->
    notice_player_op(?DUTY_NVWU, [lists:sum(maps:get(nvwu_left, State))] ++ [maps:get(langren, State)], SeatList, State);

notice_player_op(?OP_XUANJU_JINGZHANG, SeatList, State) ->
    notice_player_op(?OP_XUANJU_JINGZHANG, maps:get(part_jingzhang, State), SeatList, State);

notice_player_op(Op, SeatList, State) ->
    notice_player_op(Op, SeatList, SeatList, State).

notice_player_op(Op, AttachData, SeatList, State) ->
    lager:info("notice_player_op ~p", [Op]),
    WaitTime = lib_fight:get_op_wait(Op, SeatList, State),
    UseWaitTime = 
    case lib_fight:is_offline_all(SeatList, State) of
        true->
            lib_fight:get_op_wait(?OP_SKILL_OFFLINE, undefined, State);
        _->
            WaitTime
    end,
    Send = #m__fight__notice_op__s2l{op = Op,
                                     attach_data = AttachData},
    FunNotice = 
        fun(SeatId) ->
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, SeatList),
    case WaitTime == 0 of
        true->
            State;
        _->
            cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
            start_fight_fsm_event_timer(?TIMER_TIMEOUT, UseWaitTime),
            StateAfterAttackData = maps:put(wait_op_attack_data, AttachData, State),
            %%正常延时时间
            StateAfterNormalDuration = maps:put(op_timer_normal_dur, WaitTime, StateAfterAttackData),
            %%
            StateAfterStart = maps:put(op_timer_start, util:get_micro_time(), StateAfterNormalDuration),
            case lists:member(Op, ?FAYAN_OP_LIST) of
                true->
                    UseWaitTimeSend = #m__fight__op_timetick__s2l{wait_op = Op,timetick = UseWaitTime},
                    lib_fight:send_to_all_player(UseWaitTimeSend, StateAfterStart),
                    maps:put(op_timer_use_dur, UseWaitTime, StateAfterStart);
                _->
                    NormalWaitTimeSend = #m__fight__op_timetick__s2l{wait_op = Op,timetick = WaitTime},
                    lib_fight:send_to_all_player(NormalWaitTimeSend, StateAfterStart),
                    maps:put(op_timer_use_dur, WaitTime, StateAfterStart)
            end
    end.

do_set_wait_op(Op, SeatIdList, State) ->
    StateAfterOp = maps:put(wait_op, Op, State),
    maps:put(wait_op_list, SeatIdList, StateAfterOp).

assert_op_in_wait(PlayerId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    case lists:member(SeatId, WaitOpList) of
        false ->
            throw(?ERROR);
        true ->
            next_state
    end.

assert_op_legal(Op, StateName) ->
    case lists:member(Op, get_state_legal_op(StateName)) of
        true ->
            ok;
        false ->
            throw(?ERROR)
    end.

assert_op_fit(?DUTY_NVWU, [_, UseYao], State) ->
    case lists:member(UseYao, maps:get(nvwu_left, State)) == true orelse UseYao == 0 of
        true ->
            ok;
        false ->
            throw(?ERROR)
    end;

assert_op_fit(?OP_XUANJU_JINGZHANG, [SeatId], State) ->
    PartList = maps:get(part_jingzhang, State),
    case lists:member(SeatId, PartList) of
        true ->
            ok;
        false ->
            throw(?ERROR)
    end;

assert_op_fit(_, _, _) ->
    ok.

assert_die_skill_legal(PlayerId, _Op, _OpList, State) ->
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    SkillDieList = maps:get(skill_die_list, State),
    case SkillDieList of
        [] ->
            throw(?ERROR);
        _ ->
            ok
    end,
    {_, Die} = hd(SkillDieList),
    case Die of
        SeatId ->
            ok;
        _ ->
            throw(?ERROR)
    end.

assert_skill_legal(_SeatId, _SkillId, _SkillData, _StateName, _State) ->
    ok.

get_skill_next_state(Op, StateName, State) ->
    case Op of
        ?OP_SKILL_EIXT_PART_JINGZHANG ->
            StateName;
        ?OP_SKILL_LANGREN ->
            ShowNightResult = maps:get(show_nigth_result, State),
            case ShowNightResult == 1 of
                true->
                    state_someone_die;
                false->
                    state_night_result
            end;
        ?OP_SKILL_BAILANG->
            state_someone_die;
        _->
            StateName
    end.

do_log_op(SeatId, OpList, State) ->
    lager:info("do_log_op ~p", [{SeatId, OpList}]),
    LastOpData = maps:get(last_op_data, State),
    NewLastOpData = maps:put(SeatId, OpList, LastOpData),
    maps:put(last_op_data, NewLastOpData, State).

%%剩下等待的人是否全部离线并且超过10秒操作时间
wait_op_list_all_offline_players_timeout(WaitOpList, State)->
    case ([] =/= WaitOpList) andalso lib_fight:is_offline_all(WaitOpList, State) of
        true->
            case maps:get(op_timer_start, State) of
                0->
                    [];
                StartTime->
                    %%如果剩下的是离线玩家并且总共操作时间超过10秒，直接跳过
                    case (util:get_micro_time() - StartTime) > lib_fight:get_op_wait(?OP_SKILL_OFFLINE, undefined, State) of
                        true->
                            [];
                        _->
                            cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
                            start_fight_fsm_event_timer(?TIMER_TIMEOUT, 
                                lib_fight:get_op_wait(?OP_SKILL_OFFLINE, undefined, State) - (util:get_micro_time() - StartTime)),
                            WaitOpList
                    end
            end;
        _->
            WaitOpList
    end.

%%玩家上线下线等待延时操作
player_online_offline_wait_op_time_update(SeatId, State)->
    NormalDuration = maps:get(op_timer_normal_dur, State),
    UseDuration = maps:get(op_timer_use_dur, State),
    StartTime = maps:get(op_timer_start, State),
    WaitOpList = maps:get(wait_op_list, State),
    WaitOp = maps:get(wait_op, State),
    case (undefined =/= StartTime) andalso ([] =/= WaitOpList)
                                     andalso lists:member(SeatId, WaitOpList) of
        true->
            case lib_fight:is_offline_all(WaitOpList, State) of
                true->
                    %离线玩家总共等待10秒,并且只等待一次
                    TotalLeft = NormalDuration - (util:get_micro_time() - StartTime),
                    case TotalLeft > lib_fight:get_op_wait(?OP_SKILL_OFFLINE, undefined, State) of
                        true->
                            cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
                            start_fight_fsm_event_timer(?TIMER_TIMEOUT, lib_fight:get_op_wait(?OP_SKILL_OFFLINE, undefined, State)),
                            State;
                        _->
                            cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
                            start_fight_fsm_event_timer(?TIMER_TIMEOUT, TotalLeft),
                            State
                    end;
                _->
                    case UseDuration == NormalDuration of
                        true->
                            State;
                        _->
                            %%重连上来>
                            case (util:get_micro_time() - StartTime) >= NormalDuration of
                                true->
                                    State;
                                _->
                                    WaitTime = NormalDuration - (util:get_micro_time() - StartTime),
                                    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
                                    start_fight_fsm_event_timer(?TIMER_TIMEOUT, WaitTime),
                                    %%通知更新倒计时
                                    UseWaitTimeSend = #m__fight__op_timetick__s2l{wait_op = WaitOp, timetick = WaitTime},
                                    lib_fight:send_to_all_player(UseWaitTimeSend, State),
                                    maps:put(op_timer_use_dur, NormalDuration, State)
                            end 
                    end
            end;
        _->
            State
    end.

do_remove_wait_op(SeatId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    NewWaitOpList = wait_op_list_all_offline_players_timeout(WaitOpList -- [SeatId], State),
    NewState = 
    case NewWaitOpList of
        []->
            maps:put(wait_op, 0, State);
        _->
            State
    end,
    {NewWaitOpList == [], maps:put(wait_op_list, NewWaitOpList, NewState)}.

notice_jingxuan_jingzhang(State) ->
    notice_player_op(?OP_PART_JINGZHANG, lib_fight:get_alive_seat_list(State), State).

notice_xuanju_result(XaunJuType, IsDraw, XuanjuSeat, XuanJuResult, State) ->
    PResutList = [#p_xuanju_result{seat_id = SeatId, 
                                   select_list = SelectList} || {SeatId, SelectList} <- XuanJuResult],
    Send = #m__fight__xuanju_result__s2l{xuanju_type = XaunJuType,
                                         result_list = PResutList,
                                         result_id = XuanjuSeat,
                                         is_draw = util:conver_bool_to_int(IsDraw)},
    lib_fight:send_to_all_player(Send, State).

notice_xuanju_jingzhang(State) ->
    ExitJingZhang = maps:get(exit_jingzhang, State),
    PartXuanjuList = maps:get(part_jingzhang, State),
    notice_player_op(?OP_XUANJU_JINGZHANG, PartXuanjuList, 
        (lib_fight:get_alive_seat_list(State) -- PartXuanjuList) -- ExitJingZhang, State).

notice_xuanju_jingzhang_result(IsDraw, JingZhang, XuanjuResult, State) ->
    notice_xuanju_result(?XUANJU_TYPE_JINGZHANG, IsDraw, JingZhang, XuanjuResult, State).

notice_toupiao(State) ->
    notice_toupiao([], State).

notice_toupiao(MaxSelectList, State) ->
    AliveList = lib_fight:get_alive_seat_list(State),
    notice_player_op(?OP_TOUPIAO, AliveList -- maps:get(die, State), (((AliveList -- MaxSelectList) -- 
                                                 [maps:get(baichi, State)]) -- maps:get(die, State)), State).

notice_toupiao_mvp(State) ->
    PartyList = maps:get(mvp_party, State),
    notice_player_op(?OP_TOUPIAO_MVP, PartyList, lib_fight:get_all_seat(State), State).

notice_toupiao_carry(State) ->
    PartyList = maps:get(carry_party, State),
    notice_player_op(?OP_TOUPIAO_CARRY, PartyList, lib_fight:get_all_seat(State), State).

notice_night_result(State) ->
    Send = #m__fight__night_result__s2l{die_list = maps:get(die, State)},
    lib_fight:send_to_all_player(Send, State).

out_die_player(State) ->
    NewState = maps:put(out_seat_list, (maps:get(out_seat_list, State) ++ maps:get(die, State) ++ 
                            [maps:get(quzhu, State)]) -- [maps:get(baichi, State)], State),
    % lager:info("out_die_player  ~p ~p ~p ~p", [maps:get(out_seat_list, State),maps:get(die, State),[maps:get(quzhu, State)],[maps:get(baichi, State)]]),
    NewState.

get_fight_result(State) ->
    LangrenAlive = lib_fight:get_duty_seat(?DUTY_LANGREN, State),
    ShenMinAlive = lib_fight:get_shenmin_seat(State),
        % lists:flatten([lib_fight:get_duty_seat(DutyId, State) || DutyId <- ?DUTY_LIST_SHENMIN]),
    AllLangren = lib_fight:get_duty_seat(?DUTY_LANGREN, false, State),
    AllSeat = lib_fight:get_all_seat(State),
    try
        case LangrenAlive of
            [] ->
                LangRenQiubite = lib_fight:get_langren_qiubite_seat(State),
                ThirdPartQiubite = lib_fight:get_third_part_qiubite_seat(State),
                LangRenHunxuer = lib_fight:get_langren_hunxuer_seat(State),
                LWinner1 = AllSeat -- AllLangren,
                LWinner2 = LWinner1 -- LangRenQiubite,
                LWinner3 = LWinner2 -- ThirdPartQiubite,
                LWinner4 = LWinner3 -- LangRenHunxuer,
                throw({true, LWinner4, 0});
            _ ->
                ignore
        end,

        case lib_fight:is_third_part_win(State) of
            true->
                throw({true, lib_fight:get_third_part_seat(State), 2});    
            _->
                ignore
        end, 

        case ShenMinAlive of
            [] ->
                LangrenQiubite = lib_fight:get_langren_qiubite_seat(State),
                LangRenHunxuer1 = lib_fight:get_langren_hunxuer_seat(State),
                SWinner1 = AllLangren ++ LangrenQiubite,
                SWinner2 = SWinner1 ++ LangRenHunxuer1,
                throw({true, SWinner2, 1});
            _ ->
                ignore
        end,
        case lib_fight:get_duty_seat(?DUTY_PINGMIN, State) of
            [] ->
                LangrenQiubite1 = lib_fight:get_langren_qiubite_seat(State),
                LangRenHunxuer2 = lib_fight:get_langren_hunxuer_seat(State),
                PWinner1 = AllLangren ++ LangrenQiubite1,
                PWinner2 = PWinner1 ++ LangRenHunxuer2,
                throw({true, PWinner2, 1});
            _ ->
                ignore
        end,
           
        {false, [], 0}
    catch 
        throw:Result ->
            Result
    end.

clear_night_op(State) ->
    JingZhang = maps:get(jingzhang, State),
    NewJingZhang = 
        case lists:member(JingZhang, maps:get(out_seat_list, State)) of
            true ->
                0;
            false ->
                JingZhang
        end,
    State#{
           wait_op => 0,        %%等待的操作 
           wait_op_list => [],   %% 等待中的操作
           nvwu => {0, 0},       %% 女巫操作
           langren => 0,         %% 狼人击杀的目标
           bailang => 0,         %% 白狼自爆
           jingzhang_op => 0,    %% 警长操作
           fayan_turn => [],     %% 发言顺序
           die => [],            %% 死亡玩家
           quzhu => 0,           %% 驱逐的玩家
           last_op_data => #{},  %% 上一轮操作的数据, 杀了几号, 投了几号等等}.
           game_round => maps:get(game_round, State) + 1,
           jingzhang => NewJingZhang,
           lieren_kill => 0,
           lover_kill => 0,
           exit_jingzhang => [], %%
           langren_boom => 0,
           show_nigth_result => 0,
           flop_list => [],
           parting_jingzhang => [],
           day_notice_die => [],
           quzhu_op => 0,
           safe_night => 1,         %%平安夜
           safe_day => 1           %%平安日
           }.

notice_state_toupiao_result(IsDraw, Quzhu, TouPiaoResult, State) ->
    notice_xuanju_result(?XUANJU_TYPE_QUZHU, IsDraw, Quzhu, TouPiaoResult, State).  

notice_state_toupiao_mvp_result(IsDraw, Quzhu, TouPiaoResult, State) ->
    notice_xuanju_result(?XUANJU_TYPE_MVP, IsDraw, Quzhu, TouPiaoResult, State).  

notice_state_toupiao_carry_result(IsDraw, Quzhu, TouPiaoResult, State) ->
    notice_xuanju_result(?XUANJU_TYPE_CARRY, IsDraw, Quzhu, TouPiaoResult, State). 

notice_toupiao_out([0], _) ->
    ignore;

notice_toupiao_out(SeatList, State) ->  
    notice_player_op(?OP_QUZHU, SeatList, lib_fight:get_all_seat(State), State).

notice_game_status_change(Status, State) ->
    notice_game_status_change(Status, [], State).

notice_game_status_change(Status, AttachData, State) ->
    StatusId = get_status_id(Status),
    Send = #m__fight__game_state_change__s2l{game_status = StatusId,
                                             attach_data = AttachData},
    lib_fight:send_to_all_player(Send, State).

get_win_count(SeatId, Winner)->
    case lists:member(SeatId, Winner) of
        true->
            1;
        _->
            0
    end.

is_mvp(SeatId, MvpSeat)->
    case SeatId == MvpSeat of
        true->
            1;
        _->
            0
    end.

is_carry(SeatId, CarrySeat)->
    case SeatId == CarrySeat of
        true->
            1;
        _->
            0
    end.

fight_result_op(Winner, VictoryParty, DutyList, ResultSeatId, ResultDutyId, State)->
    MvpSeat = maps:get(mvp, State),
    CarrySeat = maps:get(carry, State),
    #{lover := Lover,
      hunxuer := Hunxuer} = State,
    ThirdPartyList = lib_fight:get_third_part_seat(State),
    WinCount = get_win_count(ResultSeatId, Winner),
    IsMvp = is_mvp(ResultSeatId, MvpSeat),
    IsCarry = is_carry(ResultSeatId, CarrySeat),
    IsThirdParty = lists:member(ResultSeatId, ThirdPartyList),
    PlayerId = lib_fight:get_player_id_by_seat(ResultSeatId, State),
    CoinExtraAdd = mod_player:get_extra_coin(WinCount, IsMvp, IsCarry, IsThirdParty),
    CoinAdd = mod_player:get_fight_coin(ResultDutyId, WinCount, IsThirdParty),
    CurLevel = mod_resource:get_num(?RESOURCE_LV, PlayerId),
    ExpExtraAdd = mod_player:get_extra_exp(WinCount, IsMvp, IsCarry, IsThirdParty),
    ExpAdd = mod_player:get_fight_exp(ResultDutyId, WinCount, IsThirdParty),
    CurExp = mod_resource:get_num(?RESOURCE_EXP, PlayerId),
    lib_fight:send_to_seat(#m__fight__result__s2l{
                                  winner = Winner,
                                  lover = Lover,
                                  hunxuer = Hunxuer,
                                  duty_list = DutyList,
                                  daozei = maps:get(daozei_seat, State),
                                  mvp = MvpSeat,
                                  carry = CarrySeat,
                                  coin_add = CoinExtraAdd + CoinAdd,
                                  cur_level = CurLevel,
                                  cur_exp = CurExp,
                                  exp_add = ExpExtraAdd + ExpAdd,
                                  pre_level_up_exp = b_exp:get(CurLevel - 1),
                                  level_up_exp = b_exp:get(CurLevel),
                                  next_level_up_exp = b_exp:get(CurLevel + 1),
                                  victory_party = VictoryParty,
                                  room_id = maps:get(room_id, State)
                                  }, ResultSeatId, State),
    mod_player:handle_fight_result(
                ResultDutyId, 
                WinCount,
                IsMvp,
                IsCarry,
                CoinExtraAdd + CoinAdd,
                ExpExtraAdd + ExpAdd,    
                PlayerId).

send_fight_result(Winner, VictoryParty, State) ->
    DutyList = [#p_duty{seat_id = SeatId,
                        duty_id = DutyId} || 
                        {SeatId, DutyId} <- maps:to_list(maps:get(seat_duty_map, State))], 
    [fight_result_op(Winner, VictoryParty, DutyList, ResultSeatId, ResultDutyId, State)
                 || {ResultSeatId, ResultDutyId} <- maps:to_list(maps:get(seat_duty_map, State))],
    RoomId = maps:get(room_id, State),

    case RoomId > 0 of
        true->
            Room = lib_room:get_room(RoomId),
            mod_room:notice_team_change(Room);
        _->
            ignore
    end.

notice_start_fayan(SeatId, State) ->
    Send = #m__fight__notice_fayan__s2l{seat_id = SeatId},
    lib_fight:send_to_all_player(Send, State).

notice_stop_fayan(SeatId, State) ->
    Send = #m__fight__stop_fayan__s2l{seat_id = SeatId},
    lib_fight:send_to_seat(Send, SeatId, State).

is_over(State) ->
    NewState = out_die_player(State),
    {IsOver, _Winner, _VictoryParty} = get_fight_result(NewState),
    IsOver.

get_online_attach_data(_SeatId, ?DUTY_YUYANJIA, State) ->
    lists:unzip(maps:get(yuyanjia_op, State));

get_online_attach_data(_SeatId, ?DUTY_LANGREN, State) ->
    {lib_fight:get_duty_seat(false, ?DUTY_LANGREN, State) ++ lib_fight:get_duty_seat(false, ?DUTY_BAILANG, State), []};

get_online_attach_data(_SeatId, ?DUTY_BAILANG, State) ->
    {lib_fight:get_duty_seat(false, ?DUTY_LANGREN, State) ++ lib_fight:get_duty_seat(false, ?DUTY_BAILANG, State), []};

get_online_attach_data(_SeatId, ?DUTY_SHOUWEI, State) ->
    {[maps:get(shouwei, State)], []};

get_online_attach_data(_SeatId, ?DUTY_HUNXUEER, State) ->
    {[maps:get(hunxuer, State)], []};

get_online_attach_data(_SeatId, ?DUTY_QIUBITE, State) ->
    {maps:get(lover, State), []};

get_online_attach_data(_, _, _) ->
    {[],[]}.

get_online_lover_data(SeatId, State)->
    Lover = maps:get(lover, State),
    case (Lover =/= []) andalso lists:member(SeatId, Lover) of
        true->
            Lover;
        _->
            []
    end.

get_online_duty_data(Winner, State)->
    case Winner of
        []->
            [];
        _->
            [#p_duty{seat_id = SeatId,
                        duty_id = DutyId} || 
                        {SeatId, DutyId} <- maps:to_list(maps:get(seat_duty_map, State))]
    end.

get_next_game_state(GameState) ->
    case GameState of
        state_daozei ->
            state_qiubite;
        state_qiubite ->
            state_hunxueer;
        state_hunxueer ->
            state_shouwei;
        state_shouwei ->
            state_langren;
        state_langren ->
            state_nvwu;
        state_nvwu ->
            state_yuyanjia;
        state_yuyanjia ->
            state_day;
        state_day ->
            state_part_jingzhang;
        state_part_jingzhang ->
            state_part_fayan;
        state_part_fayan ->
            state_xuanju_jingzhang;
        state_xuanju_jingzhang ->
            state_night_result;
        state_night_result->
            state_night_death_fayan;
        state_night_death_fayan ->
            state_jingzhang;
        state_jingzhang ->
            state_fayan;
        state_fayan ->
            state_guipiao;
        state_guipiao ->
            state_toupiao;
        state_toupiao ->
            state_toupiao_death_fayan;
        state_toupiao_death_fayan ->
            state_night;
        state_night ->
            state_shouwei;
        state_lapiao_fayan->
            state_toupiao_mvp;
        state_select_card->
            state_daozei
    end.

get_state_legal_op(GameState) ->
    case GameState of
        state_daozei ->
            [?DUTY_DAOZEI];
        state_qiubite ->
            [?DUTY_QIUBITE];
        state_hunxueer ->
            [?DUTY_HUNXUEER];
        state_shouwei ->
            [?DUTY_SHOUWEI];
        state_langren ->
            [?DUTY_LANGREN];
        state_nvwu ->
            [?DUTY_NVWU];
        state_yuyanjia ->
            [?DUTY_YUYANJIA];
        state_part_jingzhang ->
            [?OP_PART_JINGZHANG];
        state_part_fayan ->
            [?OP_PART_FAYAN, ?OP_FAYAN];
        state_xuanju_jingzhang ->
            [?OP_XUANJU_JINGZHANG];
        state_night_death_fayan ->
            [?OP_FAYAN, ?OP_DEATH_FAYAN];
        state_jingzhang ->
            [?OP_JINGZHANG_ZHIDING];
        state_guipiao ->
            [?OP_GUIPIAO];
        state_fayan ->
            [?OP_FAYAN];
        state_toupiao ->
            [?OP_TOUPIAO];
        state_toupiao_death_fayan ->
            [?OP_FAYAN, ?OP_QUZHU_FAYAN];
        state_day ->
            [];
        state_night ->
            [];
        state_night_result->
            [];
        state_fight_over ->
            [];
        state_lapiao_fayan ->
            [?OP_FAYAN,?OP_LAPIAO_FAYAN];
        state_toupiao_mvp ->
            [?OP_TOUPIAO_MVP];
        state_toupiao_carry ->
            [?OP_TOUPIAO_CARRY];
        state_select_card->
            [?OP_SELECT_DUTY]
    end.

get_status_id(GameState) ->
    case GameState of
        start ->
            0;
        state_daozei ->
            1;
        state_qiubite ->
            2;
        state_hunxueer ->
            3;
        state_shouwei ->
            4;
        state_langren ->
            5;
        state_nvwu ->
            6;
        state_yuyanjia ->
            7;
        state_day ->
            8;
        state_part_jingzhang ->
            9;
        state_part_fayan ->
            10;
        state_xuanju_jingzhang ->
            11;
        state_night_result->
            12;
        state_night_death_fayan ->
            13;
        state_jingzhang ->
            14;
        state_fayan ->
            15;
        state_guipiao ->
            16;
        state_toupiao ->
            17;
        state_toupiao_death_fayan ->
            18;
        state_night ->
            19;
        state_someone_die ->
            20;
        state_lapiao_fayan ->
            21;
        state_toupiao_mvp ->
            22;
        state_toupiao_carry ->
            23;
        state_fight_over ->
            24;
        state_select_card ->
            25
    end.

fight_test_no_send(StateName, State) ->
    StateNthList = maps:get(state_nth_list, State, []),
    StateNth = 
        case lists:keyfind(StateName, 1, StateNthList) of
            false ->
                1;
            {_, Nth} ->
                Nth
        end,
    NewStateNthList = lists:keystore(StateName, 1, StateNthList, {StateName, StateNth + 1}),

    StateAfterInnerData = fight_test_inner(StateNth, StateName, State),
    maps:put(state_nth_list, NewStateNthList, StateAfterInnerData).

fight_test(StateName, State) ->
    StateAfterInnerData = fight_test_no_send(StateName, State),
    send_event_inner(op_over),
    {next_state, StateName, StateAfterInnerData}.

fight_test_inner(StateNth, StateName, State) ->
    ReplaceDataList = b_fight_test:get({StateNth, StateName}),
    FunReplace = 
        fun({ReplaceKey, ReplaceData}, CurState) ->
                maps:put(ReplaceKey, ReplaceData, CurState)
        end,
    lists:foldl(FunReplace, State, ReplaceDataList).