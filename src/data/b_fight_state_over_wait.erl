-module(b_fight_state_over_wait).
-export([get/1]).
get(state_toupiao)->
	6000;
get(_) ->
    15000.