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

-export([state_daozei/2,
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
         state_over/2]).

-include("fight.hrl").
-include("errcode.hrl").
-include("game_pb.hrl").

-define(TEST, false).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/3,
         player_op/4,
         player_skill/4,
         player_speak/3,
         print_state/1,
         player_online/1,
         player_offline/1
         ]).

start_link(RoomId, PlayerList, DutyList) ->
    gen_fsm:start(?MODULE, [RoomId, PlayerList, DutyList, ?MFIGHT], []).

player_op(Pid, PlayerId, Op, OpList) ->
    gen_fsm:send_event(Pid, {player_op, PlayerId, Op, OpList}).

player_speak(Pid, PlayerId, Chat) ->
    gen_fsm:send_event(Pid, {player_op, PlayerId, ?OP_FAYAN, [Chat]}).    

player_skill(Pid, PlayerId, Op, OpList) ->
    gen_fsm:send_all_state_event(Pid, {skill, PlayerId, Op, OpList}).

print_state(Pid) ->
    gen_fsm:send_all_state_event(Pid, print_state).

player_online(Player) ->
    case lib_fight:get_fight_pid(Player) of
        undefined ->
            ignore;
        Pid ->
            ignore
            % gen_fsm:send_all_state_event(Pid, {player_online, lib_player:get_player_id(Player)})
    end.    

player_offline(Player) ->
    case lib_fight:get_fight_pid(Player) of
        undefined ->
            ignore;
        Pid ->
            ignore
            % gen_fsm:send_all_state_event(Pid, {player_offline, lib_player:get_player_id(Player)})
    end.

%% ====================================================================
%% Behavioural functions
%% ====================================================================

init([RoomId, PlayerList, DutyList, State]) ->
    lib_room:update_fight_pid(RoomId, self()),
    NewState = lib_fight:init(RoomId, PlayerList, DutyList, State),
    notice_game_status_change(start, NewState),
    notice_duty(NewState),
    send_event_inner(start, b_fight_state_wait:get(start)),
    {ok, state_daozei, NewState}.

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

state_qiubite({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_qiubite, State);

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
    TimeOutOp = 
        case ?TEST of
            true ->
                [lib_fight:rand_in_alive_seat(State)];
            false ->
                [0]
        end,
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

state_langren({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_langren, State);

state_langren(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    case ?TEST of
        true ->
            [send_event_inner({player_op, lib_fight:get_player_id_by_seat(SeatId, State),
                    ?DUTY_LANGREN, [lib_fight:rand_in_alive_seat(State)]}) || 
            SeatId <- lib_fight:get_duty_seat(?DUTY_LANGREN, State)];
        false ->
            send_event_inner(op_over)
    end,
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
    Op = 
        case ?TEST of
            true ->
                [util:rand_in_list([0, 1, 2]), lib_fight:rand_in_alive_seat(State)];
            false ->
                [0, 0]
        end,
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
    send_event_inner(start),
    {next_state, get_next_game_state(state_yuyanjia), NewState}.

%% ====================================================================
%% state_day
%% ====================================================================
state_day(start, State) ->
    notice_game_status_change(state_day, State),
    send_event_inner(over, b_fight_state_wait:get(state_day)),
    {next_state, state_day, State};

state_day(over, State)->
    NextState = 
        case is_over(State) of
            true ->
                state_fight_over;
            false ->
                get_next_game_state(state_day)
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
            notice_game_status_change(state_part_jingzhang, State),
            send_event_inner(wait_op, b_fight_state_wait:get(state_part_jingzhang)),
            {next_state, state_part_jingzhang, State};
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
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_PART_JINGZHANG)),
    notice_jingxuan_jingzhang(State),
    StateAfterWait = do_set_wait_op(lib_fight:get_alive_seat_list(State), State),
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
    case ?TEST == true andalso maps:get(part_jingzhang, State) == [] of
        true ->
            {next_state, get_next_game_state(state_part_jingzhang), 
            maps:put(part_jingzhang, [lib_fight:rand_in_alive_seat(State)], State)};
        false ->
            {next_state, get_next_game_state(state_part_jingzhang), NewState}
    end.

%% ====================================================================
%% state_part_fayan
%% ====================================================================
state_part_fayan(start, State) ->    
    Send = #m__fight__notice_part_jingzhang__s2l{seat_list = maps:get(part_jingzhang, State)},
    lib_fight:send_to_all_player(Send, State),
    
    do_fayan_state_start(maps:get(part_jingzhang, State), state_part_fayan, State);

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
            notice_game_status_change(state_xuanju_jingzhang, State),
            send_event_inner(wait_op, b_fight_state_wait:get(state_xuanju_jingzhang)),
            {next_state, state_xuanju_jingzhang, State}
    end;

state_xuanju_jingzhang(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_XUANJU_JINGZHANG)),
    notice_xuanju_jingzhang(State),
    ExitJingZhang = maps:get(exit_jingzhang, State),
    WaitList = (lib_fight:get_alive_seat_list(State) -- maps:get(part_jingzhang, State)) -- ExitJingZhang,
    StateAfterWait = do_set_wait_op(WaitList, State),
    {next_state, state_xuanju_jingzhang, StateAfterWait};    
    
