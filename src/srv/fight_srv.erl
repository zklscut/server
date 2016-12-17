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
         state_yuyanjia/2]).

-include("fight.hrl").
-include("errcode.hrl").
-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/2,
         player_op/3,
         print_state/1]).

start_link(RoomId, PlayerList) ->
    gen_fsm:start(?MODULE, [RoomId, PlayerList, ?MFIGHT], []).

player_op(Pid, PlayerId, Op) ->
    gen_fsm:send_event(Pid, {player_op, PlayerId, Op}).

print_state(Pid) ->
    gen_fsm:send_all_state_event(Pid, print_state).


%% ====================================================================
%% Behavioural functions
%% ====================================================================

init([RoomId, PlayerList, State]) ->
    lib_room:update_fight_pid(RoomId, self()),
    NewState = lib_fight:init(RoomId, PlayerList, State),
    notice_duty(NewState),
    send_event_inner(start),
    {ok, state_daozei, NewState}.

%% ====================================================================
%% state_daozei
%% ====================================================================
state_daozei(start, State) ->
    do_duty_state_start(?DUTY_DAOZEI, state_daozei, State);

state_daozei(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_DAOZEI, State),
    {next_state, state_daozei, NewState};

state_daozei({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_daozei, State);

state_daozei(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {next_state, state_daozei, State};

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
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_QIUBITE, State),
    {next_state, state_qiubite, NewState};

state_qiubite({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_qiubite, State);

state_qiubite(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {next_state, state_qiubite, State};

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
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_HUNXUEER, State),
    {next_state, state_hunxueer, NewState};

state_hunxueer({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_hunxueer, State);

state_hunxueer(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {next_state, state_hunxueer, State};

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
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_SHOUWEI, State),
    {next_state, state_shouwei, NewState};

state_shouwei({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_shouwei, State);

state_shouwei(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {next_state, state_shouwei, State};

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
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_LANGREN, State),
    {next_state, state_langren, NewState};

state_langren({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_langren, State);

state_langren(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
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
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_NVWU, State),
    {next_state, state_nvwu, NewState};

state_nvwu({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_nvwu, State);

state_nvwu(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {next_state, state_nvwu, State};

state_nvwu(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_nvwu_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_nvwu), NewState}.
            
%% ====================================================================
%% state_yuyanjia
%% ====================================================================
state_yuyanjia(start, State) ->
    do_duty_state_start(?DUTY_YUYANJIA, state_yuyanjia, State);

state_yuyanjia(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_YUYANJIA, State),
    {next_state, state_yuyanjia, NewState};

state_yuyanjia({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_yuyanjia, State);

state_yuyanjia(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {next_state, state_yuyanjia, State};

state_yuyanjia(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_yuyanjia_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_yuyanjia), NewState}.

%% ====================================================================
%% state_part_jingzhang
%% ====================================================================

state_part_jingzhang(start, State) ->
    send_event_inner(wait_op),
    {next_state, state_part_jingzhang, State};

state_part_jingzhang(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    notice_jingxuan_jingzhang(State),
    StateAfterWait = do_set_wait_op(lib_fight:get_alive_seat_list(State), State)
    {next_state, state_part_jingzhang, StateAfterWait};

state_part_jingzhang({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_part_jingzhang, State).

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
%% state_xuanju_jingzhang
%% ====================================================================
state_xuanju_jingzhang(start, State) ->
    case maps:get(part_jingzhang, State) of
        [] ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_xuanju_jingzhang), State};
        _ ->
            send_event_inner(wait_op),
            {next_state, state_xuanju_jingzhang, State}
    end;

state_xuanju_jingzhang(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    notice_xuanju_jingzhang(State),
    WaitList = lib_fight:get_alive_seat_list(State) -- maps:get(part_jingzhang, State),
    StateAfterWait = do_set_wait_op(WaitList, State)
    {next_state, state_xuanju_jingzhang, StateAfterWait};    
    
state_xuanju_jingzhang({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_part_jingzhang, State);

state_xuanju_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_part_jingzhang, State};

state_xuanju_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, XuanjuResult, NewState} = lib_fight:do_xuanju_jingzhang_op(State),
    notice_xuanju_jingzhang_result(IsDraw, XuanjuResult, NewState)
    case IsDraw of
        true ->
            send_event_inner(wait_op),
            {next_state, state_xuanju_jingzhang, NewState};
        false ->   
            send_event_inner(start),
            {next_state, get_next_game_state(state_xuanju_jingzhang), NewState}
    end.     

%% ====================================================================
%% state_jingzhang
%% ====================================================================
state_jingzhang(start, State) ->
    case maps:get(jingzhang, State, 0) of
        0 ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_xuanju_jingzhang), State};
        _ ->
            send_event_inner(wait_op),
            {next_state, state_xuanju_jingzhang, State}
    end;

state_jingzhang(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    JingZhang = maps:get(jingzhang, State),
    notice_player_op(?OP_JINGZHANG_ZHIDING, [JingZhang], State),
    StateAfterWait = do_set_wait_op([JingZhang], State),
    {next_state, state_jingzhang, StateAfterWait}; 

state_jingzhang({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_jingzhang, State);

state_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_jingzhang, State};

state_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_ingzhang_op(State),
    send_event_inner(start),
    {next_state, get_next_game_state(state_jingzhang), NewState}.

%% ====================================================================
%% state_fayan
%% ====================================================================

state_fayan(start, State) ->
    case maps:get(fayan_turn, State) of
        [] ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_fayan), State};
        _ ->
            send_event_inner(wait_op),
            {next_state, state_fayan, State}
    end;

state_fayan(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    Fayan = hd(maps:get(fayan_turn, State)),
    notice_player_op(?OP_FAYAN, [Fayan], State),
    StateAfterWait = do_set_wait_op([Fayan], State),
    {next_state, state_fayan, StateAfterWait};

state_fayan({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_fayan, State);

state_fayan(op_over, State) ->
    StateAfterFayan = lib_fight:do_fayan_op(State),
    case maps:get(fayan_turn, StateAfterFayan) of
        [] ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_fayan), StateAfterFayan};
        _ ->
            send_event_inner(wait_op),
            {next_state, state_fayan, StateAfterFayan}
    end.

%% ====================================================================
%% state_toupiao
%% ====================================================================
state_toupiao(start, State) ->
    send_event_inner(wait_op),
    {next_state, state_toupiao, State}.

state_toupiao(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    notice_toupiao(State),
    WaitList = lib_fight:get_alive_seat_list(State),
    StateAfterWait = do_set_wait_op(WaitList, State)
    {next_state, state_toupiao, StateAfterWait};    
    
state_toupiao({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_toupiao, State);

state_toupiao(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_toupiao, State};

state_toupiao(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, TouPiaoResult, NewState} = lib_fight:do_toupiao_op(State),
    notice_state_toupiao_result(IsDraw, TouPiaoResult, NewState)
    case IsDraw of
        true ->
            send_event_inner(wait_op),
            {next_state, state_toupiao, NewState};
        false ->   
            send_event_inner(start),
            {next_state, get_next_game_state(state_toupiao), NewState}
    end.  

%% ====================================================================
%% state_day
%% ====================================================================
state_day(start, State) ->
    notice_night_result(State),
    {IsOver, Winner} = 
        get_fight_result(State),
    case IsOver of
        true ->
            send_event_inner(start),
            {next_state, state_over, State};
        false ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_day), clear_night_op(State)}
    end.

%% ====================================================================
%% state_over
%% ====================================================================

state_over(start, State) ->
    {stop, normal, State}.


state_name(_Event, _From, StateData) ->
    Reply = next_state,
    {reply, Reply, state_name, StateData}.

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

send_event_to_fsm(Event, Player) ->
    PlayerFightProcess = lib_room:get_fight_pid_by_player(Player),
    case PlayerFightProcess of
        undefined ->
            ignore;
        _ ->
            gen_fsm:send_event(PlayerFightProcess, Event)
    end.

send_event_to_all_state(Event, Player) ->
    PlayerFightProcess = lib_room:get_fight_pid_by_player(Player),
    case PlayerFightProcess of
        undefined ->
            ignore;
        _ ->
            gen_fsm:send_all_state_event(PlayerFightProcess, Event)
    end.

%% ====================================================================
%% Internal functions
%% ====================================================================

notice_duty(State) ->
    SeatDutyMap = maps:get(seat_duty_map, State),
    FunNotice = 
        fun(SeatId) ->
            Duty = maps:get(SeatId, SeatDutyMap),
            Send = #m__fight__notice_duty__s2l{duty = Duty},
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
            send_event_inner(wait_op),
            {next_state, GameState, State}
    end.

do_duty_state_wait_op(Duty, State) ->
    SeatIdList = lib_fight:get_duty_seat(Duty, State),
    notice_player_op(Duty, SeatIdList, State),
    do_set_wait_op(SeatIdList, State).

do_receive_player_op(PlayerId, Op, StateName, State) ->
    try
        assert_op_in_wait(PlayerId, State),
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
        StateAfterLogOp = do_log_op(SeatId, Op, State),
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
            state_part_jingzhang;
        state_part_jingzhang ->
            state_xuanju_jingzhang;
        state_xuanju_jingzhang ->
            state_jingzhang;
        state_jingzhang ->
            state_fayan;
        state_fayan ->
            state_toupiao;
        state_toupiao ->
            state_day;
        state_day ->
            state_shouwei
    end.

notice_player_op(Op, SeatList, State) ->
    notice_player_op(Op, [], SeatList, State).

notice_player_op(Op, AttachData, SeatList, State) ->
    Send = #m__fight__notice_op__s2l{op = Op，
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

do_log_op(SeatId, Op, State) ->
    LastOpData = maps:get(last_op_data, State),
    NewLastOpData = maps:put(SeatId, Op, LastOpData),
    maps:put(last_op_data, NewLastOpData, State).

do_remove_wait_op(SeatId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    NewWaitOpList = WaitOpList -- [SeatId],
    {NewWaitOpList == [], maps:put(wait_op_list, NewWaitOpList, State)}.

notice_jingxuan_jingzhang(State) ->
    notice_player_op(?OP_PART_JINGZHANG}, lib_fight:get_alive_seat_list(State), State).

notice_xuanju_result(XaunJuType, IsDraw, XuanJuResult, State) ->
    PResutList = [#p_xuanju_result{seat_id = SeatId, 
                                   select_list = SelectList} || {SeatId, SelectList} <- XuanJuResult],
    Send = #m__fight__xuanju_result__s2l{xuanju_type = XaunJuType,
                                         result_list = PResutList,
                                         is_draw = IsDraw},
    lib_fight:send_to_all_player(Send, State).

notice_xuanju_jingzhang(State) ->
    PartXuanjuList = maps:get(part_jingzhang, State),
    notice_player_op(?OP_XUANJU_JINGZHANG, PartXuanjuList, 
        lib_fight:get_alive_seat_list(State) -- PartXuanjuList, State).

notice_xuanju_jingzhang_result(IsDraw, XuanjuResult, State) ->
    notice_xuanju_result(?XUANJU_TYPE_JINGZHANG, IsDraw, XuanJuResult, State).

notice_toupiao(State) ->
    AliveList = lib_fight:get_alive_seat_list(State),
    notice_player_op(?OP_TOUPIAO, AliveList, AliveList, State).
