%% @author zhangkl
%% @doc mod_chat.
%% 2016

-module(mod_chat).
-export([public_speak/2]).

-include("game_pb.hrl").
-include("chat.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

public_speak(#m__chat__public_speak__l2s{chat = Chat}, Player) ->
	ChatType = Chat#p_chat.chat_type,
	PlayerShowBase = lib_player:get_player_show_base(Player),
	case ChatType of
		?CHAT_TYPE_ROOM ->
			RoomId = lib_room:get_player_room_id(Player),
			ReturnChat = Chat#p_chat{player_show_base = PlayerShowBase,
									 room_id = RoomId},
			Return = #m__chat__public_speak__s2l{chat = ReturnChat},
    		[net_send:send(Return, SendId) || SendId <- lib_room:get_player_room_player_list(Player),
    			SendId =/= lib_player:get_player_id(Player)];
    	_ ->
    		ignore
    end,
    {ok, Player}.

%%%====================================================================
%%% Internal functions
%%%====================================================================