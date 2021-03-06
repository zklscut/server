%% @author zhangkl
%% @doc mod_fight.
%% 2016

-module(mod_fight).
-export([notice_op/2,
		 speak/2]).

-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

notice_op(#m__fight__notice_op__l2s{op = Op,
									op_list = OpList}, Player) ->
	fight_srv:player_op(lib_room:get_fight_pid_by_player(Player), 
		lib_player:get_player_id(Player), Op, OpList),
	{ok, Player}.

speak(#m__fight__speak__l2s{chat = PChat}, Player) ->
    fight_srv:player_speak(lib_room:get_fight_pid_by_player(Player), 
        lib_player:get_player_id(Player), PChat),
    {ok, Player}.

%%%====================================================================
%%% Internal functions
%%%====================================================================