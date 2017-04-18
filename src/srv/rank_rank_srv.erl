%% @author zhangkl
%% @doc mod_templete.
%% 2016

-module(rank_rank_srv).

-include("ets.hrl").

-behaviour(rank_behaviour).

-export([get_rank_to_player_ets/0,
         get_player_id_to_rank_ets/0,
         is_lager/2]).

%% ====================================================================
%% API functions
%% ====================================================================

get_rank_to_player_ets() ->
    ?ETS_RANK_RANK_RANK_TO_PLAYER.

get_player_id_to_rank_ets() ->
    ?ETS_RANK_RANK_PLAYER_ID_TO_RANK.

is_lager(Value1, Value2) ->
    Value1 > Value2.

%%%====================================================================
%%% Internal functions
%%%====================================================================