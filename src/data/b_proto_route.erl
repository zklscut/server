-module(b_proto_route).
-export([get/1]).

get(10001) -> {m__account__login__l2s, mod_account, login}; 
get(10002) -> {m__account__login__s2l, mod_account, login}; 
get(12001) -> {m__player__info__l2s, mod_player, info}; 
get(12002) -> {m__player__info__s2l, mod_player, info}; 
get(12004) -> {m__player__errcode__s2l, mod_player, errcode}; 
get(13001) -> {m__room__get_list__l2s, mod_room, get_list}; 
get(13002) -> {m__room__get_list__s2l, mod_room, get_list}; 
get(13003) -> {m__room__enter_room__l2s, mod_room, enter_room}; 
get(13004) -> {m__room__enter_room__s2l, mod_room, enter_room}; 
get(13005) -> {m__room__create_room__l2s, mod_room, create_room}; 
get(13006) -> {m__room__create_room__s2l, mod_room, create_room}; 
get(13007) -> {m__room__leave_room__l2s, mod_room, leave_room}; 
get(13008) -> {m__room__leave_room__s2l, mod_room, leave_room}; 
get(13009) -> {m__room__rand_enter__l2s, mod_room, rand_enter}; 
get(14001) -> {m__chat__public_speak__l2s, mod_chat, public_speak}; 
get(14002) -> {m__chat__public_speak__s2l, mod_chat, public_speak}; 
get(_) -> undefined. 
