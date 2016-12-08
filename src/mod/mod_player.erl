%% @author zhangkl
%% @doc mod_player.
%% 2016

-module(mod_player).
-export([info/2,
         send_errcode/2]).

-include("game_pb.hrl").


%% ====================================================================
%% API functions
%% ====================================================================

info(#m__player__info__l2s{}, Player) ->
    Return = #m__player__info__s2l{player_id = lib_player:get_player_id(Player)},
    net_send:send(Return, Player),

    NewPlayer = lib_player:handle_after_login(Player),
    {save, NewPlayer}.

send_errcode(Errcode, Player) ->
    Return = #m__player__errcode__s2l{errcode = Errcode},
    net_send:send(Return, Player),

    {ok, Player}.

%%%====================================================================
%%% Internal functions
%%%====================================================================