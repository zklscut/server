% @Author: anchen
% @Date:   2016-12-06 14:10:22
% @Last Modified by:   anchen
% @Last Modified time: 2016-12-06 14:11:25

-module(b_proto_route).
-export([get/1]).

get(10001) ->
    {m__account__login__l2s, mod_account, login}.