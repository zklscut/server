%% @author zhangkl
%% @doc player_srv.
%% 2016

-module(lib_player).

-include("ets.hrl").
-include("game_pb.hrl").

-export([handle_after_login/1,
         handle_after_logout/1,
         get_player/1,
         get_player_pid/1,
         get_player_show_base/1,
         get_player_id/1]).


%% ====================================================================
%% API functions
%% ====================================================================

handle_after_login(#{id := PlayerId} = Player) ->
    lib_ets:update(?ETS_PLAYER_PID, PlayerId, self()),
    Player.

handle_after_logout(#{id := PlayerId} = Player) ->
    lib_ets:delete(?ETS_PLAYER_PID, PlayerId),
    Player.

get_player_pid(PlayerId) ->
    lib_ets:get(?ETS_PLAYER_PID, PlayerId).

get_player(PlayerId) ->
    lib_ets:get(?ETS_PLAYER, PlayerId).

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