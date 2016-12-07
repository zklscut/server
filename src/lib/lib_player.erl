%% @author zhangkl
%% @doc player_srv.
%% 2016

-module(lib_player).

-include("ets.hrl").

-export([handle_after_login/1,
         handle_after_logout/1]).


%% ====================================================================
%% API functions
%% ====================================================================

handle_after_login(Player) ->
    Player.

handle_after_logout(Player) ->
    Player.


%%%====================================================================
%%% Internal functions
%%%====================================================================