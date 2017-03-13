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
    start_match_process(),
    start_rank_server(),
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

start_match_process() ->
    supervisor:start_child(game_supervisor,
                           {match_srv, {match_srv, start_link,[]},
                            transient, infinity, worker, [match_srv]}).    

start_cache_store_server() ->
    cache_store_bhv:start_link(cache_store_player, 10000).

start_langren_rank_server() ->
    supervisor:start_child(game_supervisor,
                           {langren_rank_srv, {rank_behaviour, start_link,[langren_rank_srv]},
                            transient, infinity, worker, [langren_rank_srv]}). 

start_nvwu_rank_server() ->
    supervisor:start_child(game_supervisor,
                           {nvwu_rank_srv, {rank_behaviour, start_link,[nvwu_rank_srv]},
                            transient, infinity, worker, [nvwu_rank_srv]}).  

start_yuyanjia_rank_server() ->
    supervisor:start_child(game_supervisor,
                           {yuyanjia_rank_srv, {rank_behaviour, start_link,[yuyanjia_rank_srv]},
                            transient, infinity, worker, [yuyanjia_rank_srv]}).   

start_lieren_rank_server() ->
    supervisor:start_child(game_supervisor,
                           {lieren_rank_srv, {rank_behaviour, start_link,[lieren_rank_srv]},
                            transient, infinity, worker, [lieren_rank_srv]}).        

start_pinming_rank_server() ->
    supervisor:start_child(game_supervisor,
                           {pinming_rank_srv, {rank_behaviour, start_link,[pinming_rank_srv]},
                            transient, infinity, worker, [pinming_rank_srv]}). 

start_rank_rank_server() ->
    supervisor:start_child(game_supervisor,
                           {rank_rank_srv, {rank_behaviour, start_link,[rank_rank_srv]},
                            transient, infinity, worker, [rank_rank_srv]}). 

start_luck_rank_server() ->
    supervisor:start_child(game_supervisor,
                           {luck_rank_srv, {rank_behaviour, start_link,[luck_rank_srv]},
                            transient, infinity, worker, [luck_rank_srv]}). 

start_mvp_rank_server() ->
    supervisor:start_child(game_supervisor,
                           {mvp_rank_srv, {rank_behaviour, start_link,[mvp_rank_srv]},
                            transient, infinity, worker, [mvp_rank_srv]}).

start_fighting_rank_server() ->
    supervisor:start_child(game_supervisor,
                           {fighting_rank_srv, {rank_behaviour, start_link,[fighting_rank_srv]},
                            transient, infinity, worker, [fighting_rank_srv]}).

start_game_db() ->
    {ok, DBUser} = application:get_env(db_user),
    {ok, DBPwd} = application:get_env(db_pwd),
    {ok, DBHost} = application:get_env(db_host),
    {ok, DBName} = application:get_env(db_name),
    emysql:add_pool(?DB_WRITE, 10, DBUser, DBPwd, DBHost, 3306, DBName, utf8).
