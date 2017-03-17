%% @author zhangkl
%% @doc mod_match.
%% 2016

-module(mod_match).
-export([start_match/2,
         end_match/2,
         enter_match/2,
         send_to_player_list/2,
         send_to_player/2
         ]).

-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

start_match(#m__match__start_match__l2s{player_list = PlayerList, 
                                        mode = MatchMode}, Player) ->
    PlayerId = lib_player:get_player_id(Player),
    % match_srv:start_match([PlayerId] ++ (PlayerList -- [PlayerId]), 0),
    lib_match:start_match([PlayerId] ++ (PlayerList -- [PlayerId]), 0, MatchMode),
    {ok, Player}.

end_match(#m__match__end_match__l2s{mode = MatchMode}, Player) ->
    % match_srv:cancle_match(lib_player:get_player_id(Player)),
    lib_match:cancel_match(lib_player:get_player_id(Player), MatchMode),
    {ok, Player}.

enter_match(#m__match__enter_match__l2s{wait_id = WaitId, mode=MatchMode}, Player) ->
    % match_srv:enter_match(lib_player:get_player_id(Player), WaitId),
    lib_match:enter_match(lib_player:get_player_id(Player), WaitId, MatchMode),
    {ok, Player}.

send_to_player_list(Send, PlayerList) ->
	[send_to_player(Send, PlayerId) || PlayerId <- PlayerList].

send_to_player(Send, PlayerId)  when is_integer(PlayerId)  ->
    net_send:send(Send, PlayerId);

send_to_player(Send, Player) ->
    net_send:send(Send, Player).



%%%====================================================================
%%% Internal functions
%%%====================================================================



