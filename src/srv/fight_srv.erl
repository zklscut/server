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
         state_duty_display/2,
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
-include("log.hrl").
-define(TEST, false).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/4,
         player_op/5,
         player_skill/4,
         player_speak/4,
         chat_input/6,
         print_state/1,
         player_online/1,
         player_offline/1,
         player_leave/2,
         forbid_other_speak/3
         ]).

start_link(RoomId, PlayerList, DutyList, Name) ->
    gen_fsm:start(?MODULE, [RoomId, PlayerList, DutyList, Name, ?MFIGHT], []).

player_op(Pid, PlayerId, Op, OpList, Confirm) ->
    case Pid of
        undefined->
            ignore;
        _->
            gen_fsm:send_event(Pid, {player_op, PlayerId, Op, OpList, Confirm})
    end.

player_speak(Pid, PlayerId, Chat, SpeakType) ->
    case Pid of
        undefined->
            ignore;
        _->
            gen_fsm:send_all_state_event(Pid, {player_chat, Chat, SpeakType, PlayerId})
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
            net_send:send(#m__room__leave_room__s2l{result=1}, PlayerId),
            room_srv:leave_room(lib_player:get_player(PlayerId));
        Pid ->
            gen_fsm:send_all_state_event(Pid, {player_leave, PlayerId})
    end.

forbid_other_speak(Pid, PlayerId, Forbid)->
    case Pid of
        undefined ->
            ignore;
        Pid ->
            gen_fsm:send_all_state_event(Pid, {forbid_other_speak, Forbid, PlayerId})
    end.

chat_input(Pid, PlayerId, IsExpression, Content, ChatType, RoomId)->
    case Pid of
        undefined ->
            Room = lib_room:get_room(RoomId),
            case Room of
                undefined->
                    ignore;
                _->
                    Send = #m__fight__chat_input__s2l{is_expression=IsExpression,
                                                player_id = PlayerId,
                                                chat_type = ChatType,
                                                content = Content
                                                },
                    mod_room:send_to_room(Send, Room)
            end;
        Pid ->
            gen_fsm:send_all_state_event(Pid, {chat_input, IsExpression, Content, ChatType, PlayerId})
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
    notice_duty(NewState, 0),
    notice_game_status_change(start, NewState),
    send_event_inner(start),
    % NextState = 
    %     case maps:get(fight_mod, NewState) of
    %         case 0->

    {ok, state_select_card, NewState}.

state_select_card(start, State)->
    notice_game_status_change(state_select_card, [?OP_SELECT_DUTY], State),
    send_event_inner(wait_op),
    {next_state, state_select_card, State};

state_select_card(wait_op, State)->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, lib_fight:get_op_wait(?OP_SELECT_DUTY, undefined, State)),
    SeatList = lib_fight:get_all_seat(State),
    % SeatList = lib_fight:get_all_seat(undefined),
    DutySelectFun = fun(CurSeatId, CurState)->   
                        case CurSeatId =/= 0 of
                            true->
                                lib_fight:notice_rnd_select_duty(CurSeatId, CurState);
                            _->
                                CurState
                        end
                    end,
    StateNew = lists:foldl(DutySelectFun, State, SeatList),
    StateAfterStartTime = maps:put(duty_select_start_time, util:get_micro_time(), StateNew),
    {next_state, state_select_card, StateAfterStartTime};