state_xuanju_jingzhang({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_xuanju_jingzhang, State);

state_xuanju_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    case ?TEST of
        true ->
            send_event_inner({player_op, lib_fight:get_player_id_by_seat(lib_fight:rand_in_alive_seat(State), State), 
                              ?OP_XUANJU_JINGZHANG, [util:rand_in_list(maps:get(part_jingzhang, State))]});
        false ->
            ignore
    end,

    send_event_inner(op_over),
    {next_state, state_xuanju_jingzhang, State};

state_xuanju_jingzhang(op_over, State) ->
    {IsDraw, XuanjuResult, MaxSeatList, NewState} = lib_fight:do_xuanju_jingzhang_op(State),
    notice_xuanju_jingzhang_result(IsDraw, maps:get(jingzhang, NewState), XuanjuResult, NewState),
    case IsDraw of
        true ->
            send_event_inner(start),
            {next_state, state_part_fayan, maps:put(part_jingzhang, MaxSeatList, NewState)};
        false ->   
            send_event_inner(start),
            {next_state, get_next_game_state(state_xuanju_jingzhang), maps:put(do_police_select, 1, NewState)}
    end.     

%% ====================================================================
%% state_night_result
%% ====================================================================
state_night_result(start, State)->
    notice_game_status_change(state_night_result, State),
    %%客户端判断是不是平安夜
    notice_night_result(State),
    send_event_inner(over, b_fight_state_wait:get(state_night_result)),
    NewState = maps:put(show_nigth_result, 1, State),
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
    lager:info("state_someone_die  ~p", [OpName, Op]),
    NextState = 
    case OpName of
        op_over->
            send_event_inner(op_over),
            state_someone_die;
        d_delay->
            notice_game_status_change(state_someone_die, [?OP_SKILL_D_DELAY], StateAfterDieOp),
            send_event_inner(op_over, b_fight_op_wait:get(?OP_SKILL_D_DELAY)),
            state_someone_die;
        skip->
            send_event_inner(start),
            StateAfterBoom = 
                case maps:get(langren_boom, StateAfterDieOp) == 1 of
                    true->
                        state_day;
                    false->
                        get_next_game_state(maps:get(pre_state_name, StateAfterDieOp))
                end,
            StateAfterBoom; 
        _->
            notice_game_status_change(state_someone_die, [Op], StateAfterDieOp),
            send_event_inner(wait_op, b_fight_op_wait:get(Op)),
            state_someone_die
    end,
    {next_state, NextState, StateAfterDieOp};

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
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(Op)),
    notice_player_op(Op, [OpSeat], StateAfterSkillSeat),
    {next_state, state_someone_die, maps:put(cur_skill, Op, StateAfterSkillSeat)};

state_someone_die(timeout, State) ->
    SeatId = maps:get(skill_seat, State),
    Skill = maps:get(cur_skill, State),
    OpList = 
        case Skill of
            ?OP_SKILL_CHANGE_JINGZHANG ->
                case ?TEST of
                    true ->
                        [lib_fight:rand_in_alive_seat(State)];
                    false ->
                        [0]
                end;
            ?OP_SKILL_LIEREN ->
                case ?TEST of
                    true ->
                        [lib_fight:rand_in_alive_seat(State)];
                    false ->
                        [0]
                end
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
    {next_state, NextState, maps:put(skill_die_list, NewSkillDieList, State)}.
    

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
    end;

state_jingzhang(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_JINGZHANG_ZHIDING)),
    JingZhang = maps:get(jingzhang, State),
    notice_player_op(?OP_JINGZHANG_ZHIDING, maps:get(die, State), [JingZhang], State),
    StateAfterWait = do_set_wait_op([JingZhang], State),
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
            
    end;

