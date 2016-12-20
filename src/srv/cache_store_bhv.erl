%%%-------------------------------------------------------------------
%%% @author zhangkl
%%% @copyright 2016 4399
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------

-module(cache_store_bhv).

-export([behaviour_info/1]).

-behaviour(gen_server).
%% API
-export([
    start_link/2,
    read/2,
    write/2,
    sync_db/1,
    sync_db/2,
    get_all/1
    ]).


%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {
        module,
        interval = 0,
        dirty_key_list = []}).


behaviour_info(callbacks) -> 
    [
        {init, 0},
        {sync_db, 1}
    ];

behaviour_info(_) -> 
   undefined.

-define(ETS_NAME(MODULE), list_to_atom(lists:concat(["ets_", atom_to_list(MODULE)]))).

%%%===================================================================
%%% API
%%%===================================================================


%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link(Module, Interval) ->
    supervisor:start_child(game_supervisor,
                           {Module, 
                           {gen_server, start_link, [{local, Module}, ?MODULE, [Module, Interval], []]},
                            transient, infinity, worker, [Module]}).

read(Module, Key) ->
    lib_ets:get(?ETS_NAME(Module), Key).

write(Module, {Key, Data}) ->
    lib_ets:update(?ETS_NAME(Module), Key, Data),
    gen_server:cast(Module, {write, Key}).

sync_db(Module) ->
    sync_db(async, Module).

sync_db(async, Module) ->
    gen_server:cast(Module, sync_db);
sync_db(sync, Module) ->
    gen_server:call(Module, sync_db).

get_all(Module) ->
    ets:tab2list(?ETS_NAME(Module)).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------

init([Module, Interval]) ->
    ets:new(?ETS_NAME(Module), [set, public, named_table, {keypos, 1}]),
    erlang:send_after(Interval, Module, sync_time),
    Module:init(),
    {ok, #state{module = Module,
                interval = Interval}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------

handle_call(sync_db, _From, State) ->
    {reply, ok, sync_db_inner(State)}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------

handle_cast({write, Key}, State) ->
    NewDirtyKeyList = add_dirty_key(Key, State#state.dirty_key_list),
    NewState = State#state{dirty_key_list = NewDirtyKeyList},
    {noreply, NewState};

handle_cast(sync_db, State) ->
    {noreply, sync_db_inner(State)}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------

handle_info(sync_time, State) ->
    sync_db(State#state.module),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

add_dirty_key(Key, DirtyKeyList) ->
    case lists:member(Key, DirtyKeyList) of
        true ->
            DirtyKeyList;
        false ->
            [Key|DirtyKeyList]
    end.

sync_db_inner(State) ->
    ok = (State#state.module):sync_db(State#state.dirty_key_list),
    erlang:send_after(State#state.interval, self(), sync_time),
    State#state{dirty_key_list = []}.