state_select_card({player_op, PlayerId, ?OP_SELECT_DUTY, [Duty], _Confirm}, State)->
    %%首先判断是否已经操作过
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    DutySelectSeatList = maps:get(duty_select_seat_list, State),
    NewState = 
    case lists:member(SeatId, DutySelectSeatList) of
        true->
            %%提示已经操作过
            lib_fight:send_to_seat(#m__fight__select_duty__s2l{result = 1, duty=0, seat_id = SeatId}, SeatId, State),
            State;
        _-> 
            DiamondNum = mod_resource:get_num(?RESOURCE_DIAMOND, PlayerId),
            NeedDiamond = b_duty_select_consume:get(Duty),
            case DiamondNum < NeedDiamond of
                true->
                    %%提示金币不够
                    lib_fight:send_to_seat(#m__fight__select_duty__s2l{result = 2, duty=0, seat_id = SeatId}, SeatId, State),
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
    NewState = maps:put(duty_select_over, 1, State),
    {next_state, state_duty_display, NewState};

state_select_card(_IgnoreOP, State)->
    {next_state, state_select_card, State}.

%%身份展示
state_duty_display(start, State)->
    notice_duty(State, 1),
    notice_game_status_change(state_duty_display, State),
    send_event_inner(wait_op),
    {next_state, state_duty_display, State};

state_duty_display(wait_op, State) ->
    StateAfterNotice = notice_duty_dis(State),
    WaitList = lib_fight:get_all_seat(StateAfterNotice),
    StateAfterWait = do_set_wait_op(?OP_DUTY_DIS, WaitList, StateAfterNotice),
    {next_state, state_duty_display, StateAfterWait}; 

state_duty_display(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_duty_display, State};

state_duty_display(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(start),
    {next_state, state_daozei, State};

state_duty_display(_IgnoreOP, State)->
    {next_state, state_duty_display, State}.

%% ====================================================================
%% state_daozei
%% ====================================================================
state_daozei(start, State) ->
    DaozeiSeatList = lib_fight:get_duty_seat(?DUTY_DAOZEI, State),
    QiubiteSeatList = lib_fight:get_duty_seat(?DUTY_QIUBITE, State),
    HunxueerSeatList = lib_fight:get_duty_seat(?DUTY_HUNXUEER, State),
    case  (DaozeiSeatList == []) andalso (QiubiteSeatList == []) andalso (HunxueerSeatList == []) of
        true->
            send_event_inner(start),
            {next_state, state_shouwei, State};
        _->
            send_event_inner(wait_op),
            {next_state, state_daozei, State}
    end;

state_daozei(wait_op, State) ->
    DaozeiSeatList = lib_fight:get_duty_seat(?DUTY_DAOZEI, State),
    QiubiteSeatList = lib_fight:get_duty_seat(?DUTY_QIUBITE, State),
    HunxueerSeatList = lib_fight:get_duty_seat(?DUTY_HUNXUEER, State),
    AttackDataDaozei =
    case DaozeiSeatList of
        []->
            [];
        _->
            %%盗贼的数据以17开始
            [17] ++ maps:get(daozei, State)
    end,
    AttackDataQiubite =
    case QiubiteSeatList of
        []->
            AttackDataDaozei;
        _->
            %%丘比特的数据以18开始
            AttackDataDaozei ++ ([18] ++ (lib_fight:get_alive_seat_list(State) -- QiubiteSeatList))
    end,
    AttackDataHunxueer =
    case HunxueerSeatList of
        []->
            AttackDataQiubite;
        _->
            %%混血儿的数据以19开始
            AttackDataQiubite ++ ([19] ++ (lib_fight:get_alive_seat_list(State) -- HunxueerSeatList))
    end,
    OpSeatList = (DaozeiSeatList ++ QiubiteSeatList) ++ HunxueerSeatList,
    StateAfterPreCommon = notice_player_op(?OP_PRE_COMMON, AttackDataHunxueer, OpSeatList, State),
    {next_state, state_daozei, do_set_wait_op(?OP_PRE_COMMON, OpSeatList, StateAfterPreCommon)};

state_daozei({player_op, PlayerId, ?DUTY_DAOZEI, OpList, Confirm}, State) ->
    {PreState, StateName, CurState} = do_receive_player_op(PlayerId, ?DUTY_DAOZEI, OpList, Confirm, state_daozei, State),
    NewState =
    case Confirm of
        1->
            lib_fight:do_daozei_op(CurState);
        _->
            CurState
    end,
    {PreState, StateName, NewState};

state_daozei({player_op, PlayerId, ?DUTY_QIUBITE, OpList, Confirm}, State) ->
    {PreState, StateName, CurState} = do_receive_player_op(PlayerId, ?DUTY_QIUBITE, OpList, Confirm, state_daozei, State),
    NewState =
    case Confirm of
        1->
            lib_fight:do_qiubite_op(CurState);
        _->
            CurState
    end,
    {PreState, StateName, NewState};

state_daozei({player_op, PlayerId, ?DUTY_HUNXUEER, OpList, Confirm}, State) ->
    {PreState, StateName, CurState} = do_receive_player_op(PlayerId, ?DUTY_HUNXUEER, OpList, Confirm, state_daozei, State),
    NewState =
    case Confirm of
        1->
            lib_fight:do_hunxuer_op(CurState);
        _->
            CurState
    end,
    {PreState, StateName, NewState};

state_daozei(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_daozei, State};

state_daozei(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    StateAfterDaozei = 
        case maps:get(duty_daozei_op, State) of
            1->
                State;
            _->
                lib_fight:do_daozei_op(State)
        end,
    StateAfterQiubite = 
        case maps:get(duty_qiubite_op, StateAfterDaozei) of
            1->
                StateAfterDaozei;
            _->
                lib_fight:do_qiubite_op(StateAfterDaozei)
        end,
    StateAfterHunxueer = 
        case maps:get(duty_hunxuer_op, StateAfterQiubite) of
            1->
                StateAfterQiubite;
            _->
                lib_fight:do_hunxuer_op(StateAfterQiubite)
        end,
    send_event_inner(start),
    {next_state, get_next_game_state(state_daozei), lib_fight:clear_last_op(StateAfterHunxueer)};

state_daozei(_IgnoreOP, State)->
    {next_state, state_daozei, State}.
            
%% ====================================================================
%% state_qiubite
%% ====================================================================
state_qiubite(start, State) ->
    do_duty_state_start(?DUTY_QIUBITE, state_qiubite, State);

state_qiubite(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_QIUBITE, State),
    {next_state, state_qiubite, NewState};

state_qiubite({player_op, PlayerId, Op, [LoverA,LoverB], Confirm} , State) ->
    do_receive_player_op(PlayerId, Op, [LoverA,LoverB], Confirm, state_qiubite, State);

state_qiubite({player_op, _PlayerId, _Op, _OpList, _Confirm}, State) ->
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
    {next_state, get_next_game_state(state_qiubite), NewState};

state_qiubite(_IgnoreOP, State)->
    {next_state, state_qiubite, State}.

%% ====================================================================
%% state_hunxueer
%% ====================================================================
state_hunxueer(start, State) ->
    do_duty_state_start(?DUTY_HUNXUEER, state_hunxueer, State);

state_hunxueer(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_HUNXUEER, State),
    {next_state, state_hunxueer, NewState};

state_hunxueer({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_hunxueer, State);

state_hunxueer(timeout, State) ->
    RandTarger = util:rand_in_list(lib_fight:get_alive_seat_list(State) -- 
                                  lib_fight:get_duty_seat(?DUTY_HUNXUEER, State), 1),
    do_duty_op_timeout(RandTarger, state_hunxueer, State);    

state_hunxueer(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_hunxuer_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_hunxueer), NewState};

state_hunxueer(_IgnoreOP, State)->
    {next_state, state_hunxueer, State}.

%% ====================================================================
%% state_shouwei
%% ====================================================================
state_shouwei(start, State) ->
    % do_duty_state_start(?DUTY_SHOUWEI, state_shouwei, State);
    send_event_inner(wait_op),
    {next_state, state_shouwei, State};

state_shouwei(wait_op, State) ->
    LangRenSeatList = lib_fight:get_duty_seat(?DUTY_LANGREN, State),
    ShouWeiSeatList = lib_fight:get_duty_seat(?DUTY_SHOUWEI, State),
    YuyanjiaSeatList = lib_fight:get_duty_seat(?DUTY_YUYANJIA, State),

    AttachDataLangren = [20] ++ lib_fight:get_alive_seat_list(State),
    AttachDataShouWei =
    case ShouWeiSeatList of
        []->
            AttachDataLangren;
        _->
            AttachDataLangren ++ ([21] ++ (lib_fight:get_alive_seat_list(State) -- [maps:get(shouwei, State)]))
    end,
    AttachDataYuyanjia = 
        case YuyanjiaSeatList of
            []->
                AttachDataShouWei;
            _->
                YuYanJiaOpList = maps:get(yuyanjia_op, State),
                YuYanJiaOpSeatList = [SeatId || {SeatId, _}<-YuYanJiaOpList],
                AttachDataShouWei ++ ([22] ++ (lib_fight:get_alive_seat_list(State) -- (YuyanjiaSeatList ++ YuYanJiaOpSeatList)))
        end,
    OpSeatList = (LangRenSeatList ++ ShouWeiSeatList) ++ YuyanjiaSeatList,
    StateAfterNormalCommon = notice_player_op(?OP_NORMAL_COMMON, AttachDataYuyanjia, OpSeatList, State),    
    {next_state, state_shouwei, do_set_wait_op(?OP_NORMAL_COMMON, OpSeatList, StateAfterNormalCommon)};

state_shouwei({player_op, PlayerId, ?DUTY_LANGREN, OpList, Confirm}, State) ->
    do_receive_player_langren_op(PlayerId, ?DUTY_LANGREN, OpList, Confirm, state_shouwei, State);

state_shouwei({player_op, PlayerId, ?DUTY_SHOUWEI, OpList, Confirm}, State) ->
    {PreState, StateName, CurState} = do_receive_player_op(PlayerId, ?DUTY_SHOUWEI, 
                                                                OpList, Confirm, state_shouwei, State),
    NewState =
    case Confirm of
        1->
            lib_fight:do_shouwei_op(CurState);
        _->
            CurState
    end,
    {PreState, StateName, NewState};

state_shouwei({player_op, PlayerId, ?DUTY_YUYANJIA, OpList, Confirm}, State) ->
    {PreState, StateName, CurState} = do_receive_player_op(PlayerId, ?DUTY_YUYANJIA, 
                                                                OpList, Confirm, state_shouwei, State),
    NewState =
    case Confirm of
        1->
            lib_fight:do_yuyanjia_op(CurState);
        _->
            CurState
    end,
    {PreState, StateName, NewState};

state_shouwei(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_shouwei, State};

state_shouwei(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    StateAfterShouWei = 
        case maps:get(duty_shouwei, State) of
            1->
                State;
            _->
                lib_fight:do_shouwei_op(State)
        end,
    StateAfterYuyanjia = 
        case maps:get(duty_yuyanjia_op, StateAfterShouWei) of
            1->
                StateAfterShouWei;
            _->
                lib_fight:do_yuyanjia_op(StateAfterShouWei)
        end,
    StateAfterLangren = 
        case maps:get(duty_langren_op, StateAfterYuyanjia) of
            1->
                StateAfterYuyanjia;
            _->
                lib_fight:do_langren_op(StateAfterYuyanjia)
        end,
    StateAfterClearOpData = lib_fight:clear_last_op(StateAfterLangren),   
    send_event_inner(start),
    case lib_fight:is_duty_exist(?DUTY_NVWU, StateAfterLangren) of
        false->
            {next_state, get_next_game_state(state_shouwei), lib_fight:do_set_die_list(StateAfterClearOpData)};
        _->
            {next_state, get_next_game_state(state_shouwei), StateAfterClearOpData}
    end;

state_shouwei(_IgnoreOP, State)->
    {next_state, state_shouwei, State}.
            
%% ====================================================================
%% state_langren
%% ====================================================================
state_langren(start, State) ->
    do_duty_state_start(?DUTY_LANGREN, state_langren, State);

state_langren(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_LANGREN, State),
    {next_state, state_langren, NewState};

state_langren({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_langren_op(PlayerId, Op, OpList, Confirm, state_langren, State);

state_langren(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_langren, State};

state_langren(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_langren_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_langren), NewState};

state_langren(_IgnoreOP, State)->
    {next_state, state_langren, State}.
    

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

state_yuyanjia({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_yuyanjia, State);

state_yuyanjia(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_yuyanjia, State};

state_yuyanjia(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_yuyanjia_op(State),
    send_event_inner(start, b_fight_state_over_wait:get(state_yuyanjia)),
    {next_state, get_next_game_state(state_yuyanjia), NewState};

state_yuyanjia(_IgnoreOP, State)->
    {next_state, state_yuyanjia, State}.


%% ====================================================================
%% state_nvwu
%% ====================================================================
state_nvwu(start, State) ->
    do_duty_state_start(?DUTY_NVWU, state_nvwu, State);

state_nvwu(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_NVWU, State),
    {next_state, state_nvwu, NewState};

state_nvwu({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_nvwu, State);

state_nvwu(timeout, State) ->
    Op = [0, 0],
    do_duty_op_timeout(Op, state_nvwu, State);

state_nvwu(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_nvwu_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_nvwu), NewState};

state_nvwu(_IgnoreOP, State)->
    {next_state, state_nvwu, State}.
            


%% ====================================================================
%% state_day
%% ====================================================================
state_day(start, State) ->
    % lib_room:update_room_status(maps:get(room_id, State), 1, maps:get(game_round, State), 1, 1),
    NewState = maps:put(is_night, 0, State),
    StateAfterGameRound = maps:put(game_round, maps:get(game_round, NewState) + 1, NewState),
    notice_game_status_change(state_day, StateAfterGameRound),
    send_event_inner(over, b_fight_state_wait:get(state_day)),
    {next_state, state_day, StateAfterGameRound};

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
    {next_state, NextState, State};

state_day(_IgnoreOP, State)->
    {next_state, state_day, State}.

    
%% ====================================================================
%% state_part_jingzhang
%% ====================================================================
state_part_jingzhang(start, State) ->
    GameRound = maps:get(game_round, State),
    case GameRound of
        2 ->
            case ?TEST of
                true ->
                    fight_test(state_part_jingzhang, State);
                false ->
                    notice_game_status_change(state_part_jingzhang, State),
                    send_event_inner(wait_op, b_fight_state_wait:get(state_part_jingzhang)),
                    {next_state, state_part_jingzhang, State}
            end;
        3 ->
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

state_part_jingzhang({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_part_jingzhang, State);

state_part_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_part_jingzhang, State};
    
state_part_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_part_jingzhang_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_part_jingzhang), NewState};

state_part_jingzhang(_IgnoreOP, State)->
    {next_state, state_part_jingzhang, State}.

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

state_part_fayan({player_op, PlayerId, Op, [0], Confirm}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], Confirm, state_part_fayan, State);


state_part_fayan(timeout, State) ->
    do_fayan_state_timeout(state_part_fayan, State);

state_part_fayan(op_over, State) ->
    do_fayan_state_op_over(state_part_fayan, State);


state_part_fayan(_IgnoreOP, State)->
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
    StateAfterWait = do_set_wait_op(?OP_XUANJU_JINGZHANG, WaitList, StateAfterNotice),

    {next_state, state_xuanju_jingzhang, StateAfterWait};    
    
state_xuanju_jingzhang({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_xuanju_jingzhang, State);

state_xuanju_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_xuanju_jingzhang, State};

state_xuanju_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, XuanjuResult, MaxSeatList, NewState} = lib_fight:do_xuanju_jingzhang_op(State),
    notice_xuanju_jingzhang_result(IsDraw, maps:get(jingzhang, NewState), XuanjuResult, MaxSeatList, NewState),
    case IsDraw of
        true ->
            send_event_inner(start),
            {next_state, state_part_fayan, maps:put(part_jingzhang, MaxSeatList, NewState)};
        false ->  
            StateAfterPartingJingZhang = maps:put(parting_jingzhang, [], NewState), 
            send_event_inner(start),
            {next_state, get_next_game_state(state_xuanju_jingzhang), maps:put(do_police_select, 1, StateAfterPartingJingZhang)}
    end;

state_xuanju_jingzhang(_IgnoreOP, State)->
    {next_state, state_xuanju_jingzhang, State}.     

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


state_night_result(_IgnoreOP, State)->
    {next_state, state_night_result, State}.  

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
    AliveSeatList = lib_fight:get_alive_seat_list(StateAfterDieOp) -- maps:get(die, StateAfterDieOp),
    StateAfterSkillSeat = maps:put(skill_seat, OpSeat, StateAfterDieOp),
    StateAfterOp = notice_player_op(Op, AliveSeatList, [OpSeat], StateAfterSkillSeat),
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

state_someone_die({player_op, PlayerId, Op, OpList, _Confirm}, State) ->
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
    {next_state, NextStateAfterOver, maps:put(skill_die_list, NewSkillDieList, State)};

state_someone_die(_IgnoreOP, State)->
    {next_state, state_someone_die, State}.

%% ====================================================================
%% state_night_death_fayan
%% ====================================================================
state_night_death_fayan(start, State) ->
    DieList = maps:get(die, State),
    case maps:get(game_round, State) of
        2 ->
            %%第一天晚上被杀死的才有遗言
            do_fayan_state_start(lists:sort(DieList), state_night_death_fayan, State);
        _ ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_night_death_fayan), State}
    end;

state_night_death_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_DEATH_FAYAN, state_night_death_fayan, State);

state_night_death_fayan({player_op, PlayerId, Op, [0], Confirm}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], Confirm, state_night_death_fayan, State);


