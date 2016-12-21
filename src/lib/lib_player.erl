%% @author zhangkl
%% @doc lib_player.
%% 2016

-module(lib_player).

-include("ets.hrl").
-include("game_pb.hrl").

-export([handle_after_login/1,
         handle_after_logout/1,
         get_player/1,
         update_player/1,
         get_player_pid/1,
         get_player_show_base/1,
         get_player_id/1]).


%% ====================================================================
%% API functions
%% ====================================================================

handle_after_login(#{id := PlayerId} = Player) ->
    lib_ets:update(?ETS_PLAYER_PID, PlayerId, self()),
    Player.

handle_after_logout(Player) ->
    PlayerId = get_player_id(Player),
    lib_ets:delete(?ETS_PLAYER_PID, PlayerId),
    room_srv:leave_room(Player),
    lib_room:update_player_room_id(0, Player);

handle_after_logout(Player) ->
    Player.

get_player_pid(PlayerId) ->
    lib_ets:get(?ETS_PLAYER_PID, PlayerId).

get_player(PlayerId) ->
    cache_store_bhv:read(cache_store_player, PlayerId).

update_player(Player) ->
    cache_store_bhv:write(cache_store_player, {get_player_id(Player), Player}).

get_player_show_base(PlayerId) when is_integer(PlayerId) ->
    get_player_show_base(get_player(PlayerId));

get_player_show_base(Player) ->
    PlayerId = maps:get(id, Player),
    #p_player_show_base{player_id = PlayerId,
                        nick_name = integer_to_list(PlayerId)}.

get_player_id(Player) ->
    maps:get(id, Player).

%%%====================================================================
%%% Internal functions
%%%====================================================================