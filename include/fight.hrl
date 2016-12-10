-ifndef(FIGHT_HRL).
-define(FIGHT_HRL, true).

-define(DUTY_DAOZEI, 1).    %%盗贼
-define(DUTY_QIUBITE, 2).   %%丘比特
-define(DUTY_HUNXUEER, 3).  %%混血儿
-define(DUTY_SHOUWEI, 4).   %%守卫
-define(DUTY_LANGREN, 5).   %%狼人
-define(DUTY_NVWU, 6).      %%女巫
-define(DUTY_YUYANJIA, 7).  %%预言家
-define(DUTY_PINGMIN, 8).   %%平民

-define(DUTY_TYPE_SPECIAL, 1).  %%特殊身份
-define(DUTY_TYPE_SHENMIN, 2).  %%神民

-define(DUTY_LIST_SPECIAL, [?DUTY_DAOZEI, ?DUTY_QIUBITE,?DUTY_HUNXUEER, ?DUTY_SHOUWEI]).
-define(DUTY_LIST_SHENMIN, [?DUTY_NVWU, ?DUTY_YUYANJIA]).

-define(TURN_UP, 0).
-define(TURN_DOWN, 1).

-define(MFIGHT, #{room_id => 0,
                  seat_player_map => [],%% #{seat_id, player_id}
                  offline_list => [],   %% seat_id
                  out_player_list => [],%% 出局列表 seat_id
                  duty_list => [],      %% #{seat_id, 职责}
                  left_op_list => [],   %% 剩余操作seat_id 按照顺序排好
                  op => 0,              %% 当前进行的操作
                  last_op_data => #{}   %% 上一轮操作的数据, 杀了几号, 投了几号等等
                  }).

-endif.