state_night_death_fayan(timeout, State) ->
    do_fayan_state_timeout(state_night_death_fayan, State);

state_night_death_fayan(op_over, State) ->
    do_fayan_state_op_over(state_night_death_fayan, State);

state_night_death_fayan(_IgnoreOP, State)->
    {next_state, state_night_death_fayan, State}.

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

state_jingzhang({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_jingzhang, State);

state_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_jingzhang, State};

state_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_jingzhang_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_jingzhang)),
    {next_state, get_next_game_state(state_jingzhang), NewState};

state_jingzhang(_IgnoreOP, State)->
    {next_state, state_jingzhang, State}.

%% ====================================================================
%% state_fayan
%% ====================================================================
state_fayan(start, State) ->
    NewState = maps:put(wait_quzhu_list, maps:get(fayan_turn, State), State),
    do_fayan_state_start(maps:get(fayan_turn, NewState), state_fayan, NewState);

state_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_FAYAN, state_fayan, State);

state_fayan({player_op, PlayerId, Op, [0], Confirm}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], Confirm, state_fayan, State);

state_fayan(timeout, State) ->
    do_fayan_state_timeout(state_fayan, State);

state_fayan(op_over, State) ->
    do_fayan_state_op_over(state_fayan, State);
    
state_fayan(_IgnoreOP, State)->
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
    AliveList = lib_fight:get_alive_seat_list(State) -- maps:get(die, State),
    JingZhang = maps:get(jingzhang, State),
    StateAfterOp = notice_player_op(?OP_GUIPIAO, AliveList, [JingZhang], State),
    StateAfterWait = do_set_wait_op(?OP_GUIPIAO, [JingZhang], StateAfterOp),
    {next_state, state_guipiao, StateAfterWait}; 

state_guipiao({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_guipiao, State);

state_guipiao(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_guipiao, State};

state_guipiao(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_guipiao_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_guipiao), NewState};

state_guipiao(_IgnoreOP, State)->
    {next_state, state_guipiao, State}.   

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
    
