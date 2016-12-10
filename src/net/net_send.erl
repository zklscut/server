% @Author: anchen
% @Date:   2016-12-06 14:52:58
% @Last Modified by:   anchen
% @Last Modified time: 2016-12-10 11:20:23

-module(net_send).
-export([send/2]).

send(Send, #{socket := Socket}) ->
    lager:info("send ~p", [Send]),
    Binary = game_pb:encode(Send),
    ProtoId = element(2, Send),
    Len = byte_size(Binary),
    gen_tcp:send(Socket, <<1:24, Len:16, ProtoId:16, Binary/binary>>);

send(Send, PlayerId) when is_integer(PlayerId) ->
	global_op_srv:player_op(PlayerId, {?MODULE, send, [Send]});

send(_, _) ->
    ok.