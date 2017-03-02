%% @author Mochi Media <dev@mochimedia.com>
%% @copyright mochiweb Mochi Media <dev@mochimedia.com>

%% @doc Callbacks for the mochiweb application.

-module(mochiweb_app).
-author("Mochi Media <dev@mochimedia.com>").

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for mochiweb.
start(_Type, _StartArgs) ->
    mochiweb_deps:ensure(),
    mochiweb_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for mochiweb.
stop(_State) ->
    ok.