state_toupiao({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_toupiao, State);

state_toupiao(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_toupiao, State};

state_toupiao(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, TouPiaoResult, MaxSelectList, NewState} = lib_fight:do_toupiao_op(State),
    Quzhu = maps:get(quzhu, NewState),
    notice_state_toupiao_result(IsDraw, Quzhu, TouPiaoResult, MaxSelectList, NewState),
    case IsDraw of
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
                            StateAfterDieInfo = maps:put(die_info, maps:get(die_info, StateAfterNoticeDie) ++ [{Quzhu, 
                                ?DIE_TYPE_BOOM, maps:get(game_round, StateAfterNoticeDie), 
                                maps:get(is_night, StateAfterNoticeDie)}], StateAfterNoticeDie),
                            lib_fight:lover_die_judge(Quzhu, StateAfterDieInfo);
                        false->
                            StateAfterBaichi
                    end;
                false->
                    %%客户端根据通知结果判断是否平安日
                    StateAfterNoticeDie = maps:put(day_notice_die, maps:get(day_notice_die, NewState) ++ [Quzhu], NewState),
                    notice_toupiao_out([Quzhu], StateAfterNoticeDie),
                    StateAfterDieInfo = maps:put(die_info, maps:get(die_info, StateAfterNoticeDie) ++ [{Quzhu, 
                                ?DIE_TYPE_BOOM, maps:get(game_round, StateAfterNoticeDie), 
                                maps:get(is_night, StateAfterNoticeDie)}], StateAfterNoticeDie),
                    lib_fight:lover_die_judge(Quzhu, StateAfterDieInfo)
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
    {next_state, NextState, lib_fight:set_skill_die_list(state_toupiao, State)};

state_toupiao(_IgnoreOP, State)->
    {next_state, state_toupiao, State}.  
            
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

state_toupiao_death_fayan({player_op, PlayerId, Op, [0], Confirm}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], Confirm, state_toupiao_death_fayan, State);


state_toupiao_death_fayan(timeout, State) ->
    do_fayan_state_timeout(state_toupiao_death_fayan, State);

state_toupiao_death_fayan(op_over, State) ->
    do_fayan_state_op_over(state_toupiao_death_fayan, State);

state_toupiao_death_fayan(_IgnoreOP, State)->
    {next_state, state_toupiao_death_fayan, State}.  

%% ====================================================================
%% state_day
%% ====================================================================
state_night(start, State) ->
    NewState = out_die_player(State),
    StateAfterClear = clear_night_op(NewState),
    GameRound = maps:get(game_round, StateAfterClear),
    case GameRound > ?FIGHT_MAX_GAME_ROUND of
        true->
            send_event_inner(start),
            lib_fight:send_to_all_player(#m__fight_over_error__s2l{reason = 2, room_id = maps:get(room_id, StateAfterClear)}, StateAfterClear),
            {next_state, state_over, StateAfterClear};
        _->
            lib_room:update_room_status(maps:get(room_id, StateAfterClear), 1, maps:get(game_round, StateAfterClear), 1, 0),
            notice_game_status_change(state_night, [maps:get(game_round, StateAfterClear)], StateAfterClear),
            send_event_inner(over, b_fight_state_wait:get(state_night)),
            NightOpTotalTime = lib_fight:get_night_last_time(StateAfterClear),
            Send = #m__fight__op_timetick__s2l{timetick = NightOpTotalTime, wait_op = ?OP_NIGHT_TICK},
            lib_fight:send_to_all_player(Send, State),
            {next_state, state_night, maps:put(night_start_time, util:get_micro_time(), StateAfterClear)}
    end;

state_night(over, State)->
    send_event_inner(start),
    GameRound = maps:get(game_round, State),
    NextState = 
        case GameRound == 1 of
            true->
                state_daozei;
            false->
                get_next_game_state(state_night)
        end,
    {next_state, NextState, State};

state_night(_IgnoreOP, State)->
    {next_state, state_night, State}.


%% ====================================================================
%% state_fight_over 战斗结束
%% ====================================================================
state_fight_over(start, State) ->
    NewState = out_die_player(State),
    {_, Winner, _VictoryParty, EndType} = get_fight_result(NewState),
    DutyList = [#p_duty{seat_id = SeatId,
                        duty_id = DutyId,
                        player_id = lib_fight:get_player_id_by_seat(SeatId, NewState)} || 
                        {SeatId, DutyId} <- maps:to_list(maps:get(seat_duty_map, NewState))], 

    %%todo:通知战斗信息
    %%send_fight_result(Winner, VictoryParty, NewState),

    notice_game_status_change(state_fight_over, NewState),
    
    send_event_inner(start, b_fight_state_wait:get(state_fight_over)),
    StateAfterMvp = maps:put(mvp_party, Winner, NewState),
    StateAfterCarry = maps:put(carry_party, lib_fight:get_all_seat(StateAfterMvp) -- Winner, StateAfterMvp),
    StateAfterFayanTurn = maps:put(fayan_turn, lib_fight:get_all_seat(StateAfterCarry), StateAfterCarry),
    StateAfterWinner = maps:put(winner, Winner, StateAfterFayanTurn),
    DieInfo = maps:get(die_info, StateAfterWinner),

    lib_fight:send_to_all_player(#m__fight__end_info__s2l{
            duty_list = DutyList,
            die_info = [#p_die_info{seat_id = SeatId, die_type = DieType, game_round = GameRound, is_night = IsNight} || 
                                                    {SeatId, DieType, GameRound, IsNight}<-DieInfo],
            result_type = EndType
        }, StateAfterWinner),

    NextState =
    case lib_fight:is_need_mvp(StateAfterWinner) of
        true->
            Send = #m__fight__over_info__s2l{duty_list = DutyList, winner = Winner, 
                                                dead_list = maps:get(out_seat_list, StateAfterWinner)},
            lib_fight:send_to_all_player(Send, StateAfterWinner),
            state_lapiao_fayan;
        _->
            state_game_over
    end,
    {next_state, NextState, StateAfterWinner};

state_fight_over(_IgnoreOP, State)->
    {next_state, state_fight_over, State}.

%%拉票发言环节
state_lapiao_fayan(start, State) ->
    do_fayan_state_start(maps:get(fayan_turn, State), state_lapiao_fayan, State);

state_lapiao_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_LAPIAO_FAYAN, state_lapiao_fayan, State);

state_lapiao_fayan({player_op, PlayerId, Op, [0], Confirm}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], Confirm, state_lapiao_fayan, State);

state_lapiao_fayan(timeout, State) ->
    do_fayan_state_timeout(state_lapiao_fayan, State);

state_lapiao_fayan(op_over, State) ->
    do_fayan_state_op_over(state_lapiao_fayan, State);

state_lapiao_fayan(_IgnoreOP, State)->
    {next_state, state_lapiao_fayan, State}.

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
    
