%% @author zhangkl
%% @doc mod_chat.
%% 2016

-module(mod_chat).
-export([public_speak/2,
         get_p_chat/2,
         send_system_room_chat/3]).

-include("game_pb.hrl").
-include("chat.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

public_speak(#m__chat__public_speak__l2s{chat = Chat}, Player) ->
	ChatType = Chat#p_chat.chat_type,
    PlayerId = lib_player:get_player_id(Player),
	PlayerShowBase = lib_player:get_player_show_base(Player),
	case ChatType of
		?CHAT_TYPE_ROOM ->
			RoomId = lib_room:get_player_room_id(Player),
            case lib_room:is_in_fight(RoomId) of
                false->
        			ReturnChat = Chat#p_chat{player_show_base = PlayerShowBase,
        									 room_id = RoomId},
        			Return = #m__chat__public_speak__s2l{chat = ReturnChat},
            		[net_send:send(Return, SendId) || SendId <- lib_room:get_player_room_player_list(Player) -- [PlayerId],
            			SendId =/= lib_player:get_player_id(Player)];
                _->
                    ignore
            end;
    	_ ->
    		ignore
    end,
    {ok, Player}.

get_p_chat(PChat, Player) ->
    PChat#p_chat{room_id = lib_room:get_player_room_id(Player),
                 player_show_base = lib_player:get_player_show_base(Player)}.

send_system_room_chat(MsgType, Content, RoomId) ->
    PChat = #p_chat{voice = <<>>,
                    content = Content,
                    length = 0,
                    compress = 0,
                    chat_type = 2,
                    room_id = RoomId,
                    msg_type = MsgType},
    Return = #m__chat__public_speak__s2l{chat = PChat},
    Room = lib_room:get_room(RoomId),
    [net_send:send(Return, SendId) || SendId <- maps:get(player_list, Room)].

%%%====================================================================
%%% Internal functions
%%%====================================================================