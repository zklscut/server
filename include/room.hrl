-ifndef(ROOM_HRL).
-define(ROOM_HRL, true).
-define(ROOM_CHAT_TIME, 20000).
-define(MROOM, #{room_id => 0,
                owner => undefined,
                player_list => [],
                max_player_num => 0,
                room_name => "",
                room_status => 0,
                duty_list => [],
                chat_start_time => 0,
                want_chat_list => [],
                ready_list => []}).

-endif.

