%% @author zhangkl
%% @doc player_srv.
%% 2016


-module(player_srv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% API functions
%% ====================================================================

-export([start_link/1,
         active_socket/1]).

start_link(Socket) ->
    gen_server:start_link(?MODULE, [Socket], []).

active_socket(Pid) ->
    gen_server:cast(Pid, active_socket).

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
init([Socket]) ->
    {ok, #{socket => Socket}}.


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
handle_cast(active_socket, State) ->
    active_socket_inner(maps:get(socket, State)),
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

handle_info({tcp_closed, _}, State) ->
    {stop, logout, State};

handle_info({tcp, _Port, <<PreData:24, Len:16, ProtoId:16, ProtoData/binary>>}, State) ->
    lager:info("receive bianry ~p", [{PreData, Len, ProtoId, ProtoData}]),
    {Op, NewState} = do_proto(ProtoId, ProtoData, State),
    do_cache_op(Op, NewState),
    active_socket_inner(maps:get(socket, State)),
    {noreply, NewState};

handle_info(Info, State) ->
    lager:error("unhandle info ~p", [Info]),
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
terminate(Reason, _State) ->
    lager:info("player terminate Reason ~p", [Reason]),
    supervisor:terminate_child(player_supervisor, self()),
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

active_socket_inner(Socket) ->
    inet:setopts(Socket, [{active, once}]).

do_proto(ProtoId, ProtoData, State) ->
    try
        {ProtoName, Module, Function} = b_proto_route:get(ProtoId),
        ProtoRecord = game_pb:decode(ProtoName, ProtoData),
        lager:info("receive proto ~p", [ProtoRecord]),
        apply(Module, Function, [ProtoRecord, State])
    catch
        throw:ThrowError ->
            lager:debug("throw error ~p", [ThrowError]),
            {ok, State};
        What:Error ->
            lager:error("error what ~p, Error ~p, stack", [What, Error, erlang:get_stacktrace()]),
            {ok, State}
    end.

do_cache_op(_Op, _NewState) ->
    ok.

