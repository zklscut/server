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
    start_tcp_supervisor(),
    tcp_listener:start(),
    start_player_supervisor(),
    
    lager:info("start game"),
    {ok, SupPid}.

%% ====================================================================
%% Internal functions
%% ====================================================================

start_tcp_supervisor() ->
    supervisor:start_child(game_supervisor,
                           {tcp_supervisor, {tcp_supervisor, start_link,[]},
                            transient, infinity, supervisor, [tcp_supervisor]}).

start_player_supervisor() ->
    supervisor:start_child(game_supervisor,
                           {player_supervisor, {player_supervisor, start_link,[]},
                            transient, infinity, supervisor, [tcp_supervisor]}).