state_toupiao_mvp({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_toupiao_mvp, State);

state_toupiao_mvp(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_toupiao_mvp, State};

state_toupiao_mvp(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {_IsDraw, ResultList, MaxSeatList} = lib_fight:do_toupiao_mvp_op(State),
    Mvp =
    case length(MaxSeatList) of
        0->
            0;
        1->
            hd(MaxSeatList);
        _->
            lib_fight:get_max_luck_seat(MaxSeatList, State)
    end,
    StateAfterMvp = maps:put(mvp, Mvp, State),
    notice_state_toupiao_mvp_result(false, Mvp, ResultList, MaxSeatList, StateAfterMvp),
    send_event_inner(wait_over, b_fight_state_over_wait:get(state_toupiao_mvp)),
    {next_state, state_toupiao_mvp, StateAfterMvp};

    % {IsDraw, TouPiaoResult, MaxSelectList, NewState} = lib_fight:do_toupiao_mvp_op(State),
    % Mvp = maps:get(mvp, NewState),
    % case IsDraw of
    %     true ->
    %         notice_state_toupiao_mvp_result(IsDraw, Mvp, TouPiaoResult, MaxSelectList, NewState),
    %         StateAfterMvpParty = maps:put(mvp_party, MaxSelectList, NewState),
    %         send_event_inner(start, b_fight_state_over_wait:get(state_toupiao_mvp)),
    %         {next_state, state_lapiao_fayan, maps:put(fayan_turn, MaxSelectList, StateAfterMvpParty)};
    %     false ->   
    %         %%临时6秒
    %         SelectMvp = 
    %         case Mvp =/= 0 of
    %             true->
    %                 Mvp;
    %             _->
    %                 %%安装魅力值高低选择一个(如果魅力值有相同的(?是否随机一个))
    %                 %%lib_fight:get_max_luck_seat(maps:get(mvp_party, NewState), NewState)
    %                 lib_fight:get_max_luck_seat(maps:get(mvp_party, NewState), NewState)
    %         end,
    %         notice_state_toupiao_mvp_result(IsDraw, SelectMvp, TouPiaoResult, MaxSelectList, NewState),
    %         StateAfterMvp = maps:put(mvp, SelectMvp, NewState),
    %         send_event_inner(wait_over, b_fight_state_over_wait:get(state_toupiao_mvp)),
    %         {next_state, state_toupiao_mvp, StateAfterMvp}
    % end;

state_toupiao_mvp(wait_over, State)->
    send_event_inner(start),
    {next_state, state_toupiao_carry, State};

state_toupiao_mvp(_IgnoreOP, State)->
    {next_state, state_toupiao_mvp, State}.

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
    
state_toupiao_carry({player_op, PlayerId, Op, OpList, Confirm}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, Confirm, state_toupiao_carry, State);

state_toupiao_carry(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_toupiao_carry, State};

state_toupiao_carry(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {_IsDraw, ResultList, MaxSeatList} = lib_fight:do_toupiao_carry_op(State),
    Carry =
    case length(MaxSeatList) of
        0->
            0;
        1->
            hd(MaxSeatList);
        _->
            lib_fight:get_max_luck_seat(MaxSeatList, State)
    end,
    StateAfterCarry = maps:put(carry, Carry, State),
    notice_state_toupiao_carry_result(false, Carry, ResultList, MaxSeatList, StateAfterCarry),
    send_event_inner(wait_over, b_fight_state_over_wait:get(state_toupiao_carry)),
    {next_state, state_toupiao_carry, StateAfterCarry};

    % {IsDraw, TouPiaoResult, MaxSelectList, NewState} = lib_fight:do_toupiao_carry_op(State),
    % Carry = maps:get(carry, NewState),
    % case IsDraw of
    %     true ->
    %         notice_state_toupiao_carry_result(IsDraw, Carry, TouPiaoResult, MaxSelectList, NewState),
    %         StateAfterMvpParty = maps:put(carry_party, MaxSelectList, NewState),
    %         send_event_inner(start, b_fight_state_over_wait:get(state_toupiao_carry)),
    %         {next_state, state_lapiao_fayan, maps:put(fayan_turn, MaxSelectList, StateAfterMvpParty)};
    %     false ->   
    %         %%临时6秒
    %         SelectCarry = 
    %         case Carry =/= 0 of
    %             true->
    %                 Carry;
    %             _->
    %                 %%安装魅力值高低选择一个(如果魅力值有相同的(?是否随机一个))
    %                 %%lib_fight:get_max_luck_seat(maps:get(mvp_party, NewState), NewState)
    %                 lib_fight:get_max_luck_seat(maps:get(carry_party, NewState), NewState)
    %         end,
    %         notice_state_toupiao_carry_result(IsDraw, SelectCarry, TouPiaoResult, MaxSelectList, NewState),
    %         StateAfterCarry = maps:put(carry, SelectCarry, NewState),
    %         send_event_inner(wait_over, b_fight_state_over_wait:get(state_toupiao_carry)),
    %         {next_state, state_toupiao_carry, StateAfterCarry}
    % end;

state_toupiao_carry(wait_over, State)->
    send_event_inner(start),
    {next_state, state_game_over, State};

state_toupiao_carry(_IgnoreOP, State)->
    {next_state, state_toupiao_carry, State}.

%% ====================================================================
%% 游戏结束
%% ====================================================================
state_game_over(start, State) ->
    lager:info("state_game_over1111111111111111"),
    NewState = out_die_player(State),
    {_, Winner, VictoryParty, _EndType} = get_fight_result(NewState),
    send_fight_result(Winner, VictoryParty, NewState),
    send_event_inner(start, b_fight_state_wait:get(state_fight_over)),
    {next_state, state_over, NewState};

state_game_over(_IgnoreOP, State)->
    {next_state, state_game_over, State}.


%% ====================================================================
%% state_over
%% ====================================================================

state_over(start, State) ->
    lib_fight:fight_over_handle(State),
    {stop, normal, maps:put(normal_exit, 1, State)};

state_over(_IgnoreOP, State)->
    {next_state, state_over, State}.

state_name(_Event, _From, StateData) ->
    Reply = next_state,
    {reply, Reply, state_name, StateData}.

handle_event({skill, _PlayerId, ?OP_SKILL_END_FIGHT, _OpList}, _StateName, State) ->
    send_event_inner(start),
    {next_state, state_over, State};

handle_event({skill, PlayerId, Op, OpList}, StateName, State) ->
    try 
        AliveList = lib_fight:get_alive_seat_list(State) -- maps:get(die, State),
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
        case lists:member(SeatId, AliveList) of
            false->
                throw(?ERROR);
            _->
                ignore
        end,
        assert_skill_legal(SeatId, Op, OpList, StateName, State),
        NewState = lib_fight:do_skill(PlayerId, Op, OpList, State),
        NextState = get_skill_next_state(Op, StateName, State),
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

handle_event({player_chat, Chat, SpeakType, PlayerId}, StateName, State)->
    lib_fight:do_send_fayan(PlayerId, Chat, SpeakType, State),
    {next_state, StateName, State};

handle_event({player_online, PlayerId}, StateName, State) ->
    OfflineList = maps:get(offline_list, State),
    NewOfflineList = OfflineList -- [PlayerId],
    NewState =  maps:put(offline_list, NewOfflineList, State),
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, NewState),
    DutyId = lib_fight:get_duty_by_seat(SeatId, NewState),
    Round = maps:get(game_round, NewState),
    _GameState = maps:get(game_state, NewState),
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
    OpUseTime = maps:get(op_timer_use_dur, NewState),
    IsNight = maps:get(is_night, NewState),
    DutySelectOver = maps:get(duty_select_over, NewState),
    DutySelectStartTime = maps:get(duty_select_start_time, NewState),
    DutySelectTotalTime = lib_fight:get_op_wait(?OP_SELECT_DUTY, undefined, NewState),
    SeatRndInfo = maps:get(seat_rnd_info, NewState),
    FightMode = maps:get(fight_mod, NewState),
    OwnRndInfo = maps:get(SeatId, SeatRndInfo, []),
    DutySelectLastTime = util:get_micro_time() - DutySelectStartTime,
    DutySelectList = maps:get(duty_select_seat_list, NewState),
    NightStartTime = maps:get(night_start_time, NewState),
    BaiLangList = lib_fight:get_duty_seat(false, ?DUTY_BAILANG, NewState),
    DutySelectLeftTime = 
    case DutySelectStartTime > 0 andalso (DutySelectTotalTime - DutySelectLastTime) > 0 of
        true->
            DutySelectTotalTime - DutySelectLastTime;
        _->
            0
    end,
    NightOpLeftTime = 
        case IsNight of
            1->
                lib_fight:get_night_last_time(NewState) - (util:get_micro_time() - NightStartTime);
            _->
                0
        end,
    {AttachData1, AttachData2} = get_online_attach_data(SeatId, DutyId, NewState),
    Send = #m__fight__online__s2l{duty = DutyId,
                                  fight_info = lib_fight:get_p_fight(NewState),
                                  seat_id = SeatId,
                                  game_status = get_status_id(StateName),
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
                                  parting_jingzhang = PartingJingZhang -- ExitJingZhang,
                                  duty_select_over = DutySelectOver,
                                  duty_select_time = DutySelectLeftTime,
                                  duty_select_info = OwnRndInfo,
                                  is_night = IsNight,
                                  speak_forbid_info = maps:get(forbid_speak_data, NewState),
                                  game_round = maps:get(game_round, NewState),
                                  fight_mode = FightMode,
                                  bailang_list = BaiLangList,
                                  night_op_left_time = NightOpLeftTime,
                                  duty_select_seat_list = DutySelectList
                                  },
    net_send:send(Send, PlayerId),

    %%刷新离线列表
    SendOffline = #m__fight__offline__s2l{
                       offline_list = [lib_fight:get_seat_id_by_player_id(OffPlayerId, NewState)||OffPlayerId <- NewOfflineList]  
                    },
    lib_fight:send_to_all_player(SendOffline, NewState, [PlayerId]),

    StateAfterTimeUpdate = player_online_offline_wait_op_time_update(SeatId, NewState),
    {next_state, StateName, StateAfterTimeUpdate};

