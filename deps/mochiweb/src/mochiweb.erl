%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc mochiweb.

-module(mochiweb).
-author("Mochi Media <dev@mochimedia.com>").
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.


%% @spec start() -> ok
%% @doc Start the mochiweb server.
start() ->
    mochiweb_deps:ensure(),
    ensure_started(crypto),
    application:start(mochiweb).


%% @spec stop() -> ok
%% @doc Stop the mochiweb server.
stop() ->
    application:stop(mochiweb).
