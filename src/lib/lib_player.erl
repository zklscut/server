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
         get_player_id/1,
         update_fight_pid/2,
         is_in_fight/1,
         get_fight_pid/1,
         get_name/1,
         is_online/1]).


%% ====================================================================
%% API functions
%% ====================================================================

handle_after_login(#{id := PlayerId} = Player) ->
    lib_ets:update(?ETS_PLAYER_PID, PlayerId, self()),
    lib_room:handle_online(Player),
    fight_srv:player_online(Player),
    Player.

handle_after_logout(#{id := PlayerId} = Player) ->
    lib_ets:delete(?ETS_PLAYER_PID, PlayerId),
    % match_srv:offline_match(PlayerId),
    lib_match:offline_match(PlayerId),
    fight_srv:player_offline(Player),
    case is_in_fight(Player) of
        true->
            Player;
        false->
            room_srv:leave_room(Player),
            lib_room:update_player_room_id(0, Player)
    end;

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
    Data = maps:get(data, Player),
    #p_player_show_base{player_id = PlayerId,
                        gvoice_status = maps:get(gvoice_status, Player, 0),
                        head_img_name = maps:get(head_img_name, Data, ""),%%maps:get(head_img_name, Player, ""),
                        nick_name = maps:get(nick_name, Player)}.

get_player_id(Player) ->
    maps:get(id, Player, 0).

update_fight_pid(Pid, Player) ->
    NewPlayer = Player#{fight_pid=>Pid},
    {save, NewPlayer}.

is_in_fight(Player) ->
    Pid = maps:get(fight_pid, Player, undefined),
    Pid =/= undefined andalso is_process_alive(Pid) == true.

get_fight_pid(Player) ->
    case is_in_fight(Player) of
        true ->
            maps:get(fight_pid, Player);
        false ->
            undefined
    end.

get_name(PlayerId) when is_integer(PlayerId) ->
    get_name(get_player(PlayerId));

get_name(Player) ->
    maps:get(nick_name, Player).

is_online(PlayerId) ->
    lib_ets:get(?ETS_PLAYER_PID, PlayerId) =/= undefined.

%%%====================================================================
%%% Internal functions
%%%====================================================================