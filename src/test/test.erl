%% @author zhangkl@lilith
%% @doc test.
%% 2016

-module(test).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0, send/1, stop/1, recv/1]).

start() ->
    {ok, Sock} = gen_tcp:connect("localhost", 19000,
                                 [{active, false}, {packet, 0}]),
    Sock.

send(Socket) ->
    Encode = game_pb:encode({m__account__login__l2s, 10001, "test"}),
    gen_tcp:send(Socket, <<1:24, Encode/binary>>).

stop(Socket) ->
    gen_tcp:close(Socket).

recv(Socket) ->
    {ok, Data} = gen_tcp:recv(Socket, 0),
    game_pb:decode(m__account__login__s2l, list_to_binary(Data)).



%% ====================================================================
%% Internal functions
%% ====================================================================


