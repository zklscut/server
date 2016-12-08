%% @author zhangkl@lilith
%% @doc test.
%% 2016

-module(test).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0, send/1, stop/1, recv/1]).

start() ->
    {ok, Sock} = gen_tcp:connect("112.74.183.119", 19000,
                                 [{active, false}, {packet, 0}]),
    Sock.

send(Socket) ->
    Encode = game_pb:encode({m__account__login__l2s, 10001, "test"}),
    gen_tcp:send(Socket, <<1:24, 1:16, 10001:16,Encode/binary>>).

stop(Socket) ->
    gen_tcp:close(Socket).

recv(Socket) ->
    {ok, List} = gen_tcp:recv(Socket, 0),
    <<_:24, Len:16, ProtoId:16, Binary/binary>> = list_to_binary(List),
    {Len, ProtoId, game_pb:decode(m__account__login__s2l, Binary)}.



%% ====================================================================
%% Internal functions
%% ====================================================================


