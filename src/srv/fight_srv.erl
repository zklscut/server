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

    %%TODO notice player duty
    send_event_inner(wait_op),
    {ok, ?GAME_STATE_SPECIAL_NIGHT, NewState}.


?GAME_STATE_SPECIAL_NIGHT(wait_op, State) ->
    %%TODO select special
    %%send player to op
    %% config timeout
    %% log op seat
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, 30000),
    {next_state, state_name, State};

?GAME_STATE_SPECIAL_NIGHT({player_op, PlayerId, Op}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    %%TODO assert op 
    %% op
    %% decide next or continuce
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