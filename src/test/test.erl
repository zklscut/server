%% @author zhangkl@lilith
%% @doc test.
%% 2016

-module(test).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0, send/2, stop/1]).

start() ->
    {ok, Sock} = gen_tcp:connect("localhost", 19000,
                                 [{active, false}, {packet, 0}]),
    Sock.

send(Socket, Content) ->
    gen_tcp:send(Socket, Content).

stop(Socket) ->
    gen_tcp:close(Socket).


%% ====================================================================
%% Internal functions
%% ====================================================================


