%% @author zhangkl
%% @doc rank_behaviour.
%% 2016

-module(rank_behaviour).
-callback get_rank_to_player_ets() -> atom().
-callback get_player_id_to_rank_ets() -> atom().

-include("function.hrl").

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {module = undefined}).
-define(SERVER_MAX_RANK, 100).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/1, value_change/4, reset/1, get_player_show_by_rank/2, dump_all_rank_server/0, get_max_rank/1]).

start_link(Module) ->
    gen_server:start_link({local, Module}, ?MODULE, [Module], []).

%%比如狼人积分变换了 调用 rank_behaviour:value_change(langren_rank_srv, PlayerId, PreValue, Value)
value_change(Module, PlayerId, PreValue, Value) ->
    gen_server:cast(Module, {value_change, PlayerId, PreValue, Value}).

reset(Module) ->
    gen_server:cast(Module, reset).

get_player_show_by_rank(Rank, Module) ->
    Ets = get_rank_to_player_ets(Module),
    case lib_ets:get(Ets, Rank) of
        undefined ->
            false;
        Cache ->
            Cache
    end.

dump_all_rank_server() ->
    [dump_rank_server(Module) || Module <- [langren_rank_srv]].

dump_rank_server(Module) ->
    gen_server:call(Module, dump_rank_server).

get_max_rank(Module) ->
    Ets = get_rank_to_player_ets(Module),
    ets:info(Ets, size).


%% ====================================================================
%% Behavioural functions
%% ====================================================================


%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
-spec init(Args :: term()) -> Result when
    Result :: {ok, State}
            | {ok, State, Timeout}
            | {ok, State, hibernate}
            | {stop, Reason :: term()}
            | ignore,
    State :: term(),
    Timeout :: non_neg_integer() | infinity.