handle_event({forbid_other_speak, Forbid, PlayerId}, StateName, State) ->
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    GameGround = maps:get(game_round, State),
    ForbidInfo = [get_status_id(StateName), GameGround, SeatId, Forbid],
    Send = #m__fight__forbid_other_speak__s2l{forbid_info=ForbidInfo},
    lib_fight:send_to_all_player(Send, State),
    {next_state, StateName, maps:put(forbid_speak_data, ForbidInfo, State)};

handle_event({chat_input, IsExpression, Content, ChatType, PlayerId}, StateName, State) ->
    Send = #m__fight__chat_input__s2l{is_expression=IsExpression,
                                                player_id = PlayerId,
                                                chat_type = ChatType,
                                                content = Content
                                                },
    case ChatType of
        0->
            lib_fight:send_to_all_player(Send, State);
        1->
            LangRenList = lib_fight:get_duty_seat(?DUTY_LANGREN, false, State),
            [lib_fight:send_to_seat(Send, SeatId, State) || SeatId <- LangRenList];
        2->
            DieList = maps:get(out_seat_list, State) ++ maps:get(day_notice_die, State),
            [lib_fight:send_to_seat(Send, SeatId, State) || SeatId <- DieList];
        _->
            ignore
    end,
    {next_state, StateName, State};

handle_event({player_offline, PlayerId}, StateName, State) ->
    OfflineList = maps:get(offline_list, State),
    NewOfflineList = util:add_element_single(PlayerId, OfflineList),
    NewState =  maps:put(offline_list, NewOfflineList, State),
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    Send = #m__fight__offline__s2l{
                       offline_list = [lib_fight:get_seat_id_by_player_id(OffPlayerId, NewState)||OffPlayerId <- NewOfflineList]  
                    },
    lib_fight:send_to_all_player(Send, NewState),
    StateAfterTimeUpdate = player_online_offline_wait_op_time_update(SeatId, NewState),
    case lib_fight:is_all_alive_player_not_in(StateAfterTimeUpdate) of
        true->
            lib_fight:send_to_all_player(#m__fight_over_error__s2l{reason = 1,
                                                                    room_id = maps:get(room_id, StateAfterTimeUpdate)
                                                                    }, StateAfterTimeUpdate),
            cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
            send_event_inner(start),
            {next_state, state_over, StateAfterTimeUpdate};
        _->
            {next_state, StateName, StateAfterTimeUpdate}
    end;

handle_event({player_leave, PlayerId}, StateName, State) ->
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    DieList = maps:get(out_seat_list, State) ++ maps:get(day_notice_die, State),

    
    % case lists:member(SeatId, DieList) of
    %     false->
    %         lib_fight:send_to_seat(#m__room__leave_room__s2l{result=2}, SeatId, State),
    %         State;
    %     _->
    case lists:member(SeatId, DieList) of
        false->
            case maps:get(room_id, State) > 0 of
                true->
                    % 扣除人气
                    mod_player:handle_decrease(?RESOURCE_LUCK, ?FORCE_LEAVE_SUB_LUCK, undefined, PlayerId);
                _->
                    % 扣除荣耀值
                    mod_player:handle_decrease(?RESOURCE_RANK_SCORE, ?FORCE_LEAVE_SUB_RANK_SCORE, undefined, PlayerId)
            end;
        _->
            ignore
    end,

    lib_fight:send_to_seat(#m__room__leave_room__s2l{result=1}, SeatId, State),
    room_srv:leave_room(lib_player:get_player(PlayerId)),
    NewLeavePlayerList = maps:get(leave_player, State) ++ [PlayerId],
    NewState = maps:put(leave_player, NewLeavePlayerList, State),
    Send = #m__fight__leave__s2l{
                       leave_list = [lib_fight:get_seat_id_by_player_id(LeavePlayerId, NewState)
                                                                    ||LeavePlayerId <- NewLeavePlayerList]   
                    },
    lib_fight:send_to_all_player(Send, NewState),
    StateAfterLeave =  player_online_offline_wait_op_time_update(SeatId, NewState),
    % end,

    %%判断活着的人是否都离线
    case lib_fight:is_all_alive_player_not_in(StateAfterLeave) of
        true->
            lib_fight:send_to_all_player(#m__fight_over_error__s2l{reason = 1,
                                                                    room_id = maps:get(room_id, StateAfterLeave)
                                                                    }, StateAfterLeave),
            cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
            send_event_inner(start),
            {next_state, state_over, StateAfterLeave};
        _->
            {next_state, StateName, StateAfterLeave}
    end;

handle_event(print_state, StateName, StateData) ->
    {next_state, StateName, StateData}.

handle_sync_event(_Event, _From, StateName, StateData) ->
    Reply = ok,
    {reply, Reply, StateName, StateData}.

handle_info(_Info, StateName, StateData) ->
    {next_state, StateName, StateData}.

terminate(_Reason, _StateName, StateData) ->
    case maps:get(normal_exit, StateData) of
        0->
            lib_fight:send_to_all_player(#m__fight_over_error__s2l{reason = 3,
                                                                    room_id = maps:get(room_id, StateData)
                                                                    }, StateData),
            lib_fight:fight_over_handle(StateData);
        _->
            ignore
    end,
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

notice_duty(State, DutyValid) ->
    SeatDutyMap = maps:get(seat_duty_map, State),
    FightInfo = lib_fight:get_p_fight(State),
    FunNotice = 
        fun(SeatId) ->
            Duty = maps:get(SeatId, SeatDutyMap),
            Send = #m__fight__notice_duty__s2l{duty = Duty,
                                               seat_id = SeatId,
                                               fight_info = FightInfo,
                                               fight_mode = maps:get(fight_mod, State),
                                               duty_valid = DutyValid
                                               },
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, maps:keys(SeatDutyMap)),
    case DutyValid of
        0->
            ignore;
        _->
            LangRenList = lib_fight:get_duty_seat(?DUTY_LANGREN, false, State),
            SendLangRenList = #m__fight__notice_langren__s2l{langren_list=LangRenList, 
                                bailang_list = lib_fight:get_duty_seat(false, ?DUTY_BAILANG, State)},
            [lib_fight:send_to_seat(SendLangRenList, LangRenSeatId, State) || LangRenSeatId<-LangRenList]
    end.
    

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
    SeatIdList = lib_fight:get_duty_seat(Duty, State),
    StateAfterOp = notice_player_op(Duty, SeatIdList, State),
    do_set_wait_op(Duty, SeatIdList, StateAfterOp).