state_guipiao(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_GUIPIAO)),
    JingZhang = maps:get(jingzhang, State),
    notice_player_op(?OP_GUIPIAO, [JingZhang], State),
    StateAfterWait = do_set_wait_op([JingZhang], State),
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
    notice_game_status_change(state_toupiao, State),
    send_event_inner(wait_op, b_fight_state_wait:get(state_toupiao)),
    {next_state, state_toupiao, maps:put(lieren_kill, 0, State)};

state_toupiao(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_TOUPIAO)),
    notice_toupiao(State),
    WaitList = lib_fight:get_alive_seat_list(State) -- [maps:get(baichi, State)],
    StateAfterWait = do_set_wait_op(WaitList, State),
    {next_state, state_toupiao, StateAfterWait};    
    
state_toupiao({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_toupiao, State);

state_toupiao(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    case ?TEST of
        true ->
            send_event_inner({player_op, lib_fight:get_player_id_by_seat(lib_fight:rand_in_alive_seat(State), State), 
                              ?OP_TOUPIAO, [lib_fight:rand_in_alive_seat(State)]});
        false ->
            ignore
    end,
    send_event_inner(op_over),
    {next_state, state_toupiao, State};

state_toupiao(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, TouPiaoResult, MaxSelectList, NewState} = lib_fight:do_toupiao_op(State),
    Quzhu = maps:get(quzhu, NewState),
    notice_state_toupiao_result(IsDraw, Quzhu, TouPiaoResult, NewState),
    case IsDraw of
        true ->
            send_event_inner(start, b_fight_wait_op:get(state_toupiao)),
            {next_state, state_fayan, maps:put(toupiao_draw_list, MaxSelectList, NewState)};
        false ->   
            %%临时6秒
            StateAfterQuzhu = 
            case (Quzhu =/= 0) andalso (?DUTY_BAICHI == lib_fight:get_duty_by_seat(Quzhu, NewState)) of
                true->
                    %%白痴直接翻牌
                    StateAfterBaichi = lib_fight:do_skill(lib_fight:get_player_id_by_seat(Quzhu), ?OP_SKILL_BAICHI, [0], NewState),
                    case maps:get(baichi, StateAfterBaichi) == 0 of
                        true->
                            notice_toupiao_out(Quzhu, NewState);
                        false->
                            ignore
                    end;
                false->
                    %%客户端根据通知结果判断是否平安日
                    notice_toupiao_out(Quzhu, NewState),
                    NewState
            end,

            send_event_inner(wait_over, b_fight_wait_op:get(state_toupiao)),
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
            do_fayan_state_start([maps:get(quzhu, State)] ++ 
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
    {IsOver, Winner} = get_fight_result(NewState),
    case IsOver of
        true ->
            send_fight_result(Winner, NewState),
            send_event_inner(start, b_fight_state_wait:get(state_night)),
            {next_state, state_over, NewState};
        false ->
            notice_game_status_change(state_night, State),
            send_event_inner(over, b_fight_state_wait:get(state_night)),
            {next_state, state_night, NewState}
    end;

state_night(over, State)->
    send_event_inner(start),
    {next_state, get_next_game_state(state_night), clear_night_op(State)}.

%% ====================================================================
%% state_fight_over
%% ====================================================================
state_fight_over(start, State) ->
    NewState = out_die_player(State),
    {_, Winner} = get_fight_result(NewState),
    send_fight_result(Winner, NewState),
    send_event_inner(start, b_fight_state_wait:get(state_fight_over)),
    {next_state, state_over, NewState}.

%% ====================================================================
%% state_over
%% ====================================================================

state_over(start, State) ->
    {stop, normal, State}.


state_name(_Event, _From, StateData) ->
    Reply = next_state,
    {reply, Reply, state_name, StateData}.

handle_event({skill, PlayerId, Op, OpList}, StateName, State) ->
    try 
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
        assert_skill_legal(SeatId, Op, OpList, StateName, State),
        NewState = lib_fight:do_skill(PlayerId, Op, OpList, State),
        NextState = get_skill_next_state(Op, StateName, State),
        case NextState of
            StateName ->
                {next_state, StateName, NewState};
            _ ->
                send_event_inner(start),
                {next_state, StateName, NewState}
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

    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    DutyId = lib_fight:get_duty_by_seat(SeatId, State),
    Round = maps:get(game_round, State),
    GameState = maps:get(game_state, State),
    DieList = maps:get(out_seat_list, State),
    {AttachData1, AttachData2} = get_online_attach_data(SeatId, DutyId, State),

    Send = #m__fihgt__online__s2l{duty = DutyId,
                                  seat_id = SeatId,
                                  game_state =GameState,
                                  round = Round,
                                  speak_id = 0,
                                  die_list = DieList,
                                  attach_data1 = AttachData1,
                                  attach_data2 = AttachData2
                                  },
    mod_send:send(Send, PlayerId),

    {next_state, StateName, NewState};

handle_event({player_offline, PlayerId}, StateName, State) ->
    OfflineList = maps:get(offline_list, State),
    NewOfflineList = util:add_element_single(PlayerId, OfflineList),
    NewState =  maps:put(offline_list, NewOfflineList, State),
    {next_state, StateName, NewState};

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

% send_event_to_fsm(Event, Player) ->
%     PlayerFightProcess = lib_room:get_fight_pid_by_player(Player),
%     case PlayerFightProcess of
%         undefined ->
%             ignore;
%         _ ->
%             gen_fsm:send_event(PlayerFightProcess, Event)
%     end.

% send_event_to_all_state(Event, Player) ->
%     PlayerFightProcess = lib_room:get_fight_pid_by_player(Player),
%     case PlayerFightProcess of
%         undefined ->
%             ignore;
%         _ ->
%             gen_fsm:send_all_state_event(PlayerFightProcess, Event)
%     end.

%% ====================================================================
%% Internal functions
%% ====================================================================

notice_duty(State) ->
    SeatDutyMap = maps:get(seat_duty_map, State),
    FunNotice = 
        fun(SeatId) ->
            Duty = maps:get(SeatId, SeatDutyMap),
            Send = #m__fight__notice_duty__s2l{duty = Duty,
                                               seat_id = SeatId},
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, maps:keys(SeatDutyMap)).

