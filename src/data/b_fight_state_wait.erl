-module(b_fight_state_wait).
-export([get/1]).

get(start) ->
    5000;
get(state_daozei) ->
    5000;
get(state_qiubite) ->
    5000;
get(state_hunxueer) ->
    5000;
get(state_shouwei) ->
    5000;
get(state_langren) ->
    5000;
get(state_nvwu) ->
    5000;
get(state_yuyanjia) ->
    5000;
get(state_part_jingzhang) ->
    5000;
get(state_part_fayan) ->
    5000;
get(state_xuanju_jingzhang) ->
    5000;
get(state_night_skill) ->
    5000;
get(state_night_death) ->
    5000;
get(state_jingzhang) ->
    5000;
get(state_fayan) ->
    5000;
get(state_guipiao) ->
    5000;
get(state_toupiao) ->
    5000;
get(state_toupiao_skill) ->
    5000;
get(state_toupiao_death) ->
    5000;
get(state_day) ->
    5000;
get(_) ->
    5000.