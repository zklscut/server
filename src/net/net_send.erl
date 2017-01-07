% @Author: anchen
% @Date:   2016-12-06 14:52:58
% @Last Modified by:   anchen
% @Last Modified time: 2017-01-07 13:51:49

-module(net_send).
-export([send/2,
         send_errcode/2]).

send(Send, #{socket := Socket,
			 id := PlayerId}) ->
    lager:info("send ~p", [{PlayerId, Send}]),
    Binary = game_pb:encode(Send),
    ProtoId = element(2, Send),
    Len = byte_size(Binary),
    gen_tcp:send(Socket, <<1:24, Len:16, ProtoId:16, Binary/binary>>),
    ok;

send(Send, PlayerId) when is_integer(PlayerId) ->
    lager:info("send ~p", [{PlayerId, Send}]),
	global_op_srv:player_op(PlayerId, {?MODULE, send, [Send]}),
    ok;

send(_, _) ->
    ok.

send_errcode(ErrCode, PlayerId) when is_integer(PlayerId) ->
    global_op_srv:player_op(PlayerId, {?MODULE, send_errcode, [ErrCode]}),
    ok;    

send_errcode(ErrCode, Player) ->
    mod_player:send_errcode(ErrCode, Player),
    ok.