%% ====================================================================
init([Module]) ->
    {DBPlayerToRank, DBRankToPlayer} = select_rank_data_from_db(Module),
    State = #state{module = Module},
    EtsPlayerToRank = get_player_id_to_rank_ets(Module),
    EtsRankToPlayer = get_rank_to_player_ets(Module),

    [lib_ets:update(EtsPlayerToRank, PlayerId, Rank) || {PlayerId, Rank} <- DBPlayerToRank],
    [lib_ets:update(EtsRankToPlayer, Rank, Data) ||  {Rank, Data} <- DBRankToPlayer],

    {ok, #state{module = Module}}.
    
%% handle_call/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
    Result :: {reply, Reply, NewState}
            | {reply, Reply, NewState, Timeout}
            | {reply, Reply, NewState, hibernate}
            | {noreply, NewState}
            | {noreply, NewState, Timeout}
            | {noreply, NewState, hibernate}
            | {stop, Reason, Reply, NewState}
            | {stop, Reason, NewState},
    Reply :: term(),
    NewState :: term(),
    Timeout :: non_neg_integer() | infinity,
    Reason :: term().
%% ====================================================================

handle_call(dump_rank_server, _From, State) ->
    Module = State#state.module,
    EtsPlayerToRank = get_player_id_to_rank_ets(Module),
    EtsRankToPlayer = get_rank_to_player_ets(Module),
    DBPlayerToRank = ets:tab2list(EtsPlayerToRank),
    DBRankToPlayer = ets:tab2list(EtsRankToPlayer),

    Data = {DBPlayerToRank, DBRankToPlayer},
    update_rank_data_to_db(Module, Data),

    Reply = ok,
    {reply, Reply, State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
-spec handle_cast(Request :: term(), State :: term()) -> Result when
    Result :: {noreply, NewState}
            | {noreply, NewState, Timeout}
            | {noreply, NewState, hibernate}
            | {stop, Reason :: term(), NewState},
    NewState :: term(),
    Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_cast(Cast, State) ->
    try
        handle_cast_inner(Cast, State)
    catch
        throw:{ErrCode, PlayerId} ->
            global_op_srv:player_op(PlayerId, {mod_player, send_errcode, ErrCode});
        What:Error ->
            lager:error("error what ~p, Error ~p, stack", 
                [What, Error, erlang:get_stacktrace()]),
        {noreply, State}        
    end.

handle_cast_inner({value_change, PlayerId, PreValue, Value}, State) ->
    Module = State#state.module,
    MaxRank = get_max_rank(Module),
    Rank = 
        case get_rank_by_player_id(PlayerId, State) of
            false ->
                MaxRank + 1;
            CurRank ->
                CurRank
        end,
    case MaxRank of
        0 ->
            update_rank(PlayerId, 1, Value, State);
        1 when Rank == 1 ->
            update_rank(PlayerId, 1, Value, State);
        _ ->
            ExchangeChangeRank = ?IF(Module:is_lager(Value, PreValue), -1, 1),
            exchange_rank(Rank + ExchangeChangeRank, PlayerId, Value, ExchangeChangeRank, State)
    end,
    {noreply, State}.

%% handle_info/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
-spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
    Result :: {noreply, NewState}
            | {noreply, NewState, Timeout}
            | {noreply, NewState, hibernate}
            | {stop, Reason :: term(), NewState},
    NewState :: term(),
    Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_info(_Info, State) ->
    {noreply, State}.


%% terminate/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
-spec terminate(Reason, State :: term()) -> Any :: term() when
    Reason :: normal
            | shutdown
            | {shutdown, term()}
            | term().
%% ====================================================================
terminate(_Reason, _State) ->
    ok.


%% code_change/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
-spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
    Result :: {ok, NewState :: term()} | {error, Reason :: term()},
    OldVsn :: Vsn | {down, Vsn},
    Vsn :: term().
%% ====================================================================
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================

get_rank_by_player_id(PlayerId, State) ->
    Ets = get_player_id_to_rank_ets(State#state.module),
    case lib_ets:get(Ets, PlayerId) of
        undefined ->
            false;
        Rank ->
            Rank
    end.

get_player_by_rank(Rank, State) ->
    Ets = get_rank_to_player_ets(State#state.module),
    case lib_ets:get(Ets, Rank) of
        undefined ->
            false;
        Cache ->
            Cache
    end.

update_rank_by_player_id(PlayerId, Rank, State) ->
    Ets = get_player_id_to_rank_ets(State#state.module),
    lib_ets:update(Ets, PlayerId, Rank).

update_player_by_rank(Rank, PlayerId, Value, State) ->
    Ets = get_rank_to_player_ets(State#state.module),
    lib_ets:update(Ets, Rank, {PlayerId, Value}).

update_rank(PlayerId, Rank, _Value, State) when Rank > ?SERVER_MAX_RANK ->
    remove_rank(PlayerId, Rank, State);

update_rank(PlayerId, Rank, Value, State) ->
    update_rank_by_player_id(PlayerId, Rank, State),
    update_player_by_rank(Rank, PlayerId, Value, State).

remove_rank(PlayerId, Rank, State) ->
    EtsPlayerToRank = get_player_id_to_rank_ets(State#state.module),
    lib_ets:delete(EtsPlayerToRank, PlayerId),
    EtsRankToPlayer = get_rank_to_player_ets(State#state.module),
    lib_ets:delete(EtsRankToPlayer, Rank).

get_rank_to_player_ets(Module) ->
    Module:get_rank_to_player_ets().

get_player_id_to_rank_ets(Module) ->
    Module:get_player_id_to_rank_ets().

exchange_rank(0, PlayerId, Value, _ExchangeChangeRank, State) ->
    update_rank(PlayerId, 1, Value, State);

exchange_rank(TargetRank, PlayerId, Value, ExchangeChangeRank, State) ->
    case get_player_by_rank(TargetRank, State) of
        false ->
            update_rank(PlayerId, TargetRank - ExchangeChangeRank, Value, State);
        {TargetId, TargetValue} ->
            case is_need_exchange(Value, TargetValue, ExchangeChangeRank, State) of
                true ->
                    update_rank(PlayerId, TargetRank, Value, State),
                    update_rank(TargetId, TargetRank - ExchangeChangeRank, TargetValue, State),
                    exchange_rank(TargetRank + ExchangeChangeRank, PlayerId, Value, ExchangeChangeRank, State);
                false ->
                    update_rank(PlayerId, TargetRank - ExchangeChangeRank, Value, State),
                    ok
            end
    end.

is_need_exchange(Value, ExchangeValue, ExchangeChangeRank, State) ->
    Module = State#state.module,
    ?IF(ExchangeChangeRank < 0, Module:is_lager(Value, ExchangeValue), Module:is_lager(ExchangeValue, Value)).

select_rank_data_from_db(Module) ->
    Sql = "select data from rank where rank_name = " ++ atom_to_list(Module),
    case db:get_one(Sql) of
        null ->
            [];
        Data ->
            binary_to_term(Data)
    end.

update_rank_data_to_db(Module, Data) ->
    Sql = 
        db:make_replace_sql(rank, ["rank_name", "data"], [[Module, term_to_binary(Data)]]),
    db:execute(Sql).
