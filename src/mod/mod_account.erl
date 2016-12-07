%% @author zhangkl
%% @doc player_srv.
%% 2016

-module(mod_account).
-export([login/2]).

-include("game_pb.hrl").


%% ====================================================================
%% API functions
%% ====================================================================

login(#m__account__login__l2s{account_name = _AccountName}, Player) ->
    PlayerId = global_id_srv:generate_player_id(),

    Return = #m__account__login__s2l{result = 1},
    net_send:send(Return, Player),
    {save, maps:put(id, PlayerId, Player)}.


%%%====================================================================
%%% Internal functions
%%%====================================================================