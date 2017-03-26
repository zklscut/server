-module(b_fight_state_over_wait).
-export([get/1]).
get(state_toupiao)->
	0;
get(state_toupiao_mvp)->
	0;
get(state_toupiao_carry)->
	0;
get(state_yuyanjia)->
	0;
get(_) ->
    0.