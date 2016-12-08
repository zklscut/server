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
    start_player_supervisor(),
    start_cache_process(),
    ok = global_id_srv:init_global_id(),
    start_room_process(),

    %% keep last
    start_tcp_supervisor(),
    tcp_listener:start(),
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
                            transient, infinity, supervisor, [player_supervisor]}).

start_cache_process() ->
    supervisor:start_child(game_supervisor,
                           {ets_srv, {ets_srv, start_link,[]},
                            transient, infinity, worker, [ets_srv]}).    

start_room_process() ->
    supervisor:start_child(game_supervisor,
                           {room_srv, {room_srv, start_link,[]},
                            transient, infinity, worker, [room_srv]}).        