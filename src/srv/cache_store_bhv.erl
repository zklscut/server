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
    start_link/1,
    read/2,
    write/2,
    delete/2,
    sync_db/1,
    sync_db/2,
    delete_all/1,
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
        {write, 2},
        {sync_db, 1}
    ];

behaviour_info(_) -> 
   undefined.

-define(ETS_NAME(NAME), list_to_atom(lists:concat(["cache_store_", atom_to_list(NAME)]))).

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
start_link(Module) ->
    gen_server:start_link({local, Module}, ?MODULE, [Module], []).

read(CacheModule, Key) ->
    CacheResult = cache:get_value(?ETS_NAME(CacheModule), Key) , 
    case CacheResult of
        undefined ->
            CacheData = apply(CacheModule, read, [Key, #state{}]),
            cache:update(?ETS_NAME(CacheModule), Key, CacheData),
            CacheData;
        _ ->
            CacheResult
    end.


write(CacheModule, {Key, Data}) ->
    gen_server:cast(CacheModule, {write, {Key, Data}}).

delete(CacheModule, Key) ->
    gen_server:cast(CacheModule, {delete, Key}).

sync_db(CacheModule) ->
    sync_db(async, CacheModule).

sync_db(async, CacheModule) ->
    gen_server:cast(CacheModule, sync_db);
sync_db(sync, CacheModule) ->
    gen_server:call(CacheModule, sync_db).

delete_all(CacheModule) ->
    gen_server:cast(CacheModule, {delete_all}).

get_all(CacheModule) ->
    ets:tab2list(?ETS_NAME(CacheModule)).

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
handle_call({read, Key}, _From, State) ->
    Reply = (State#state.module):read(Key, State),
    {reply, Reply, State};

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

handle_cast({write, {Key, Data}}, State) ->
    NewDirtyKeyList = add_dirty_key(Key, State#state.dirty_key_list),
    lib_ets:update(?ETS_NAME(State#state.module), Key, Data),
    NewState = State#state{dirty_key_list = NewDirtyKeyList},
    {noreply, NewState};

handle_cast({delete, Key}, State) ->
    NewState = (State#state.module):delete(Key, State),
    NewDirtyKeyList = delete_dirty_key(Key, NewState#state.dirty_key_list),
    lib_ets:delete(?ETS_NAME(State#state.module), Key),
    {noreply, NewState#state{dirty_key_list = NewDirtyKeyList}};

handle_cast({delete_all}, State) ->
    lib_ets:delete_all(?ETS_NAME(State#state.module)),
    {noreply, State#state{dirty_key_list = []}};

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

delete_dirty_key(Key, DirtyKeyList) ->
    DirtyKeyList -- [Key].


sync_db_inner(State) ->
    ok = (State#state.module):sync_db(State#state.dirty_key_list),
    erlang:send_after(State#state.interval, self(), sync_time),
    State#state{dirty_key_list = []}.