% @Author: anchen
% @Date:   2016-12-06 14:52:58
% @Last Modified by:   anchen
% @Last Modified time: 2016-12-06 14:57:41

-module(net_send).
-export([send/2]).

send(Send, #{socket := Socket}) ->
    Binary = game_pb:encode(Send),
    gen_tcp:send(Socket, Binary).