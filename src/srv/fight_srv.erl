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

% -define(MFIGHT, #{room_id => 0,
%                   seat_player_map => #{},%% #{seat_id, player_id}
%                   player_seat_map => #{},%% #{player_id, seat_id}
%                   offline_list => [],   %% seat_id
%                   out_player_list => [],%% 出局列表 seat_id
%                   seat_duty_map => #{}, %% #{seat_id, 职责}
%                   duty_seat_map => #{}, %% #{duty_id, [seat_id]}
%                   left_op_list => [],   %% 剩余操作seat_id 按照顺序排好
%                   op => 0,              %% 当前进行的操作
%                   game_state =>  0,     %% 第几天晚上
%                   game_round =>  1,     %% 第几轮
%                   last_op_data => #{}   %% 上一轮操作的数据, 杀了几号, 投了几号等等
%                   }).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:init-1">gen_fsm:init/1</a>
-spec init(Args :: term()) -> Result when
    Result :: {ok, StateName, StateData}
            | {ok, StateName, StateData, Timeout}
            | {ok, StateName, StateData, hibernate}
            | {stop, Reason}
            | ignore,
    StateName :: atom(),
    StateData :: term(),
    Timeout :: non_neg_integer() | infinity,
    Reason :: term().
%% ====================================================================
init([RoomId, PlayerList, State]) ->
    lib_room:update_fight_pid(RoomId, self()),
    NewState = lib_fight:init(RoomId, PlayerList, State),
    notice_duty(NewState),
    send_event_inner(start),
    {ok, ?GAME_STATE_SPECIAL_NIGHT, NewState}.

notice_duty(State) ->
    SeatDutyMap = maps:get(seat_duty_map, State),
    FunNotice = 
        fun(SeatId) ->
            Duty = maps:get(SeatId, SeatDutyMap),
            Send = #m__fight__notice_duty__s2l{duty = Duty},
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, maps:keys(SeatDutyMap)).

?GAME_STATE_SPECIAL_NIGHT(start, State) ->
    StateAfterInit = lib_fight:init_special_night(State),
    StateAfterStatus = update_fight_status(?GAME_STATE_SPECIAL_NIGHT, StateAfterInit),
    send_event_inner(new_op),
    {ok, ?GAME_STATE_SPECIAL_NIGHT, StateAfterStatus};

?GAME_STATE_SPECIAL_NIGHT(new_op, State) ->
    case get_turn_op_list(State) of
        undefined ->
            send_event_inner(start),
            {next_state, ?GAME_STATE_LANGREN_NIGHT, State};        
        TurnList ->
            notice_player_op(TurnList, State),
            StateAfterWaitOp = maps:put(wait_op_list, TurnList, State),
            %start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
            {next_state, ?GAME_STATE_SPECIAL_NIGHT, StateAfterWaitOp}
    end;

?GAME_STATE_SPECIAL_NIGHT({player_op, PlayerId, Op}, State) ->
    try
        assert_op_in_wait(PlayerId, State),
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId),
        StateAfterLogOp = do_log_op(SeatId, Op, State),
        {IsWaitOver, StateAfterWaitOp} = 
            do_remove_wait_op(SeatId, StateAfterLogOp),
        case IsWaitOver of
            true ->
                %cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
                StateAfterDoOp = do_player_op(StateAfterWaitOp),
                StateAfterLeftOp = do_remove_left_op(StateAfterDoOp),
                send_event_inner(new_op),
                {next_state, ?GAME_STATE_SPECIAL_NIGHT, StateAfterLeftOp};
            false ->
                {next_state, ?GAME_STATE_SPECIAL_NIGHT, StateAfterWaitOp}
        end
    catch 
        throw:ErrCode ->
            net_send:send_errcode(ErrCode, PlayerId),
            State
    end
    {next_state, state_name, State};

?GAME_STATE_SPECIAL_NIGHT(?TIMER_TIMEOUT, State) ->
    %%TODO send special 
    {next_state, state_name, State}.



%% state_name/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:StateName-3">gen_fsm:StateName/3</a>
-spec state_name(Event :: term(), From :: {pid(), Tag :: term()}, StateData :: term()) -> Result when
    Result :: {reply, Reply, NextStateName, NewStateData}
            | {reply, Reply, NextStateName, NewStateData, Timeout}
            | {reply, Reply, NextStateName, NewStateData, hibernate}
            | {next_state, NextStateName, NewStateData}
            | {next_state, NextStateName, NewStateData, Timeout}
            | {next_state, NextStateName, NewStateData, hibernate}
            | {stop, Reason, Reply, NewStateData}
            | {stop, Reason, NewStateData},
    Reply :: term(),
    NextStateName :: atom(),
    NewStateData :: atom(),
    Timeout :: non_neg_integer() | infinity,
    Reason :: normal | term().
