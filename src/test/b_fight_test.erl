% @Author: anchen
% @Date:   2017-02-14 10:43:16
% @Last Modified by:   anchen
% @Last Modified time: 2017-02-14 15:21:26


% -define(DUTY_DAOZEI, 1).    %%盗贼
% -define(DUTY_QIUBITE, 2).   %%丘比特
% -define(DUTY_HUNXUEER, 3).  %%混血儿
% -define(DUTY_SHOUWEI, 4).   %%守卫
% -define(DUTY_LANGREN, 5).   %%狼人
% -define(DUTY_NVWU, 6).      %%女巫
% -define(DUTY_YUYANJIA, 7).  %%预言家
% -define(DUTY_LIEREN, 8).    %%猎人
% -define(DUTY_CUNZHANG, 9).  %%村长
% -define(DUTY_BAICHI, 10).   %%白痴
% -define(DUTY_PINGMIN, 11).  %%平民
% -define(DUTY_NONE, 12).     %%第三方,需要杀光所有人
% -define(DUTY_BAILANG, 13).  %%白狼

-module(b_fight_test).
-export([get/1]).

get({1, init}) ->
    [{seat_player_map, #{1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9}},
     {player_seat_map, #{1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9}},
     {seat_duty_map, #{1=>13,2=>5,3=>5,4=>4,5=>6,6=>7,7=>8,8=>11,9=>11}},
     {duty_seat_map, #{13=>[1],5=>[2,3],4=>[4],6=>[5],7=>[6],8=>[7],11=>[8,9]}},
     {player_num,9}];

%%数字代表第几次走到这个状态
get({1, state_langren}) ->
    [{last_op_data, #{1=>[4]}}];

get({2, state_langren}) ->
    [{last_op_data, #{1=>[6]}}];

get({3, state_langren}) ->
    [{last_op_data, #{1=>[7]}}];

get({4, state_langren}) ->
    [{last_op_data, #{1=>[8]}}];

get({1, state_shouwei}) ->
    [{last_op_data, #{4 => [3]}}];

get({_, state_yuyanjia}) ->
    [{last_op_data, #{6 => [0]}}];    

get({_, state_nvwu}) ->
    [{last_op_data, #{5 => [0, 0]}}];        

get(_) ->
    [].
