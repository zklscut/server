%% @author zhangkl@lilith
%% @doc sgame.
%% 2016

-module(sgame).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/0]).

start() ->
    application:start(syntax_tools),
    application:start(compiler),
    application:start(goldrush),
    application:start(sasl),
    application:start(lager),
    application:start(game).

%% ====================================================================
%% Internal functions
%% ====================================================================