%% ====================================================================
state_name(Event, From, StateData) ->
    Reply = ok,
    {reply, Reply, state_name, StateData}.


%% handle_event/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:handle_event-3">gen_fsm:handle_event/3</a>
-spec handle_event(Event :: term(), StateName :: atom(), StateData :: term()) -> Result when
    Result :: {next_state, NextStateName, NewStateData}
            | {next_state, NextStateName, NewStateData, Timeout}
            | {next_state, NextStateName, NewStateData, hibernate}
            | {stop, Reason, NewStateData},
    NextStateName :: atom(),
    NewStateData :: term(),
    Timeout :: non_neg_integer() | infinity,
    Reason :: term().
%% ====================================================================
handle_event(Event, StateName, StateData) ->
    {next_state, StateName, StateData}.


%% handle_sync_event/4
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:handle_sync_event-4">gen_fsm:handle_sync_event/4</a>
-spec handle_sync_event(Event :: term(), From :: {pid(), Tag :: term()}, StateName :: atom(), StateData :: term()) -> Result when
    Result :: {reply, Reply, NextStateName, NewStateData}
            | {reply, Reply, NextStateName, NewStateData, Timeout}
            | {reply, Reply, NextStateName, NewStateData, hibernate}
            | {next_state, NextStateName, NewStateData}
            | {next_state, NextStateName, NewStateData, Timeout}
            | {next_state, NextStateName, NewStateData, hibernate}
            | {stop, Reason, Reply, NewStateData}
            | {stop, Reason, NewStateData},
    Reply :: term(),
    NextStateName :: atom(),
    NewStateData :: term(),
    Timeout :: non_neg_integer() | infinity,
    Reason :: term().
%% ====================================================================
handle_sync_event(Event, From, StateName, StateData) ->
    Reply = ok,
    {reply, Reply, StateName, StateData}.


%% handle_info/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:handle_info-3">gen_fsm:handle_info/3</a>
-spec handle_info(Info :: term(), StateName :: atom(), StateData :: term()) -> Result when
    Result :: {next_state, NextStateName, NewStateData}
            | {next_state, NextStateName, NewStateData, Timeout}
            | {next_state, NextStateName, NewStateData, hibernate}
            | {stop, Reason, NewStateData},
    NextStateName :: atom(),
    NewStateData :: term(),
    Timeout :: non_neg_integer() | infinity,
    Reason :: normal | term().
%% ====================================================================
handle_info(Info, StateName, StateData) ->
    {next_state, StateName, StateData}.


%% terminate/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:terminate-3">gen_fsm:terminate/3</a>
-spec terminate(Reason, StateName :: atom(), StateData :: term()) -> Result :: term() when
    Reason :: normal
            | shutdown
            | {shutdown, term()}
            | term().
%% ====================================================================
terminate(Reason, StateName, StatData) ->
    ok.


%% code_change/4
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_fsm.html#Module:code_change-4">gen_fsm:code_change/4</a>
-spec code_change(OldVsn, StateName :: atom(), StateData :: term(), Extra :: term()) -> {ok, NextStateName :: atom(), NewStateData :: term()} when
    OldVsn :: Vsn | {down, Vsn},
    Vsn :: term().
%% ====================================================================
code_change(OldVsn, StateName, StateData, Extra) ->
    {ok, StateName, StateData}.


%% ====================================================================
%% Internal functions
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

get_turn_op_list(State) ->
    case maps:get(left_op_list, State) of
        [] ->
            undefined;
        LeftOpList ->
            hd(LeftOpList)
    end.

assert_op_in_wait(PlayerId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    case lists:member(PlayerId, WaitOpList) of
        false ->
            throw(?ERROR);
        true ->
            ok
    end.

notice_player_op(TurnList, State) ->
    notice_player_op(duty, TurnList, State).

notice_player_op(SendOp, TurnList, State) ->
    FunNotice = 
        fun(SeatId) ->
            Op = 
                case SendOp of
                    speak ->
                        0;
                    duty ->
                        lib_fight:get_duty_by_seat(SeatId, State)
                end,
            Send = #m__fight__notice_op__s2l{op = Op},
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, TurnList).

get_fight_status(State) ->
    maps:get(status, State).

update_fight_status(Status, State) ->
    maps:put(status, Status, State).

do_log_op(SeatId, Op, State) ->
    LastOpData = maps:get(last_op_data, State),
    NewLastOpData = maps:put(SeatId, Op, LastOpData),
    maps:put(last_op_data, NewLastOpData, State).

do_remove_wait_op(SeatId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    NewWaitOpList = WaitOpList -- [SeatId],
    {NewWaitOpList == [], maps:put(wait_op_list, NewWaitOpList, State)}.

do_remove_left_op(State) ->
    LeftOpList = maps:get(left_op_list, State),
    maps:put(left_op_list, tl(LeftOpList), State).

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
