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
-define(DUTY_BAILANG, 13).  %%白狼

-define(DUTY_TYPE_SPECIAL, 1).  %%特殊身份
-define(DUTY_TYPE_SHENMIN, 2).  %%神民

-define(DUTY_LIST_SPECIAL, [?DUTY_DAOZEI, ?DUTY_QIUBITE,?DUTY_HUNXUEER]).
-define(DUTY_LIST_SHENMIN, [?DUTY_NVWU, ?DUTY_YUYANJIA, ?DUTY_LIEREN, ?DUTY_BAICHI, ?DUTY_SHOUWEI]).

-define(TURN_UP, 0).
-define(TURN_DOWN, 1).

-define(OP_PART_JINGZHANG, 1001). %%參選警長
-define(OP_XUANJU_JINGZHANG, 1002). %%選舉警長
-define(OP_JINGZHANG_ZHIDING, 1003). %%警长指定
-define(OP_FAYAN, 1004). %%发言
-define(OP_TOUPIAO, 1005). %%投票驱逐
-define(OP_QUZHU, 1006). %%被驱逐
-define(OP_PART_FAYAN, 1007). %%竞选发言
-define(OP_GUIPIAO, 1008). %%归票
-define(OP_DEATH_FAYAN, 1009). %%死亡发言
-define(OP_QUZHU_FAYAN, 1010). %%驱逐发言
-define(OP_NIGHT_SKILL, 1011). %%夜晚死亡技能
-define(OP_TOUPIAO_SKILL, 1012). %%投票死亡技能
-define(OP_CHANGE_JINGZHANG, 1013). %%转移警长

-define(XUANJU_TYPE_JINGZHANG, 1).
-define(XUANJU_TYPE_QUZHU, 2).

-define(TIMER_TIMEOUT, timeout).

-define(JINXXUAN_TIMER_TIMEOUT, jingxuan_timeout).

-define(NVWU_NONE, 0).
-define(NVWU_DUYAO, 1).
-define(NVWU_JIEYAO, 2).

-define(MFIGHT, #{room_id => 0,
                  seat_player_map => #{},%% #{seat_id, player_id}
                  player_seat_map => #{},%% #{player_id, seat_id}
                  offline_list => [],   %% seat_id
                  out_seat_list => [],%% 出局列表 seat_id
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
                  nvwu_left => [1, 2],  %% 女巫剩余的药
                  langren => 0,         %% 狼人操作
                  hunxuer => 0,         %% 混血儿是否帮狼人
                  daozei => [],         %% 盗贼可选择的
                  part_jingzhang => [], %% 參與選舉警長
                  xuanju_draw_cnt => 0, %% 选举平局次数
                  jingzhang => 0,       %% 选举的警长
                  jingzhang_op => 0,    %% 警长操作
                  fayan_turn => [],     %% 发言顺序
                  die => [],            %% 死亡玩家
                  quzhu => 0,           %% 驱逐的玩家
                  skill_seat => 0,      %% 发动技能列表
                  baichi => 0,          %% 白痴id
                  lieren_kill => 0,     %% 猎人杀死
                  last_op_data => #{}   %% 上一轮操作的数据, 杀了几号, 投了几号等等
                  }).

-endif.