do_duty_state_start(Duty, GameState, State) ->
    SeatIdList = lib_fight:get_duty_seat(Duty, State),
    case SeatIdList of
        [] ->
            send_event_inner(start),
            {next_state, get_next_game_state(GameState), State};
        _ ->
            notice_game_status_change(GameState, State),
            send_event_inner(wait_op, b_fight_state_wait:get(GameState)),
            {next_state, GameState, State}
    end.

do_duty_state_wait_op(Duty, State) ->
    case b_fight_op_wait:get(Duty) of
        0 ->
            ignore;
        WaitTime ->
            start_fight_fsm_event_timer(?TIMER_TIMEOUT, WaitTime)
    end,
    SeatIdList = lib_fight:get_duty_seat(Duty, State),
    notice_player_op(Duty, SeatIdList, State),
    do_set_wait_op(SeatIdList, State).

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
            DrawCnt = maps:get(xuanju_draw_cnt, State),
            notice_game_status_change(StateName, [DrawCnt], State),
            NewState = maps:put(fayan_turn, FayanList, State),
            send_event_inner(wait_op, b_fight_state_wait:get(StateName)),
            {next_state, StateName, NewState}
    end.

do_fayan_state_wait_op(Op, StateName, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_FAYAN)),
    Fayan = hd(maps:get(fayan_turn, State)),
    notice_start_fayan(Fayan, State),
    notice_player_op(Op, [Fayan], State),
    StateAfterWait = do_set_wait_op([Fayan], State),
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

notice_player_op(?DUTY_DAOZEI, SeatList, State) ->
    notice_player_op(?DUTY_DAOZEI, maps:get(daozei, State), SeatList, State);
    
notice_player_op(?DUTY_NVWU, SeatList, State) ->
    notice_player_op(?DUTY_NVWU, [lists:sum(maps:get(nvwu_left, State))] ++ [maps:get(langren, State)], SeatList, State);

notice_player_op(?OP_XUANJU_JINGZHANG, SeatList, State) ->
    notice_player_op(?OP_XUANJU_JINGZHANG, maps:get(part_jingzhang, State), SeatList, State);

notice_player_op(Op, SeatList, State) ->
    notice_player_op(Op, SeatList, SeatList, State).

notice_player_op(Op, AttachData, SeatList, State) ->
    Send = #m__fight__notice_op__s2l{op = Op,
                                     attach_data = AttachData},
    FunNotice = 
        fun(SeatId) ->
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, SeatList).

do_set_wait_op(SeatIdList, State) ->
    maps:put(wait_op_list, SeatIdList, State).

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
    LastOpData = maps:get(last_op_data, State),
    NewLastOpData = maps:put(SeatId, OpList, LastOpData),
    maps:put(last_op_data, NewLastOpData, State).

