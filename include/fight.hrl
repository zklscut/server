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
-define(DUTY_NONE, 12).     %%第三方,需要杀光所有人

-define(DUTY_TYPE_SPECIAL, 1).  %%特殊身份
-define(DUTY_TYPE_SHENMIN, 2).  %%神民

-define(DUTY_LIST_SPECIAL, [?DUTY_DAOZEI, ?DUTY_QIUBITE,?DUTY_HUNXUEER]).
-define(DUTY_LIST_SHENMIN, [?DUTY_NVWU, ?DUTY_YUYANJIA]).

-define(TURN_UP, 0).
-define(TURN_DOWN, 1).

-define(TIMER_TIMEOUT, timeout).

-define(MFIGHT, #{room_id => 0,
                  seat_player_map => #{},%% #{seat_id, player_id}
                  player_seat_map => #{},%% #{player_id, seat_id}
                  offline_list => [],   %% seat_id
                  out_player_list => [],%% 出局列表 seat_id
                  seat_duty_map => #{}, %% #{seat_id, 职责}
                  duty_seat_map => #{}, %% #{duty_id, [seat_id]}
                  left_op_list => [],   %% 剩余操作seat_id 按照顺序排好
                  wait_op_list => [],   %% 等待中的操作
                  status => 0,          %% 当前游戏状态
                  game_state =>  0,     %% 第几天晚上
                  game_round =>  1,     %% 第几轮
                  lover => [],          %% 情侣
                  shouwei => 0,         %% 守卫的id
                  nvwu => {0, 0},       %% 女巫操作
                  langren => 0,         %% 狼人操作
                  hunxuer => 0,         %% 混血儿是否帮狼人
                  daozei => [],         %% 盗贼可选择的
                  last_op_data => #{}   %% 上一轮操作的数据, 杀了几号, 投了几号等等
                  }).

-endif.

