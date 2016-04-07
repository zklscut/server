%% @author zhangkl@lilith
%% @doc test.
%% 2016

-module(test).

%% ====================================================================
%% API functions
%% ====================================================================
-export([test_connect/0]).

test_connect() ->
    {ok,Sock} = gen_tcp:connect("localhost", 19000,
                                [{active, false}, {packet, 0}]),
    gen_tcp:send(Sock, <<1>>),
    A = gen_tcp:recv(Sock, 0),
    io:format("rec ~p ~n", [A]),
    gen_tcp:close(Sock),
    A.

%% ====================================================================
%% Internal functions
%% ====================================================================