do_duty_op_timeout(OpList, StateName, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    SeatId = hd(maps:get(wait_op_list, State)),
    StateAfterLogOp = do_log_op(SeatId, OpList, State),
    {_, StateAfterWaitOp} = do_remove_wait_op(SeatId, 1, StateAfterLogOp),
    send_event_inner(op_over),
    {next_state, StateName, StateAfterWaitOp}.

do_receive_player_op(PlayerId, Op, OpList, Confirm, StateName, State) ->
    try
        assert_op_in_wait(PlayerId, State),
        assert_op_legal(Op, StateName),
        assert_op_fit(Op, OpList, State),
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
        StateAfterLogOp = do_log_op(SeatId, OpList, State),
        {IsWaitOver, StateAfterWaitOp} = do_remove_wait_op(SeatId, Confirm, StateAfterLogOp),
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

do_receive_player_langren_op(PlayerId, Op, OpList, Confirm, StateName, State) ->
    try
        assert_op_in_wait(PlayerId, State),
        assert_op_legal(Op, StateName),
        assert_op_fit(Op, OpList, State),
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
        StateAfterLogOp = do_log_op(SeatId, OpList, State),
        {_AllSame, AllOpData} = lib_fight:get_langren_dync_data(StateAfterLogOp),
        LangRenList = lib_fight:get_duty_seat(?DUTY_LANGREN, StateAfterLogOp),
        {IsWaitOver, StateAfterWaitOp} = do_remove_wait_op(SeatId, Confirm, StateAfterLogOp),
        % {IsWaitOver, StateAfterWaitOp} =
        % case AllSame of
        %     true->
        %         do_remove_wait_op_list(LangRenList, 1, StateAfterLogOp);
        %     _->
        %         {false, StateAfterLogOp}
        % end,
        Send = #m__fight__dync_langren_op_data__s2l{op_data = AllOpData},
        [lib_fight:send_to_seat(Send, LangRenSeatId, StateAfterWaitOp) || LangRenSeatId<-LangRenList],

        % StateAfterLangrenOP =
        % case AllSame of
        %     true ->
        %         case maps:get(duty_langren_op, StateAfterWaitOp) of
        %             1->
        %                 StateAfterWaitOp;
        %             _->
        %                 lib_fight:do_langren_op(StateAfterWaitOp)
        %         end;
        %     _ ->
        %         StateAfterWaitOp
        % end,

        case IsWaitOver of
            true->
                send_event_inner(op_over);
            _->
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

% do_receive_fayan(PlayerId, Chat, State) ->
%     try
%         assert_op_in_wait(PlayerId, State),
%         lib_fight:do_send_fayan(PlayerId, Chat, State)
%     catch
%         throw:ErrCode ->
%             net_send:send_errcode(ErrCode, PlayerId)
%     end.       

notice_player_op(?DUTY_LANGREN, SeatList, State) ->
    notice_player_op(?DUTY_LANGREN, lib_fight:get_alive_seat_list(State), SeatList, State);

notice_player_op(?DUTY_YUYANJIA, SeatList, State) ->
    AliveSeatList = lib_fight:get_alive_seat_list(State),
    YuYanJiaOpList = maps:get(yuyanjia_op, State),
    YuYanJiaOpSeatList = [SeatId || {SeatId, _}<-YuYanJiaOpList],
    notice_player_op(?DUTY_YUYANJIA, AliveSeatList -- (SeatList ++ YuYanJiaOpSeatList), SeatList, State);

notice_player_op(?DUTY_DAOZEI, SeatList, State) ->
    notice_player_op(?DUTY_DAOZEI, maps:get(daozei, State), SeatList, State);

notice_player_op(?DUTY_SHOUWEI, SeatList, State) ->
    AliveSeatList = lib_fight:get_alive_seat_list(State),
    notice_player_op(?DUTY_SHOUWEI, AliveSeatList -- [maps:get(shouwei, State)], SeatList, State);

notice_player_op(?DUTY_QIUBITE, SeatList, State) ->
    AliveSeatList = lib_fight:get_alive_seat_list(State),
    notice_player_op(?DUTY_QIUBITE, AliveSeatList -- SeatList, SeatList, State);

notice_player_op(?DUTY_HUNXUEER, SeatList, State) ->
    AliveSeatList = lib_fight:get_alive_seat_list(State),
    notice_player_op(?DUTY_HUNXUEER, AliveSeatList -- SeatList, SeatList, State);

notice_player_op(?DUTY_LIEREN, SeatList, State) ->
    AliveSeatList = lib_fight:get_alive_seat_list(State),
    notice_player_op(?DUTY_LIEREN, AliveSeatList -- SeatList, SeatList, State);

notice_player_op(?DUTY_NVWU, SeatList, State) ->
    notice_player_op(?DUTY_NVWU, [lists:sum(maps:get(nvwu_left, State))] ++ [maps:get(langren, State)], SeatList, State);

notice_player_op(?OP_XUANJU_JINGZHANG, SeatList, State) ->
    notice_player_op(?OP_XUANJU_JINGZHANG, maps:get(part_jingzhang, State), SeatList, State);

notice_player_op(Op, SeatList, State) ->
    notice_player_op(Op, SeatList, SeatList, State).

notice_player_op(Op, AttachData, SeatList, State) ->
    WaitTime = lib_fight:get_op_wait(Op, SeatList, State),
    UseWaitTime = 
    case lib_fight:is_offline_all(SeatList, State) of
        true->
            lib_fight:get_op_wait(?OP_SKILL_OFFLINE, undefined, State);
        _->
            WaitTime
    end,
    lager:info("state_duty_display ~p", [{Op, WaitTime}]),
    StateAfterWaitTime =
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
    end,
    Send = #m__fight__notice_op__s2l{op = Op,
                                     attach_data = AttachData},
    FunNotice = 
        fun(SeatId) ->
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, SeatList),
    StateAfterWaitTime.

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

do_remove_wait_op(SeatId, Confirm, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    WaipOpListAfterConfirm = 
        case Confirm of
            0->
                WaitOpList;
            _->
                WaitOpList -- [SeatId]
        end,
    NewWaitOpList = wait_op_list_all_offline_players_timeout(WaipOpListAfterConfirm, State),
    NewState = 
    case NewWaitOpList of
        []->
            maps:put(wait_op, 0, State);
        _->
            State
    end,
    {NewWaitOpList == [], maps:put(wait_op_list, NewWaitOpList, NewState)}.

% do_remove_wait_op_list(SeatList, Confirm, State)->
%     WaitOpList = maps:get(wait_op_list, State),
%     WaipOpListAfterConfirm = 
%         case Confirm of
%             0->
%                 WaitOpList;
%             _->
%                 WaitOpList -- SeatList
%         end,
%     NewWaitOpList = wait_op_list_all_offline_players_timeout(WaipOpListAfterConfirm, State),
%     NewState = 
%     case NewWaitOpList of
%         []->
%             maps:put(wait_op, 0, State);
%         _->
%             State
%     end,
%     {NewWaitOpList == [], maps:put(wait_op_list, NewWaitOpList, NewState)}.

notice_jingxuan_jingzhang(State) ->
    notice_player_op(?OP_PART_JINGZHANG, lib_fight:get_alive_seat_list(State), State).

notice_xuanju_result(XaunJuType, IsDraw, XuanjuSeat, XuanJuResult, MaxList, State) ->
    PResutList = [#p_xuanju_result{seat_id = SeatId, 
                                   select_list = SelectList} || {SeatId, SelectList} <- XuanJuResult],
    Send = #m__fight__xuanju_result__s2l{xuanju_type = XaunJuType,
                                         result_list = PResutList,
                                         result_id = XuanjuSeat,
                                         max_list = MaxList,
                                         is_draw = util:conver_bool_to_int(IsDraw)},
    lib_fight:send_to_all_player(Send, State).

notice_xuanju_jingzhang(State) ->
    ExitJingZhang = maps:get(exit_jingzhang, State),
    PartXuanjuList = maps:get(part_jingzhang, State),
    notice_player_op(?OP_XUANJU_JINGZHANG, PartXuanjuList, 
        (lib_fight:get_alive_seat_list(State) -- PartXuanjuList) -- ExitJingZhang, State).

notice_xuanju_jingzhang_result(IsDraw, JingZhang, XuanjuResult, MaxList, State) ->
    notice_xuanju_result(?XUANJU_TYPE_JINGZHANG, IsDraw, JingZhang, XuanjuResult, MaxList, State).

notice_toupiao(State) ->
    notice_toupiao([], State).

