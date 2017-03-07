%% @author zhangkl
%% @doc rank_behaviour.
%% 2016

-module(rank_behaviour).
-callback get_rank_to_role_mnesia() -> atom().
-callback get_role_id_to_rank_mnesia() -> atom().
-behaviour(gen_server).
% -export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

% -record(state, {module = undefined}).
% -define(SERVER_MAX_RANK, 100).

% %% ====================================================================
% %% API functions
% %% ====================================================================
% -export([start_link/0, value_change/4, reset/2, get_role_show_by_rank/2, dump_all_rank_server/0, get_max_rank/1]).

% start_link() ->
%     gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

% value_change(Module, RoleId, PreValue, Value) ->
%     gen_server:cast(Module, {value_change, RoleId, PreValue, Value}).

% reset(Module) ->
%     gen_server:cast(Module, reset).

% get_role_show_by_rank(Rank, Module) ->
%     Mnesia = Module:get_rank_to_role_mnesia(),
%     case lib_ets:get(Mnesia, Rank) of
%         undefined ->
%             fakse;
%         Cache ->
%             Cache
%     end.

% dump_all_rank_server() ->
%     [dump_rank_server(Module) || Module <- []].

% dump_rank_server(Module) ->
%     gen_server:call(Modul, dump_rank_server).

% get_max_rank(Module) ->
%     Mnesia = get_rank_to_role_mnesia(),
%     ets:info(Mnesia, size).


% %% ====================================================================
% %% Behavioural functions
% %% ====================================================================


% %% init/1
% %% ====================================================================
% %% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
% -spec init(Args :: term()) -> Result when
%     Result :: {ok, State}
%             | {ok, State, Timeout}
%             | {ok, State, hibernate}
%             | {stop, Reason :: term()}
%             | ignore,
%     State :: term(),
%     Timeout :: non_neg_integer() | infinity.
% %% ====================================================================
% init([Module]) ->
%     {DBRoleToRank, DBRankToRole} = select_rank_data_from_db(Module),
%     State = #state{module = Module},
%     MnesiaRoleToRank = get_role_id_to_rank_mnesia(State),
%     MnesiaRankToRole = get_rank_to_role_mnesia(State),
%     %%todo init from db

