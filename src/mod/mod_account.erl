% @Author: anchen
% @Date:   2016-12-06 14:49:32
% @Last Modified by:   anchen
% @Last Modified time: 2016-12-06 15:11:40

-module(mod_account).
-export([login/2]).

-include("game_pb.hrl").

login(#m__account__login__l2s{account_name = _AccountName}, Player) ->
    Return = #m__account__login__s2l{result = 1},
    net_send:send(Return, Player),
    {save, Player}.