do_remove_wait_op(SeatId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    NewWaitOpList = WaitOpList -- [SeatId],
    {NewWaitOpList == [], maps:put(wait_op_list, NewWaitOpList, State)}.

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
    notice_player_op(?OP_TOUPIAO, MaxSelectList, (((AliveList -- MaxSelectList) -- 
                                                 [maps:get(baichi, State)]) -- maps:get(die, State)), State).

notice_night_result(State) ->
    Send = #m__fight__night_result__s2l{die_list = maps:get(die, State)},
    lib_fight:send_to_all_player(Send, State).

out_die_player(State) ->
    maps:put(out_seat_list, (maps:get(out_seat_list, State) ++ maps:get(die, State) ++ 
                            [maps:get(quzhu, State)]) -- [maps:get(baichi, State)], State).

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
                throw({true, LWinner4});
            _ ->
                ignore
        end,

        case lib_fight:is_third_part_win(State) of
            true->
                throw({true, lib_fight:get_third_part_seat(State)});    
            _->
                ignore
        end, 

        case ShenMinAlive of
            [] ->
                LangrenQiubite = lib_fight:get_langren_qiubite_seat(State),
                LangRenHunxuer1 = lib_fight:get_langren_hunxuer_seat(State),
                SWinner1 = AllLangren ++ LangrenQiubite,
                SWinner2 = SWinner1 ++ LangRenHunxuer1,
                throw({true, SWinner2});
            _ ->
                ignore
        end,
        case lib_fight:get_duty_seat(?DUTY_PINGMIN, State) of
            [] ->
                LangrenQiubite1 = lib_fight:get_langren_qiubite_seat(State),
                LangRenHunxuer2 = lib_fight:get_langren_hunxuer_seat(State),
                PWinner1 = AllLangren ++ LangrenQiubite1,
                PWinner2 = PWinner1 ++ LangRenHunxuer2,
                throw({true, PWinner2});
            _ ->
                ignore
        end,
           
        {false, []}
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
    State#{wait_op_list => [],   %% 等待中的操作
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
           exit_jingzhang => [], %%
           langren_boom => 0,
           show_nigth_result => 0,
           flop_list => [],
           quzhu_op => 0,
           safe_night => 1,         %%平安夜
           safe_day => 1           %%平安日
           }.

notice_state_toupiao_result(IsDraw, Quzhu, TouPiaoResult, State) ->
    notice_xuanju_result(?XUANJU_TYPE_QUZHU, IsDraw, Quzhu, TouPiaoResult, State).  

notice_toupiao_out(0, _) ->
    ignore;

notice_toupiao_out(SeatId, State) ->  
    notice_player_op(?OP_QUZHU, [SeatId], State).

notice_game_status_change(Status, State) ->
    notice_game_status_change(Status, [], State).

notice_game_status_change(Status, AttachData, State) ->
    StatusId = get_status_id(Status),
    Send = #m__fight__game_state_change__s2l{game_status = StatusId,
                                             attach_data = AttachData},
    lib_fight:send_to_all_player(Send, State).

send_fight_result(Winner, State) ->
    DutyList = [#p_duty{seat_id = SeatId,
                        duty_id = DutyId} || 
                        {SeatId, DutyId} <- maps:to_list(maps:get(seat_duty_map, State))],

    #{lover := Lover,
      hunxuer := Hunxuer} = State,
    Send = #m__fight__result__s2l{winner = Winner,
                                  lover = Lover,
                                  hunxuer = Hunxuer,
                                  duty_list = DutyList},
    lib_fight:send_to_all_player(Send, State).

notice_start_fayan(SeatId, State) ->
    Send = #m__fight__notice_fayan__s2l{seat_id = SeatId},
    lib_fight:send_to_all_player(Send, State).

notice_stop_fayan(SeatId, State) ->
    Send = #m__fight__stop_fayan__s2l{seat_id = SeatId},
    lib_fight:send_to_seat(Send, SeatId, State).

is_over(State) ->
    NewState = out_die_player(State),
    {IsOver, _Winner} = get_fight_result(NewState),
    IsOver.

get_online_attach_data(_SeatId, ?DUTY_YUYANJIA, State) ->
    lists:unzip(maps:get(yuyanjia_op, State));

get_online_attach_data(_SeatId, ?DUTY_LANGREN, State) ->
    {lib_fight:get_duty_seat(State), []};

get_online_attach_data(_SeatId, ?DUTY_BAILANG, State) ->
    {lib_fight:get_duty_seat(State), []};

get_online_attach_data(_SeatId, ?DUTY_SHOUWEI, State) ->
    {[maps:get(shouwei, State)], []};

get_online_attach_data(_SeatId, ?DUTY_HUNXUEER, State) ->
    {[maps:get(hunxuer, State)], []};

get_online_attach_data(_, _, _) ->
    [].

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
            state_shouwei
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
            []
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
            20
    end.
