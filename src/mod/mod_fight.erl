%% @author zhangkl
%% @doc mod_fight.
%% 2016

-module(mod_fight).
-export([notice_op/2,
		 speak/2,
         do_skill/2]).

-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

notice_op(#m__fight__notice_op__l2s{op = Op,
									op_list = OpList}, Player) ->
	fight_srv:player_op(lib_player:get_fight_pid(Player), 
	       lib_player:get_player_id(Player), Op, OpList),
	{ok, Player}.

speak(#m__fight__speak__l2s{chat = PChat}, Player) ->
    fight_srv:player_speak(lib_player:get_fight_pid(Player), 
        lib_player:get_player_id(Player), PChat),
    {ok, Player}.

do_skill(#m__fight__do_skill__l2s{op = Op,
                                  op_list = OpList}, Player) ->
    fight_srv:player_skill(lib_player:get_fight_pid(Player), 
        lib_player:get_player_id(Player), Op, OpList),
    {ok, Player}.

%%%====================================================================
%%% Internal functions
%%%====================================================================