%% @author zhangkl@lilith
%% @doc tcp_listener.
%% 2016

-module(tcp_listener).

-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, 
                      {reuseaddr, true}, {nodelay, false}, 
                      {delay_send, true}, {send_timeout, 50000}, 
                      {keepalive, true}, {exit_on_close, true}
                     ]).
-define(LISTENER_PROCESS_NUM, 5).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0,
         start_listener_process/1]).

start() ->
    start_tcp_supervisor(),
    start_listener().

start_listener_process(LS) ->
    spawn(fun() ->
            case gen_tcp:accept(LS) of
              {ok, S} ->
                loop(S),
                start_listener_process(LS);
              _Other ->
                ok
            end
          end).

%% ====================================================================
%% Internal functions
%% ====================================================================

start_tcp_supervisor() ->
    supervisor:start_child(game_supervisor,
                           {tcp_supervisor, {tcp_supervisor, start_link,[]},
                            transient, infinity, supervisor, [tcp_supervisor ]}).

start_listener() ->
    {ok, MainPort} = application:get_env(main_port),
    io:format("main_port ~p~n", [MainPort]),
    case gen_tcp:listen(MainPort, ?TCP_OPTIONS) of
        {ok, ListenSock} ->
            start_servers(?LISTENER_PROCESS_NUM, ListenSock),
            {ok, Port} = inet:port(ListenSock),
            Port;
        {error, Reason} ->
            {error, Reason}
    end.

start_servers(0,_) ->
    ok;
start_servers(Num, LS) ->
    spawn(fun() ->
                  supervisor:start_child(tcp_supervisor, [LS])
          end),
    start_servers(Num - 1, LS).

loop(S) ->
    inet:setopts(S, [{active, once}]),
    receive
        {tcp, S, Data} ->
            io:format("data ~p ~n", [Data]),
            gen_tcp:send(S, <<2>>),
            loop(S);
        {tcp_closed, S} ->
            ok
    end.
