-module(b_fight_state_wait).
-export([get/1]).

get(start) ->
    1000;
get(state_daozei) ->
    1000;
get(state_qiubite) ->
    1000;
get(state_hunxueer) ->
    1000;
get(state_shouwei) ->
    1000;
get(state_langren) ->
    1000;
get(state_nvwu) ->
    1000;
get(state_yuyanjia) ->
    1000;
get(state_part_jingzhang) ->
    1000;
get(state_part_fayan) ->
    1000;
get(state_xuanju_jingzhang) ->
    1000;
get(state_night_skill) ->
    1000;
get(state_night_death) ->
    1000;
get(state_jingzhang) ->
    1000;
get(state_fayan) ->
    1000;
get(state_guipiao) ->
    1000;
get(state_toupiao) ->
    1000;
get(state_toupiao_skill) ->
    1000;
get(state_toupiao_death) ->
    1000;
get(state_day) ->
    1000;
get(_) ->
    1000.