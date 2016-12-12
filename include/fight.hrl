-ifndef(FIGHT_HRL).
-define(FIGHT_HRL, true).

-define(DUTY_DAOZEI, 1).    %%盗贼
-define(DUTY_QIUBITE, 2).   %%丘比特
-define(DUTY_HUNXUEER, 3).  %%混血儿
-define(DUTY_SHOUWEI, 4).   %%守卫
-define(DUTY_LANGREN, 5).   %%狼人
-define(DUTY_NVWU, 6).      %%女巫
-define(DUTY_YUYANJIA, 7).  %%预言家
-define(DUTY_LIEREN, 8).    %%猎人
-define(DUTY_CUNZHANG, 9).  %%村长
-define(DUTY_BAICHI, 10).   %%白痴
-define(DUTY_PINGMIN, 11).  %%平民

-define(DUTY_TYPE_SPECIAL, 1).  %%特殊身份
-define(DUTY_TYPE_SHENMIN, 2).  %%神民

-define(DUTY_LIST_SPECIAL, [?DUTY_DAOZEI, ?DUTY_QIUBITE,?DUTY_HUNXUEER, ?DUTY_SHOUWEI]).
-define(DUTY_LIST_SHENMIN, [?DUTY_NVWU, ?DUTY_YUYANJIA]).

-define(TURN_UP, 0).
-define(TURN_DOWN, 1).

-define(GAME_STATE_SPECIAL_NIGHT, 0).  %%特殊身份选择
-define(GAME_STATE_LANGREN_NIGHT, 1).  %%狼人杀人
-define(GAME_STATE_SHENMIN_NIGHT, 2).  %%神民操作
-define(GAME_STATE_JINGZHANG_XUANJU, 3).  %%选举警长
-define(GAME_STATE_SPEAK, 4).  %%开始发言

-define(MFIGHT, #{room_id => 0,
                  seat_player_map => #{},%% #{seat_id, player_id}
                  player_seat_map => #{},%% #{player_id, seat_id}
                  offline_list => [],   %% seat_id
                  out_player_list => [],%% 出局列表 seat_id
                  seat_duty_map => #{}, %% #{seat_id, 职责}
                  duty_seat_map => #{}, %% #{duty_id, [seat_id]}
                  left_op_list => [],   %% 剩余操作seat_id 按照顺序排好
                  op => 0,              %% 当前进行的操作
                  game_state =>  0,     %% 第几天晚上
                  game_round =>  1,     %% 第几轮
                  last_op_data => #{}   %% 上一轮操作的数据, 杀了几号, 投了几号等等
                  }).

-endif.

