-module(b_fight_state_wait).
-export([get/1]).

get(start) ->
    0;
get(state_daozei) ->
    0;
get(state_qiubite) ->
    0;
get(state_hunxueer) ->
    0;
get(state_shouwei) ->
    0;
get(state_langren) ->
    0;
get(state_nvwu) ->
    0;
get(state_yuyanjia) ->
    0;
get(state_part_jingzhang) ->
    0;
get(state_part_fayan) ->
    0;
get(state_xuanju_jingzhang) ->
    0;
get(state_night_death) ->
    0;
get(state_jingzhang) ->
    0;
get(state_fayan) ->
    0;
get(state_guipiao) ->
    0;
get(state_toupiao) ->
    0;
get(state_toupiao_death) ->
    0;
get(state_day) ->
    0;
get(_) ->
    0.