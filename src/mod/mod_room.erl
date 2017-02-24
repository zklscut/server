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
         send_gift/2]).

-include("game_pb.hrl").
-include("ets.hrl").
-include("errcode.hrl").
-include("resource.hrl").

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
    room_srv:enter_room(RoomId, Player),
    {ok, Player}.

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
    lib_room:assert_have_room(Player),
    room_srv:leave_room(Player),
    {ok, Player}.

handle_leave_room(Player) ->
    Return = #m__room__leave_room__s2l{},
    net_send:send(Return, Player),
    {save, lib_room:update_player_room_id(0, Player)}.

start_fight(#m__room__start_fight__l2s{}, Player) ->
    RoomId = lib_room:get_player_room_id(Player),
    PlayerList = lib_room:get_player_room_player_list(Player),
    DutyList = lib_room:get_room_duty_list(RoomId),
    fight_srv:start_link(RoomId, PlayerList, DutyList),
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
            mod_player:handle_receive_gift(GiftId, lib_player:get_player_id(Player)),
            send_to_room(#m__room__send_gift__s2l{
                    result = 1,
                    gift_id = GiftId,
                    luck_add = b_gift_effects:get(GiftId),
                    player_id = ReceivePlayerId
                }, Room);    
        false->
            send_to_player(#m__room__send_gift__s2l{
                    result = 0,
                    gift_id = GiftId,
                    player_id = ReceivePlayerId
                }, Player)
    end,
    {ok, Player}.

notice_team_change(Room) ->
    #{player_list := PlayerList} = Room,
    MemberList = [lib_player:get_player_show_base(PlayerId) || PlayerId <- PlayerList],

    Send = #m__room__notice_member_change__s2l{room_info = conver_to_p_room(Room),
                                                 member_list = MemberList},
    send_to_room(Send, Room).

send_to_room(Send, Room) ->
    #{player_list := PlayerList} = Room,
    [net_send:send(Send, PlayerId) || PlayerId <- PlayerList].

send_to_player(Send, PlayerId)  when is_integer(PlayerId)  ->
    net_send:send(Send, PlayerId);

send_to_player(Send, Player) ->
    net_send:send(Send, Player).

want_chat(#m__room__want_chat__l2s{}, Player) ->
    room_srv:want_chat(Player),
    {ok, Player}.

end_chat(#m__room__end_chat__l2s{}, Player) ->
    room_srv:end_chat(Player),
    {ok, Player}. 

want_chat_list(#m__room__want_chat_list__l2s{}, Player)->
    RoomId = maps:get(room_id, Player, 0),
    lib_room:assert_room_exist(RoomId),
    Room = lib_room:get_room(RoomId),
    WantChatList = maps:get(want_chat_list, Room),
    WaitList = [lib_player:get_name(PlayerId) || PlayerId<-WantChatList],
    Send = #m__room__want_chat_list__s2l{wait_list = WaitList},
    net_send:send(Send, Player),
    {ok, Player}.   

%%%====================================================================
%%% Internal functions
%%%====================================================================

conver_to_p_room(#{room_id := RoomId,
                   owner := Owner,
                   player_list := PlayerList,
                   max_player_num := MaxPlayerNum,
                   room_name := RoomName,
                   room_status := RoomStatus,
                   duty_list := DutyList}) ->
    #p_room{room_id = RoomId,
            cur_player_num = length(PlayerList),
            max_player_num = MaxPlayerNum,
            owner = Owner,
            room_name = RoomName,
            room_status = RoomStatus,
            duty_list = DutyList}.

