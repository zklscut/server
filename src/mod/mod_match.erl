%% @author zhangkl
%% @doc mod_match.
%% 2016

-module(mod_match).
-export([start/2,
         end/2]).

-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

start(#m__match__start__l2s{player_list = PlayerList}, Player) ->
    PlayerId = lib_player:get_player_id(Player),
    match_srv:start_match([PlayerId] ++ (PlayerList -- [PlayerId]), 0),
    {ok, Player}.

end(#m__match__end__l2s{}, Player) ->
    match_srv:end_match(lib_player:get_player_id(Player)),
    {ok, Player}.

%%%====================================================================
%%% Internal functions
%%%====================================================================