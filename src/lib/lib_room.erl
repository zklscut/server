%% @author zhangkl
%% @doc lib_room.
%% 2016

-module(lib_room).
-export([get_room/1,
         update_room/2,
         delete_room/1,
         get_player_room_id/1,
         update_player_room_id/2,
         assert_not_have_room/1,
         assert_room_not_full/1,
         assert_room_exist/1,
         assert_have_room/1,
         is_room_owner/2,
         get_player_room_player_list/1,
         update_fight_pid/2,
         get_fight_pid_by_player/1,
         get_room_duty_list/1,
         is_in_fight/1,
         handle_online/1,
         update_room_status/5]).

-include("game_pb.hrl").
-include("ets.hrl").
-include("errcode.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

get_room(RoomId) ->
    lib_ets:get(?ETS_ROOM, RoomId).

update_room(RoomId, Room) ->
    lib_ets:update(?ETS_ROOM, RoomId, Room).

delete_room(RoomId) ->
    lib_ets:delete(?ETS_ROOM, RoomId).

get_player_room_id(Player) ->
    maps:get(room_id, Player, 0).

update_player_room_id(RoomId, Player) ->
    maps:put(room_id, RoomId, Player).

assert_not_have_room(Player) ->
    case lib_room:get_player_room_id(Player) of
        0 ->
            ok;
        _ ->
            throw(?ERROR)
    end.

assert_room_not_full(Room) ->
    #{max_player_num := MaxPlayerNum,
      player_list := PlayerList} = Room,
    case length(PlayerList) >= MaxPlayerNum of
        true ->
            throw(?ERROR);
        false ->
            ok
    end.

assert_room_exist(RoomId) ->
    case get_room(RoomId) of
        undefined ->
            throw(?ERROR);
        _ ->
            ok
    end.

assert_have_room(Player) ->
    case lib_room:get_player_room_id(Player) of
        0 ->
            throw(?ERROR);
        _ ->
            ok
    end.

is_room_owner(PlayerId, Room) ->
    #{owner := OwnerShow} = Room,
    OwnerShow#p_player_show_base.player_id == PlayerId.

get_player_room_player_list(Player) ->
    case get_room(get_player_room_id(Player)) of
        undefined ->
            [];
        Room ->
            maps:get(player_list, Room)
    end.

update_fight_pid(RoomId, Pid) ->
    case get_room(RoomId) of
        undefined ->
            ignore;
        Room ->
            [global_op_srv:player_op(PlayerId, {lib_player, update_fight_pid, [Pid]}) || PlayerId <- maps:get(player_list, Room)],
            room_srv:update_room_fight_pid(RoomId, Pid)
    end.

%%如果是白天night传1如果是晚上day传0
update_room_status(RoomId, BaseStatus, GameRound, Night, Day)->
    room_srv:update_room_status(RoomId, BaseStatus, GameRound, Night, Day).

is_in_fight(RoomId) ->
    case get_room(RoomId) of
        undefined ->
            false;
        Room ->
            Pid = maps:get(fight_pid, Room, undefined),
            Pid =/= undefined andalso is_process_alive(Pid) == true
    end.

get_fight_pid_by_player(Player) ->
    maps:get(fight_pid, get_room(get_player_room_id(Player))).

get_room_duty_list(RoomId) ->
    maps:get(duty_list, get_room(RoomId)).

handle_online(Player) ->
    RoomId = maps:get(room_id, Player, 0),
    lager:info("handle_online ~p", [RoomId]),
    case RoomId of
        0 ->
            mod_room:send_to_player(#m__room__login_not_in_room__s2l{}, Player);
        _ ->
            Room = lib_room:get_room(RoomId),
            mod_room:notice_team_change(Room)
    end.

%%%====================================================================
%%% Internal functions
%%%====================================================================