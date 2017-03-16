%% @author zhangkl
%% @doc mod_room.
%% 2016

-module(mod_room).
-export([get_list/2,
         enter_room/2,
         handle_enter_room/2,
         create_room/2,
         handle_create_room/2,
         leave_room/2,
         handle_leave_room/1,
         start_fight/2,
         notice_team_change/1,
         send_to_room/2,
         want_chat/2,
         end_chat/2,
         want_chat_list/2,
         send_gift/2,
         kick_player/2,
         handle_kick_player/2,
         send_to_player/2,
         ready/2,
         cancle_ready/2,
         update_chat_list/1
         ]).

-include("game_pb.hrl").
-include("ets.hrl").
-include("errcode.hrl").
-include("resource.hrl").
-include("room.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

get_list(#m__room__get_list__l2s{}, Player) ->
    PRoomList = [conver_to_p_room(Room) || {_, Room} <- ets:tab2list(?ETS_ROOM)],
    Return = #m__room__get_list__s2l{room_list = PRoomList},
    net_send:send(Return, Player),
    {ok, Player}.



enter_room(#m__room__enter_room__l2s{room_id = RoomId}, Player) ->
    lib_room:assert_not_have_room(Player),
    lib_room:assert_room_exist(RoomId),
    Room = lib_room:get_room(RoomId),
    case lib_room:is_room_full(Room) of
        true->
            send_to_player(#m__room__enter_fail__s2l{}, Player);
        _->
            room_srv:enter_room(RoomId, Player)
    end,
    {ok, Player}.

enter_simple_room(#m__room__enter_simple_room__l2s{}, Player)
    Room = get_not_full_simple_room(),
    case Room of
        undefined->
            room_srv:create_room(length(?ROOM_SIMPLE_DUTY_LIST), "test", ?ROOM_SIMPLE_DUTY_LIST, Player);
        _->
            room_srv:enter_room(maps:get(room_id, Room), Player)
    end.

handle_enter_room(Room, Player) ->
    #{player_list := PlayerList,
      room_id := RoomId} = Room,
    MemberList = [lib_player:get_player_show_base(PlayerId) ||
      PlayerId <- PlayerList],

    Return = #m__room__enter_room__s2l{room_info = conver_to_p_room(Room),
                                       member_list = MemberList},
    net_send:send(Return, Player),                                      

    NewPlayer = lib_room:update_player_room_id(RoomId, Player),
    {save, NewPlayer}.

create_room(#m__room__create_room__l2s{max_player_num = MaxPlayerNum,
                                       room_name = RoomName,
                                       duty_list = DutyList}, Player) ->
    lib_room:assert_not_have_room(Player),
    room_srv:create_room(MaxPlayerNum, RoomName, DutyList, Player),
    {ok, Player}.

handle_create_room(Room, Player) ->
    #{room_id := RoomId} = Room,
    NewPlayer = lib_room:update_player_room_id(RoomId, Player),

    Return = #m__room__create_room__s2l{room_info = conver_to_p_room(Room)},
    net_send:send(Return, Player),
    {save, NewPlayer}.    

leave_room(#m__room__leave_room__l2s{}, Player) ->
    fight_srv:player_leave(lib_player:get_fight_pid(Player), lib_player:get_player_id(Player)),
    {ok, Player}.

handle_leave_room(Player) ->
    % Return = #m__room__leave_room__s2l{},
    % net_send:send(Return, Player),
    PlayerAfterLeaveRoom = lib_room:update_player_room_id(0, Player),
    lib_player:update_fight_pid(undefined, PlayerAfterLeaveRoom).

handle_kick_player(OpName, Player)->
    Send = #m__room__kick_player__s2l{player_name = OpName, 
                        result = 0,
                        kicked_player_id = lib_player:get_player_id(Player)},
    net_send:send(Send, Player),
    PlayerAfterLeaveRoom = lib_room:update_player_room_id(0, Player),
    lib_player:update_fight_pid(undefined, PlayerAfterLeaveRoom).

get_kick_player_fail_result(KickedPlayerId, OpPlayerId, KickedPlayerRoomId, OpPlayerRoomId)->
    case KickedPlayerId == OpPlayerId of
        true->
            2;
        false->
            case KickedPlayerRoomId =/= 0 of
                true->
                    3;
                false->
                    case KickedPlayerRoomId =/= OpPlayerRoomId of
                        true->
                            1;
                        false->
                            4
                    end
            end
    end.

kick_player(#m__room__kick_player__l2s{kicked_player_id = KickedPlayerId}, Player)->
    KickedPlayer = lib_player:get_player(KickedPlayerId),
    KickedPlayerRoomId = maps:get(room_id, KickedPlayer, 0),
    OpPlayerRoomId = maps:get(room_id, Player, 0),
    OpPlayerId = lib_player:get_player_id(Player),
    case KickedPlayerRoomId =/= 0 andalso KickedPlayerRoomId == OpPlayerRoomId 
                    andalso KickedPlayerId =/= OpPlayerId andalso OpPlayerRoomId =/= 0  of
        true->
            room_srv:kick_player(KickedPlayer, Player);
        _->
            Send = #m__room__kick_player__s2l{player_name = lib_player:get_name(Player), 
                        kicked_player_id = KickedPlayerId, result = 
                        get_kick_player_fail_result(KickedPlayerId, OpPlayerId, KickedPlayerRoomId, OpPlayerRoomId)},
            net_send:send(Send, Player)
    end,
    {ok, Player}.

start_fight(#m__room__start_fight__l2s{}, Player) ->
    lager:info("start_fight+++++++++++ ~p", [Player]),
    RoomId = lib_room:get_player_room_id(Player),
    PlayerList = lib_room:get_player_room_player_list(Player),
    DutyList = lib_room:get_room_duty_list(RoomId),
    RoomName = lib_room:get_room_name(RoomId),
    fight_srv:start_link(RoomId, PlayerList, DutyList, RoomName),
    {ok, Player}.

send_gift(#m__room__send_gift__l2s{    
                                        player_id = ReceivePlayerId, 
                                        gift_id = GiftId      
                                    }, Player)->
    %%判断送礼包条件是否成立
    {Coin, Diamond} = b_gift_consume:get(GiftId),
    CoinEnough = mod_resource:is_enough(?RESOURCE_COIN, Coin, Player),
    DiamondEnough = mod_resource:is_enough(?RESOURCE_DIAMOND, Diamond, Player),
    case CoinEnough and DiamondEnough of 
        true->
            RoomId = lib_room:get_player_room_id(Player),
            Room = lib_room:get_room(RoomId),
            mod_player:handle_consume_gift(GiftId, lib_player:get_player_id(Player)),
            mod_player:handle_receive_gift(GiftId, ReceivePlayerId),
            {_Op, LuckNum}= b_gift_effects:get(GiftId),
            send_to_room(#m__room__send_gift__s2l{
                    result = 1,
                    gift_id = GiftId,
                    luck_add = LuckNum,
                    player_id = ReceivePlayerId
                }, Room);    
        false->
            send_to_player(#m__room__send_gift__s2l{
                    result = 0,
                    gift_id = GiftId,
                    luck_add = 0,
                    player_id = ReceivePlayerId
                }, Player)
    end,
    {ok, Player}.

