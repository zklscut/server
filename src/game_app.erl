%% @author zhangkl@lilith
%% @doc game_app.
%% 2016

-module(game_app).

-include("db.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/2]).

start(_, _) ->
    {ok, SupPid} = game_supervisor:start_link(),
    start_game_db(),
    start_player_supervisor(),
    start_cache_process(),
    ok = global_id_srv:init_global_id(),
    start_room_process(),
    start_global_op_process(),
    start_cache_store_server(),
    
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

start_global_op_process() ->
    supervisor:start_child(game_supervisor,
                           {global_op_srv, {global_op_srv, start_link,[]},
                            transient, infinity, worker, [global_op_srv]}).     

start_cache_store_server() ->
    cache_store_bhv:start_link(cache_store_player, 10000).

start_game_db() ->
    {ok, DBUser} = application:get_env(db_user),
    {ok, DBPwd} = application:get_env(db_pwd),
    {ok, DBHost} = application:get_env(db_host),
    emysql:add_pool(?DB_WRITE, 10, DBUser, DBPwd, DBHost, 3306, "game", utf8).
