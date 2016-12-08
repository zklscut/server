%% @author zhangkl
%% @doc global_id_srv.
%% 2016

-module(global_id_srv).

-include("ets.hrl").

-export([init_global_id/0,
         generate_player_id/0,
         generate_room_id/0]).

%% ====================================================================
%% API functions
%% ====================================================================

init_global_id() ->
    init_player_id(),
    init_room_id(),
    ok.

generate_player_id() ->
    ets:update_counter(?ETS_GLOBAL_COUNTER, player, 1).

generate_room_id() ->
    ets:update_counter(?ETS_GLOBAL_COUNTER, room, 1).    

%%%====================================================================
%%% Internal functions
%%%====================================================================

init_player_id() ->
    lib_ets:update(?ETS_GLOBAL_COUNTER, player, 0).

init_room_id() ->
    lib_ets:update(?ETS_GLOBAL_COUNTER, room, 0).    