%     {ok, #state{}}.
    


% %% handle_call/3
% %% ====================================================================
% %% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
% -spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
%     Result :: {reply, Reply, NewState}
%             | {reply, Reply, NewState, Timeout}
%             | {reply, Reply, NewState, hibernate}
%             | {noreply, NewState}
%             | {noreply, NewState, Timeout}
%             | {noreply, NewState, hibernate}
%             | {stop, Reason, Reply, NewState}
%             | {stop, Reason, NewState},
%     Reply :: term(),
%     NewState :: term(),
%     Timeout :: non_neg_integer() | infinity,
%     Reason :: term().
% %% ====================================================================
% handle_call(_Request, _From, State) ->
%     Reply = ok,
%     {reply, Reply, State}.


% %% handle_cast/2
% %% ====================================================================
% %% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
% -spec handle_cast(Request :: term(), State :: term()) -> Result when
%     Result :: {noreply, NewState}
%             | {noreply, NewState, Timeout}
%             | {noreply, NewState, hibernate}
%             | {stop, Reason :: term(), NewState},
%     NewState :: term(),
%     Timeout :: non_neg_integer() | infinity.
% %% ====================================================================
% handle_cast(Cast, State) ->
%     try
%         handle_cast_inner(Cast, State)
%     catch
%         throw:{ErrCode, PlayerId} ->
%             global_op_srv:player_op(PlayerId, {mod_player, send_errcode, ErrCode});
%         What:Error ->
%             lager:error("error what ~p, Error ~p, stack", 
%                 [What, Error, erlang:get_stacktrace()]),
%         {noreply, State}        
%     end.

% handle_cast_inner({value_change, RoleId, PreValue, NewValue}, State) ->
%     Module = State#state.module,
%     MaxRank = get_max_rank(Module),
%     Rank = 
%         case get_rank_by_role_id(RoleId, State) of
%             false ->
%                 MaxRank + 1;
%             CurRank ->
%                 CurRank
%         end,
%     case MaxRank of
%         0 ->
%             update_rank(RoleId, 1, Value, State);
%         1 when Rank == 1 ->
%             update_rank(RoleId, 1, Value, State);
%         _ ->
%             ExchangeChangeRank = ?IF(Module:is_lager(Value, PreValue), -1, 1),
%             exchange_rank(Rank + ExchangeChangeRank, RoleId, Value, ExchangeChangeRank, State)
%     end,
%     {noreply, State}.

% %% handle_info/2
% %% ====================================================================
% %% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
% -spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
%     Result :: {noreply, NewState}
%             | {noreply, NewState, Timeout}
%             | {noreply, NewState, hibernate}
%             | {stop, Reason :: term(), NewState},
%     NewState :: term(),
%     Timeout :: non_neg_integer() | infinity.
% %% ====================================================================
% handle_info(_Info, State) ->
%     {noreply, State}.


% %% terminate/2
% %% ====================================================================
% %% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
% -spec terminate(Reason, State :: term()) -> Any :: term() when
%     Reason :: normal
%             | shutdown
%             | {shutdown, term()}
%             | term().
% %% ====================================================================
% terminate(_Reason, _State) ->
%     ok.


% %% code_change/3
% %% ====================================================================
% %% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
% -spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
%     Result :: {ok, NewState :: term()} | {error, Reason :: term()},
%     OldVsn :: Vsn | {down, Vsn},
%     Vsn :: term().
% %% ====================================================================
% code_change(_OldVsn, State, _Extra) ->
%     {ok, State}.


% %% ====================================================================
% %% Internal functions
% %% ====================================================================

% get_rank_by_role_id(RoleId, State) ->
%     Mnesia = get_role_id_to_rank_mnesia(State),
%     case lib_ets:get(Mnesia, RoleId) of
%         undefined ->
%             false;
%         Rank ->
%             Rank
%     end.

% get_role_by_rank(Rank, State) ->
%     Mnesia = get_rank_to_role_mnesia(State),
%     case lib_ets:get(Mnesia, Rank) of
%         undefined ->
%             false;
%         Cache ->
%             Cache
%     end.

% update_rank_by_role_id(RoleId, Rank, State) ->
%     Mnesia = get_role_id_to_rank_mnesia(State),
%     lib_ets:update(Mnesia, RoleId, Rank).

% update_role_by_rank(Rank, RoleId, Value, State) ->
%     Mnesia = get_rank_to_role_mnesia(State),
%     lib_ets:update(Mnesia, Rank, {RoleId, Value}).

% update_rank(RoleId, Rank, _Value, State) when Rank > ?SERVER_MAX_RANK ->
%     remove_rank(RoleId, Rank, State);

% update_rank(RoleId, Rank, Value, State) ->
%     update_rank_by_role_id(RoleId, Rank, State),
%     update_role_by_rank(Rank, RoleId, Value, State).

% remove_rank(RoleId, Rank, State) ->
%     MnesiaRoleToRank = get_role_id_to_rank_mnesia(State),
%     lib_ets:delete(MnesiaRoleToRank, RoleId),
%     MnesiaRankToRole = get_rank_to_role_mnesia(State),
%     lib_ets:delete(MnesiaRankToRole, Rank).

% get_rank_to_role_mnesia(State) ->
%     Module = State#state.module,
%     Module:get_rank_to_role_mnesia().

% get_role_id_to_rank_mnesia(State) ->
%     Module = State#state.module,
%     Module:get_role_id_to_rank_mnesia().

% exchange_rank(0, RoleId, Value, _ExchangeChangeRank, State) ->
%     update_rank(RoleId, 1, Value, State);

% exchange_rank(TargetRank, RoleId, Value, ExchangeChangeRank, State) ->
%     case get_role_by_rank(TargetRank, State) of
%         false ->
%             update_rank(RoleId, TargetRank - ExchangeChangeRank, Value, State);
%         {TargetId, TargetValue} ->
%             case is_need_exchange(Value, TargetValue, ExchangeChangeRank, State) of
%                 true ->
%                     update_rank(RoleId, TargetRank, Value, State),
%                     update_rank(TargetId, TargetRank - ExchangeChangeRank, TargetValue, State),
%                     exchange_rank(TargetRank + ExchangeChangeRank, RoleId, Value, ExchangeChangeRank, State);
%                 false ->
%                     update_rank(RoleId, TargetRank - ExchangeChangeRank, Value, State),
%                     ok
%             end
%     end.

% is_need_exchange(Value, ExchangeValue, ExchangeChangeRank, State) ->
%     Module = State#state.module,
%     ?IF(ExchangeChangeRank < 0, Module:is_lager(Value, ExchangeValue), Module:is_lager(ExchangeValue, Value)).

% select_rank_data_from_db(Module) ->
%     ok.

% update_rank_data_to_db() ->
%     ok,

