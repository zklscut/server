-module(b_fight_state_wait).
-export([get/1,
         getEnd/1
        ]).

get(start) ->
    4000;
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
    4000;
get(state_part_jingzhang) ->
    4000;
get(state_part_fayan) ->
    4000;
get(state_xuanju_jingzhang) ->
    4000;
get(state_night_skill) ->
    4000;
get(state_night_death) ->
    4000;
get(state_jingzhang) ->
    4000;
get(state_fayan) ->
    4000;
get(state_guipiao) ->
    4000;
get(state_toupiao) ->
    4000;
get(state_toupiao_skill) ->
    4000;
get(state_toupiao_death) ->
    4000;
get(state_day) ->
    4000;
get(state_night) ->
    4000;
get(state_fight_over) ->
    4000;
get(_) ->
    4000.

getEnd(state_xuanju_jingzhang) ->
    4000;
getEnd(state_yuyanjia)->
    4000;
getEnd(_) ->
    0.