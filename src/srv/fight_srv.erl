%% @author zhangkl
%% @doc fight_srv.
%% 2016

-module(fight_srv).
-behaviour(gen_fsm).
-export([init/1, 
        ?GAME_STATE_SPECIAL_NIGHT/2, 
        state_name/3, 
        handle_event/3, 
        handle_sync_event/4, 
        handle_info/3, 
        terminate/3, 
        code_change/4]).

-include("fight.hrl").
-include("errcode.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/2]).

start_link(RoomId, PlayerList) ->
    gen_fsm:start(?MODULE, [RoomId, PlayerList, ?MFIGHT], []).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {}).

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
    do_duty_state_start(?DUTY_DAOZEI, state_daozei, State).

state_daozei(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_DAOZEI, State),
    {next_state, state_daozei, NewState};

state_daozei({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_daozei, State);

state_daozei(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {ok, state_daozei, State};

state_daozei(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_daozei_op(State),
    {ok, get_next_game_state(state_daoze), NewState}.
            
%% ====================================================================
%% state_qiubite
%% ====================================================================
state_qiubite(start, State) ->
    do_duty_state_start(?DUTY_QIUBITE, state_qiubite, State).

state_qiubite(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_QIUBITE, State),
    {next_state, state_qiubite, NewState};

state_qiubite({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_qiubite, State);

state_qiubite(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {ok, state_qiubite, State};

state_qiubite(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_qiubite_op(State),
    {ok, get_next_game_state(state_qiubite), NewState}.

%% ====================================================================
%% state_hunxuer
%% ====================================================================
state_hunxuer(start, State) ->
    do_duty_state_start(?DUTY_HUNXUEER, state_hunxuer, State).

state_hunxuer(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    NewState = do_duty_state_wait_op(?DUTY_HUNXUEER, State),
    {next_state, state_hunxuer, NewState};

state_hunxuer({player_op, PlayerId, Op}, State) ->
    do_receive_player_op(PlayerId, Op, state_hunxuer, State);

state_hunxuer(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {ok, state_hunxuer, State};

state_hunxuer(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_hunxuer_op(State),
    {ok, get_next_game_state(state_hunxuer), NewState}.

state_name(Event, From, StateData) ->
    Reply = ok,
    {reply, Reply, state_name, StateData}.

handle_event(Event, StateName, StateData) ->
    {next_state, StateName, StateData}.

handle_sync_event(Event, From, StateName, StateData) ->
    Reply = ok,
    {reply, Reply, StateName, StateData}.

handle_info(Info, StateName, StateData) ->
    {next_state, StateName, StateData}.

terminate(Reason, StateName, StatData) ->
    ok.

code_change(OldVsn, StateName, StateData, Extra) ->
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

send_event_to_all_state(Event, PlayerId) ->
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
    SeatIdList = lib_fight:get_duty_seat(Duty),
    case SeatIdList of
        [] ->
            send_event_inner(start),
            {ok, get_next_game_state(GameState), State};
        _ ->
            send_event_inner(wait_op),
            {ok, GameState, State}
    end.

do_duty_state_wait_op(Duty, State) ->
    SeatIdList = lib_fight:get_duty_seat(Duty),
    notice_player_op(Duty, SeatIdList, State),
    do_set_wait_op(SeatIdList, State).

do_receive_player_op(PlayerId, Op, StateName, State) ->
    try
        assert_op_in_wait(PlayerId, State),
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId),
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
            state_hunxueer
    end.

notice_player_op(Op, SeatList, State) ->
    Send = #m__fight__notice_op__s2l{op = Op},
    FunNotice = 
        fun(SeatId) ->
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, TurSeatListnList).

do_set_wait_op(SeatIdList, State) ->
    maps:put(wait_op_list, SeatIdList, State).

assert_op_in_wait(PlayerId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    case lists:member(PlayerId, WaitOpList) of
        false ->
            throw(?ERROR);
        true ->
            ok
    end.

do_log_op(SeatId, Op, State) ->
    LastOpData = maps:get(last_op_data, State),
    NewLastOpData = maps:put(SeatId, Op, LastOpData),
    maps:put(last_op_data, NewLastOpData, State).

do_remove_wait_op(SeatId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    NewWaitOpList = WaitOpList -- [SeatId],
    {NewWaitOpList == [], maps:put(wait_op_list, NewWaitOpList, State)}.

do_player_op(State) ->
    Status = get_fight_status(State),
    do_player_op(Status, State).

do_player_op(?GAME_STATE_SPECIAL_NIGHT, State) ->
    LastOpData = maps:get(last_op_data, State),
    {OpSeatId, OpData} = hd(maps:to_list(LastOpData)),
    DutyId = lib_fight:get_duty_by_seat(OpSeatId, State),
    do_duty_op(DutyId, {OpSeatId, OpData} , State).

do_duty_op(?DUTY_QIUBITE, {OpSeatId, [Seat1, Seat2]}, State) ->
    StateAfterLover = maps:put(lover, [Seat1, Seat2], State),
    Duty1 = lib_fight:get_duty_by_seat(Seat1),
    Duty2 = lib_fight:get_duty_by_seat(Seat2),
    NewDuty = 
        case Duty1 == Duty2 of
            true ->
                Duty1;
            false ->
                ?DUTY_NONE
        end,
    lib_fight:update_duty(OpSeatId, ?DUTY_QIUBITE, NewDuty, StateAfterLover);

do_duty_op(?DUTY_SHOUWEI, {_, [SeatId]}, State) ->
    maps:put(shouwei, SeatId, State);

do_duty_op(?DUTY_HUNXUEER, {OpSeatId, [SeatId]}, State) ->
    NewDuty = lib_fight:get_duty_by_seat(SeatId),
    lib_fight:update_duty(OpSeatId, ?DUTY_HUNXUEER, NewDuty, State).
