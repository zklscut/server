%% @author zhangkl
%% @doc mod_fight.
%% 2016

-module(mod_fight).
-export([notice_op/2,
		 speak/2,
     forbid_other_speak/2,
     chat_input/2,
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

speak(#m__fight__speak__l2s{chat = PChat, night_langren = NightLangren}, Player) ->
    fight_srv:player_speak(lib_player:get_fight_pid(Player), 
        lib_player:get_player_id(Player), PChat, NightLangren),
    {ok, Player}.

do_skill(#m__fight__do_skill__l2s{op = Op,
                                  op_list = OpList}, Player) ->
    fight_srv:player_skill(lib_player:get_fight_pid(Player), 
        lib_player:get_player_id(Player), Op, OpList),
    {ok, Player}.

forbid_other_speak(#m__fight__forbid_other_speak__l2s{is_forbid = Forbid}, Player)->
    fight_srv:forbid_other_speak(lib_player:get_fight_pid(Player), 
        lib_player:get_player_id(Player), Forbid),
    {ok, Player}.

chat_input(#m__fight__chat_input__s2l{is_expression = IsExpression,
                                      content = Content,
                                      night_langren = NightLangren}, Player) ->
    fight_srv:chat_input(lib_player:get_fight_pid(Player), 
        lib_player:get_player_id(Player), IsExpression, Content, NightLangren),
    {ok, Player}.

%%%====================================================================
%%% Internal functions
%%%====================================================================