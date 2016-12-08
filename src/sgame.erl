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
    application:start(game).

stop() ->
    application:start(game),
    application:start(lager).

%% ====================================================================
%% Internal functions
%% ====================================================================