want_chat(#m__room__want_chat__l2s{}, Player) ->
    room_srv:want_chat(Player),
    {ok, Player}.

end_chat(#m__room__end_chat__l2s{}, Player) ->
    room_srv:end_chat(Player),
    {ok, Player}. 

want_chat_list(#m__room__want_chat_list__l2s{}, Player)->
    send_chat_list(Player),
    {ok, Player}.

notice_team_change(Room)->
    #{player_list := PlayerList} = Room,
    MemberList = [lib_player:get_player_show_base(PlayerId) || PlayerId <- PlayerList],

    Send = #m__room__notice_member_change__s2l{room_info = conver_to_p_room(Room),
                                                 member_list = MemberList},
    send_to_room(Send, Room).

update_chat_list(Room)->
    [send_chat_list(lib_player:get_player(PlayerId)) || PlayerId <- maps:get(player_list, Room)].

send_chat_list(Player)->
    RoomId = maps:get(room_id, Player, 0),
    lib_room:assert_room_exist(RoomId),
    Room = lib_room:get_room(RoomId),
    WantChatList = maps:get(want_chat_list, Room),
    WaitList = [lib_player:get_name(PlayerId) || PlayerId<-WantChatList],
    Send = #m__room__want_chat_list__s2l{wait_list = WaitList},
    send_to_player(Send, Player).

send_to_room(Send, Room) ->
    #{player_list := PlayerList} = Room,
    [net_send:send(Send, PlayerId) || PlayerId <- PlayerList].

send_to_player(Send, PlayerId)  when is_integer(PlayerId)  ->
    net_send:send(Send, PlayerId);

send_to_player(Send, Player) ->
    net_send:send(Send, Player).

ready(#m__room__ready__l2s{}, Player) ->
    RoomId = lib_room:get_player_room_id(Player),
    case lib_room:is_in_fight(RoomId) of
        false->
            room_srv:ready(RoomId, lib_player:get_player_id(Player));
        _->
            ignore
    end,
    {ok, Player}.

cancle_ready(#m__room__cancle_ready__l2s{}, Player) ->
    RoomId = lib_room:get_player_room_id(Player),
    case lib_room:is_in_fight(RoomId) of
        false->
            room_srv:cancle_ready(RoomId, lib_player:get_player_id(Player));
        _->
            ignore
    end,
    {ok, Player}.

%%%====================================================================
%%% Internal functions
%%%====================================================================

get_not_full_simple_room()->
    RoomList = ets:tab2list(?ETS_ROOM),
    Func = fun({_,CurRoom}, Ignore)->
                IsSimple = maps:get(is_simple, CurRoom),
                case IsSimple andalso (length(maps:get(player_list, CurRoom)) < maps:get(max_player_num, CurRoom)) of
                    true->
                        throw(CurRoom);
                    _
                        Ignore
                end
            end,
    try
        lists:foldl(Func, 1, RoomList),
        undefined
    catch
        throw:Room ->
            Room;
        _:_ ->
            undefined
    end.

conver_to_p_room(#{room_id := RoomId,
                   owner := Owner,
                   player_list := PlayerList,
                   max_player_num := MaxPlayerNum,
                   room_name := RoomName,
                   room_status := RoomStatus,
                   duty_list := DutyList,
                   ready_list := ReadyList}) ->
    #p_room{room_id = RoomId,
            cur_player_num = length(PlayerList),
            max_player_num = MaxPlayerNum,
            owner = Owner,
            room_name = RoomName,
            room_status = RoomStatus,
            duty_list = DutyList,
            ready_list = ReadyList}.

