%% @author zhangkl
%% @doc mod_chat.
%% 2016

-module(mod_chat).
-export([public_speak/2,
         get_p_chat/2]).

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
			ReturnChat = Chat#p_chat{player_show_base = PlayerShowBase,
									 room_id = RoomId},
			Return = #m__chat__public_speak__s2l{chat = ReturnChat},
    		[net_send:send(Return, SendId) || SendId <- lib_room:get_player_room_player_list(Player) -- [PlayerId],
    			SendId =/= lib_player:get_player_id(Player)];
    	_ ->
    		ignore
    end,
    {ok, Player}.

get_p_chat(PChat, Player) ->
    PChat#p_chat{room_id = lib_room:get_player_room_id(Player),
                 player_show_base = lib_player:get_player_show_base(Player)}.

%%%====================================================================
%%% Internal functions
%%%====================================================================