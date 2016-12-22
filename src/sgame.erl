%% @author zhangkl@lilith
%% @doc sgame.
%% 2016

-module(sgame).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0, stop/0]).

start() ->
    application:start(syntax_tools),
    application:start(compiler),
    application:start(goldrush),
    application:start(sasl),
    application:start(lager),
    Result = application:start(emysql),
    io:format("start emysql res ~p~n",[Result]),
    application:start(game).

stop() ->
    application:stop(game),
    application:stop(emysql),
    application:stop(lager).

%% ====================================================================
%% Internal functions
%% ====================================================================


