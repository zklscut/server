%% @author zhangkl@lilith
%% @doc game_app.
%% 2016

-module(game_app).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/2]).

start(_, _) ->
    {ok, SupPid} = game_supervisor:start_link(),
    tcp_listener:start(),
    lager:info("start game"),
    {ok, SupPid}.

%% ====================================================================
%% Internal functions
%% ====================================================================


