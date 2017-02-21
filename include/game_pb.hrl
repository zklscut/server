-record(p_player_show_base, {player_id, nick_name}).
-record(p_resource, {resource_id, num}).
-record(m__account__login__l2s, {msg_id=10001, account_name}).
-record(m__account__login__s2l, {msg_id=10002, result}).
-record(m__player__info__l2s, {msg_id=12001}).
-record(p_win_rate, {duty_id, win_cnt, all_cnt}).
-record(m__player__info__s2l, {msg_id=12002, player_id, nick_name, grade, month_vip, equip, resource_list, win_rate_list}).
-record(m__player__errcode__s2l, {msg_id=12004, errcode}).
-record(m__player__other_info__l2s, {msg_id=12005, player_id}).
-record(m__room__get_list__l2s, {msg_id=13001}).
-record(p_room, {room_id, cur_player_num, max_player_num, owner, room_name, room_status, duty_list}).
-record(m__room__get_list__s2l, {msg_id=13002, room_list}).
-record(m__room__enter_room__l2s, {msg_id=13003, room_id}).
-record(m__room__enter_room__s2l, {msg_id=13004, room_info, member_list}).
-record(m__room__create_room__l2s, {msg_id=13005, max_player_num, room_name, duty_list}).
-record(m__room__create_room__s2l, {msg_id=13006, room_info}).
-record(m__room__leave_room__l2s, {msg_id=13007}).
-record(m__room__leave_room__s2l, {msg_id=13008}).
-record(m__room__rand_enter__l2s, {msg_id=13009}).
-record(m__room__start_fight__l2s, {msg_id=13011}).
-record(m__room__notice_member_change__s2l, {msg_id=13012, room_info, member_list}).
-record(p_chat, {player_show_base, voice, content, length, compress, chat_type, room_id, msg_type}).
-record(m__chat__public_speak__l2s, {msg_id=14001, chat}).
-record(m__chat__public_speak__s2l, {msg_id=14002, chat}).
-record(m__fight__game_state_change__s2l, {msg_id=15001, game_status, attach_data}).
-record(m__fight__notice_duty__s2l, {msg_id=15002, duty, seat_id}).
-record(m__fight__notice_op__s2l, {msg_id=15003, op, attach_data}).
-record(m__fight__notice_op__l2s, {msg_id=15004, op, op_list}).
-record(m__fight__speak__l2s, {msg_id=15005, chat}).
-record(m__fight__speak__s2l, {msg_id=15006, chat}).
-record(m__fight__notice_lover__s2l, {msg_id=15007, lover_list}).
-record(m__fight__notice_yuyanjia_result__s2l, {msg_id=15008, seat_id, duty}).
-record(p_xuanju_result, {seat_id, select_list}).
-record(m__fight__xuanju_result__s2l, {msg_id=15009, xuanju_type, result_list, is_draw, result_id}).
-record(m__fight__night_result__s2l, {msg_id=15010, die_list}).
-record(p_duty, {seat_id, duty_id}).
-record(m__fight__result__s2l, {msg_id=15011, winner, duty_list, lover, hunxuer}).
-record(m__fight__guipiao__s2l, {msg_id=15012, guipiao_list}).
-record(m__fight__notice_fayan__s2l, {msg_id=15013, seat_id}).
-record(m__fight__stop_fayan__s2l, {msg_id=15014, seat_id}).
-record(m__fight__notice_hunxuer__s2l, {msg_id=15015, select_seat}).
-record(m__fight__notice_part_jingzhang__s2l, {msg_id=15016, seat_list}).
-record(m__fight__notice_skill__s2l, {msg_id=15017, op, op_list, seat_id}).
-record(m__fight__do_skill__l2s, {msg_id=15018, op, op_list}).
-record(m__fight__online__s2l, {msg_id=15019, duty, game_state, round, speak_id, die_list, seat_id, attach_data1, attach_data2, offline_list}).
-record(m__fight__offline__s2l, {msg_id=15020, offline_list}).
-record(m__fight__op_timetick__s2l, {msg_id=15021, timetick}).
-record(m__resource__push__s2l, {msg_id=16001, resource_id, num, action_id}).
