%% @author zhangkl
%% @doc player_srv.
%% 2016


-module(player_srv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("ets.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

-export([start_link/1,
         active_socket/1,
         do_cache_op/2,
         kick_player/2,
         stop_force/1,
         login_change_socket/2]).

start_link(Socket) ->
    gen_server:start_link(?MODULE, [Socket], []).

active_socket(Pid) ->
    gen_server:cast(Pid, active_socket).

do_cache_op(Op, State) ->
    case Op of
        save ->
            lib_player:update_player(State);
        _ ->
            ignore
    end.

kick_player(Pid, Reason) ->
    gen_server:cast(Pid, {kick, Reason}).    

stop_force(Pid) ->
    supervisor:terminate_child(player_supervisor, Pid).

login_change_socket(Pid, Socket) ->
    gen_server:cast(Pid, {login_change_socket, Socket}).

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
    {ok, #{socket => Socket,
           is_buff_data => 0,
           buff_data => <<>>,
           buff_data_length => 0,
           buff_total_length => 0}}.


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
    {noreply, State};

handle_cast(Cast, State) ->
    try
        handle_cast_inner(Cast, State)
    catch
        throw:ErrCode ->
            net_send:send_errcode(ErrCode, State),
            {noreply, State};
        What:Error ->
            lager:error("error what ~p, Error ~p, stack ~p", 
                [What, Error, erlang:get_stacktrace()]),
            {noreply, State}        
    end.

handle_cast_inner({apply, {M, F, A}, _PlayerId}, State) ->
    {Op, NewState} = 
        case apply(M, F, A ++ [State]) of
            {OpResult, StateResult} ->
                {OpResult, StateResult};
            _ ->
                {ok, State}
        end,
    do_cache_op(Op, NewState),
    {noreply, NewState};

handle_cast_inner({kick, Reason}, State) ->
    {stop, Reason, State};

handle_cast_inner({login_change_socket, Socket}, #{socket := PreSocket} = State) ->
    gen_tcp:controlling_process(PreSocket, spawn(fun() -> ok end)),
    gen_tcp:controlling_process(Socket, self()),

    NewState = State#{socket := Socket},
    mod_account:handle_send_login_result(NewState),
    active_socket_inner(Socket),
    {noreply, NewState}.


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

handle_info({tcp, _Port, TcpData}, State) ->
    #{is_buff_data := IsBuffData,
      buff_data_length := BuffDataLength,
      buff_total_length := BuffTotalLength,
      buff_data := BuffData} = State,
    
    NewState = 
        case IsBuffData of
            1 ->
                ReceiveBuffLength = erlang:byte_size(TcpData),
                NewBuffDataLength = (ReceiveBuffLength + BuffDataLength),
                NewBuffData = <<BuffData/binary, TcpData/binary>>,
                case NewBuffDataLength >= BuffTotalLength of
                    true ->
                        do_recevie_over(NewBuffData, State);
                    false ->
                        State#{buff_data_length := NewBuffDataLength,
                               buff_data := NewBuffData}
                end;
            0 ->
                <<_PreData:24, Len:16, _ProtoId:16, ProtoData/binary>> = TcpData,
                ReceiveBuffLength = erlang:byte_size(ProtoData),
                case ReceiveBuffLength >= Len of
                    true ->
                        do_recevie_over(TcpData, State);
                    false ->
                        State#{is_buff_data := true,
                               buff_data_length := ReceiveBuffLength,
                               buff_total_length := Len,
                               buff_data := TcpData}
                end
        end,
    % lager:info("receive bianry ~p", [{PreData, Len, ProtoId, ProtoData}]),
    active_socket_inner(maps:get(socket, State)),
    {noreply, NewState};

handle_info(Info, State) ->
    lager:error("unhandle info ~p", [Info]),
    active_socket_inner(maps:get(socket, State)),
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
terminate(Reason, State) ->
    lager:info("player terminate Reason ~p", [Reason]),
    NewState = lib_player:handle_after_logout(State),
    lib_player:update_player(NewState),
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
    ActiveResult = inet:setopts(Socket, [{active, once}]),
    % lager:info("active result ~p", [ActiveResult]),
    ActiveResult.

do_proto(ProtoId, ProtoData, State) ->
    try
        {ProtoName, Module, Function} = b_proto_route:get(ProtoId),
        ProtoRecord = game_pb:decode(ProtoName, ProtoData),
        case Function of
            heart_beat ->
                ignore;
            get_head ->
                ignore;
            _ ->
                lager:info("receive proto ~p", [ProtoRecord])
        end,
        apply(Module, Function, [ProtoRecord, State])
    catch
        throw:ThrowError ->
            lager:debug("throw error ~p", [ThrowError]),
            net_send:send_errcode(ThrowError, State),
            {ok, State};
        What:Error ->
            lager:error("proto error what ~p, Error ~p, stack ~p", 
                    [What, Error, erlang:get_stacktrace()]),
            {ok, State}
    end.

do_recevie_over(Data, State) ->
    <<_PreData:24, _Len:16, ProtoId:16, ProtoData/binary>>} = TcpData,
    {Op, NewState} = do_proto(ProtoId, ProtoData, State),
    do_cache_op(Op, NewState),
    NewState#{is_buff_data => 0,
              buff_data => <<>>,
              buff_data_length => 0,
              buff_total_length => 0}.


