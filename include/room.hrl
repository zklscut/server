-ifndef(ROOM_HRL).
-define(ROOM_HRL, true).
-define(ROOM_CHAT_TIME, 60000).
-define(ROOM_READY_TIME, 5000).
% -define(ROOM_SIMPLE_DUTY_LIST, [?DUTY_YUYANJIA, ?DUTY_NVWU, ?DUTY_LIEREN, ?DUTY_LANGREN, 
% 				?DUTY_LANGREN, ?DUTY_LANGREN, ?DUTY_PINGMIN, ?DUTY_PINGMIN, ?DUTY_PINGMIN]).

-define(ROOM_SIMPLE_DUTY_LIST, [?DUTY_YUYANJIA, ?DUTY_NVWU, ?DUTY_LANGREN, ?DUTY_LANGREN, ?DUTY_PINGMIN, ?DUTY_PINGMIN]).

-define(MROOM, #{room_id => 0,
                owner => undefined,
                player_list => [],
                max_player_num => 0,
                room_name => "",
                room_status => 0,
                duty_list => [],
                is_simple => false,
                chat_start_time => 0,
                want_chat_list => [],
                ready_list => []}).

-endif.