notice_toupiao(_MaxSelectList, State) ->
    AliveList = lib_fight:get_alive_seat_list(State),
    WaitQuzhuList = maps:get(wait_quzhu_list, State),
    notice_player_op(?OP_TOUPIAO, WaitQuzhuList -- maps:get(die, State), ((AliveList -- 
                                                 [maps:get(baichi, State)]) -- maps:get(die, State)), State).

notice_duty_dis(State) ->
    notice_player_op(?OP_DUTY_DIS, [], lib_fight:get_all_seat(State), State).

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
    PingMinAlive = lib_fight:get_duty_seat(?DUTY_PINGMIN, State),
    % lists:flatten([lib_fight:get_duty_seat(DutyId, State) || DutyId <- ?DUTY_LIST_SHENMIN]),
    AllLangren = lib_fight:get_duty_seat(?DUTY_LANGREN, false, State),
    AllSeat = lib_fight:get_all_seat(State),
    try

        FightMode = maps:get(fight_mod, State),
        case FightMode of
            ?FIGHT_MODE_SIMPLE->
                case LangrenAlive of
                    []->
                        throw({true, AllSeat -- AllLangren, 0, ?FIGHT_END_TYPE_LANGREN_DIE_ALL});
                    _->
                        ignore
                end,
                case length(LangrenAlive) > length(ShenMinAlive ++ PingMinAlive) of
                    true->
                        throw({true, AllLangren, 1, ?FIGHT_END_TYPE_LANGREN_NUM_BIG});
                    _->
                        ignore
                end,
                throw({false, [], 0, 0});
            _->
                ignore
        end,

        case LangrenAlive of
            [] ->
                LangRenQiubite = lib_fight:get_langren_qiubite_seat(State),
                ThirdPartQiubite = lib_fight:get_third_part_qiubite_seat(State),
                LangRenHunxuer = lib_fight:get_langren_hunxuer_seat(State),
                LWinner1 = AllSeat -- AllLangren,
                LWinner2 = LWinner1 -- LangRenQiubite,
                LWinner3 = LWinner2 -- ThirdPartQiubite,
                LWinner4 = LWinner3 -- LangRenHunxuer,
                throw({true, LWinner4, 0, ?FIGHT_END_TYPE_LANGREN_DIE_ALL});
            _ ->
                ignore
        end,

        case lib_fight:is_third_part_win(State) of
            true->
                throw({true, lib_fight:get_third_part_seat(State), 2, ?FIGHT_END_TYPE_THIRD_PART});    
            _->
                ignore
        end, 

        case ShenMinAlive of
            [] ->
                LangrenQiubite = lib_fight:get_langren_qiubite_seat(State),
                LangRenHunxuer1 = lib_fight:get_langren_hunxuer_seat(State),
                SWinner1 = AllLangren ++ LangrenQiubite,
                SWinner2 = SWinner1 ++ LangRenHunxuer1,
                throw({true, SWinner2, 1, ?FIGHT_END_TYPE_SHENMIN_DIE_ALL});
            _ ->
                ignore
        end,
        case PingMinAlive of
            [] ->
                LangrenQiubite1 = lib_fight:get_langren_qiubite_seat(State),
                LangRenHunxuer2 = lib_fight:get_langren_hunxuer_seat(State),
                PWinner1 = AllLangren ++ LangrenQiubite1,
                PWinner2 = PWinner1 ++ LangRenHunxuer2,
                throw({true, PWinner2, 1, ?FIGHT_END_TYPE_PINGMIN_DIE_ALL});
            _ ->
                ignore
        end,
           
        {false, [], 0, 0}
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
           % game_round => maps:get(game_round, State) + 1,
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
           is_night => 1,
           safe_night => 1,         %%平安夜
           safe_day => 1,           %%平安日
           duty_daozei_op => 0,
           duty_qiubite_op => 0,
           duty_hunxuer_op => 0,
           duty_langren_op => 0,
           duty_yuyanjia_op => 0,
           duty_shouwei => 0
           }.

notice_state_toupiao_result(IsDraw, Quzhu, TouPiaoResult, MaxList, State) ->
    notice_xuanju_result(?XUANJU_TYPE_QUZHU, IsDraw, Quzhu, TouPiaoResult, MaxList, State).  

notice_state_toupiao_mvp_result(IsDraw, Mvp, TouPiaoResult, MaxList, State) ->
    notice_xuanju_result(?XUANJU_TYPE_MVP, IsDraw, Mvp, TouPiaoResult, MaxList, State).  

notice_state_toupiao_carry_result(IsDraw, Carry, TouPiaoResult, MaxList, State) ->
    notice_xuanju_result(?XUANJU_TYPE_CARRY, IsDraw, Carry, TouPiaoResult, MaxList, State). 

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
    ThirdList = 
    case lib_fight:is_third_part_win(State) orelse lib_fight:get_third_part_qiubite_seat(State) of
        true->
            lib_fight:get_third_part_seat(State);
        _->
            []
    end,
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
    AverageRank = maps:get(average_rank, State),
    RankChange = 
        case maps:get(room_id, State) of
            0->
                CurRank = mod_resource:get_num(?RESOURCE_RANK_SCORE, PlayerId),
                case lists:member(ResultSeatId, Winner) of
                    true->
                        lib_match:compute_rank(win, CurRank, AverageRank) - CurRank;
                    _->
                        lib_match:compute_rank(lose, CurRank, AverageRank) - CurRank
                end;
            _->
                0
        end,
    
    case RankChange =/= 0 of
        true->
            mod_player:handle_increase(?RESOURCE_RANK_SCORE, RankChange, ?LOG_ACTION_FIGHT, PlayerId);
        _->
            ignore
    end,

    lib_fight:send_to_seat(#m__fight__result__s2l{
                                  winner = Winner,
                                  lover = Lover,
                                  third_list = ThirdList,
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
                                  room_id = maps:get(room_id, State),
                                  rank_add = RankChange,
                                  own_seat_id = ResultSeatId
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
                        duty_id = DutyId,
                        player_id = lib_fight:get_player_id_by_seat(SeatId, State)} || 
                        {SeatId, DutyId} <- maps:to_list(maps:get(seat_duty_map, State))], 
    LeavePlayerList = maps:get(leave_player, State),
    [fight_result_op(Winner, VictoryParty, DutyList, ResultSeatId, ResultDutyId, State)
                 || {ResultSeatId, ResultDutyId} <- maps:to_list(maps:get(seat_duty_map, State)),
                     not lists:member(ResultSeatId, LeavePlayerList)],

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
    {IsOver, _Winner, _VictoryParty, _EndType} = get_fight_result(NewState),
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
                        player_id = lib_fight:get_player_id_by_seat(SeatId, State),
                        duty_id = DutyId} || 
                        {SeatId, DutyId} <- maps:to_list(maps:get(seat_duty_map, State))]
    end.

get_next_game_state(GameState) ->
    case GameState of
        state_daozei ->
            state_shouwei;
        state_qiubite ->
            state_hunxueer;
        state_hunxueer ->
            state_shouwei;
        state_shouwei ->
            state_nvwu;
        state_langren ->
            state_nvwu;
        state_nvwu ->
            state_day;
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
            state_daozei;
        state_duty_display->
            state_daozei
    end.

get_state_legal_op(GameState) ->
    case GameState of
        state_daozei ->
            [?DUTY_DAOZEI, ?DUTY_QIUBITE, ?DUTY_HUNXUEER];
        state_qiubite ->
            [?DUTY_QIUBITE];
        state_hunxueer ->
            [?DUTY_HUNXUEER];
        state_shouwei ->
            [?DUTY_LANGREN, ?DUTY_SHOUWEI, ?DUTY_YUYANJIA];% [?DUTY_SHOUWEI];
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
            [?OP_SELECT_DUTY];
        state_duty_display->
            [?OP_DUTY_DIS]
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
            25;
        state_duty_display ->
            26
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