-module(b_proto_route).
-export([get/1]).

get(10001) -> {m__account__login__l2s, mod_account, login}; 
get(10002) -> {m__account__login__s2l, mod_account, login}; 
get(_) -> undefined. 
