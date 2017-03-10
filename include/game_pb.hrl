-record(p_player_show_base, {player_id, nick_name}).
-record(p_resource, {resource_id, num}).
-record(m__account__login__l2s, {msg_id=10001, account_name}).
-record(m__account__login__s2l, {msg_id=10002, result}).
-record(m__account__heart_beat__l2s, {msg_id=10003}).
-record(m__account__heart_beat__s2l, {msg_id=10004}).
-record(m__player__info__l2s, {msg_id=12001}).
-record(p_win_rate, {duty_id, win_cnt, all_cnt}).
-record(m__player__info__s2l, {msg_id=12002, player_id, nick_name, grade, month_vip, equip, resource_list, win_rate_list, other_player}).
-record(m__player__errcode__s2l, {msg_id=12004, errcode}).
-record(m__player__other_info__l2s, {msg_id=12005, player_id}).
-record(m__player__add_coin__l2s, {msg_id=12006}).
-record(m__player__add_diamond__l2s, {msg_id=12007}).
-record(m__player__change_name__l2s, {msg_id=12008, name}).
-record(m__player__change_name__s2l, {msg_id=12009, name, result}).
-record(m__room__get_list__l2s, {msg_id=13001}).
-record(p_room, {room_id, cur_player_num, max_player_num, owner, room_name, room_status, duty_list, ready_list}).
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
-record(m__room__want_chat__l2s, {msg_id=13013}).
-record(m__room__want_chat__s2l, {msg_id=13014, wait_list}).
-record(m__room__notice_start_chat__s2l, {msg_id=13015, start_id, wait_list, duration}).
-record(m__room__end_chat__l2s, {msg_id=13016}).
-record(m__room__want_chat_list__l2s, {msg_id=13017}).
-record(m__room__want_chat_list__s2l, {msg_id=13018, wait_list}).
-record(m__room__notice_chat_info__s2l, {msg_id=13019, player_id, wait_time}).
-record(m__room__send_gift__l2s, {msg_id=13020, gift_id, player_id}).
-record(m__room__send_gift__s2l, {msg_id=13021, gift_id, player_id, result, luck_add}).
-record(m__room__kick_player__l2s, {msg_id=13022, kicked_player_id}).
-record(m__room__kick_player__s2l, {msg_id=13023, kicked_player_id, player_name, result}).
-record(m__room__ready__l2s, {msg_id=13024}).
-record(m__room__cancle_ready__l2s, {msg_id=13025}).
-record(m__room__notice_all_ready__s2l, {msg_id=13026}).
-record(m__room__login_not_in_room__s2l, {msg_id=13027}).
-record(m__room__enter_fail__s2l, {msg_id=13028}).
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
-record(m__fight__result__s2l, {msg_id=15011, winner, duty_list, lover, hunxuer, daozei, mvp, carry, coin_add, cur_level, cur_exp, exp_add, pre_level_up_exp, level_up_exp, next_level_up_exp, victory_party}).
-record(m__fight__guipiao__s2l, {msg_id=15012, guipiao_list}).
-record(m__fight__notice_fayan__s2l, {msg_id=15013, seat_id}).
-record(m__fight__stop_fayan__s2l, {msg_id=15014, seat_id}).
-record(m__fight__notice_hunxuer__s2l, {msg_id=15015, select_seat}).
-record(m__fight__notice_part_jingzhang__s2l, {msg_id=15016, seat_list}).
-record(m__fight__notice_skill__s2l, {msg_id=15017, op, op_list, seat_id}).
-record(m__fight__do_skill__l2s, {msg_id=15018, op, op_list}).
-record(p_flop, {seat_id, op}).
-record(m__fight__online__s2l, {msg_id=15019, duty, game_state, round, die_list, seat_id, attach_data1, attach_data2, offline_list, leave_list, flop_list, winner, wait_op, wait_op_list, wait_op_attach_data, wait_op_tick, jingzhang, lover_list, duty_list, parting_jingzhang}).
-record(m__fight__offline__s2l, {msg_id=15020, offline_list}).
-record(m__fight__op_timetick__s2l, {msg_id=15021, timetick}).
-record(m__fight__langren_team_speak__s2l, {msg_id=15022, chat}).
-record(m__fight__shouwei_op__s2l, {msg_id=15023, seat_id}).
-record(m__fight__over_info__s2l, {msg_id=15024, winner, duty_list, dead_list}).
-record(m__fight__leave__s2l, {msg_id=15025, leave_list}).
-record(m__resource__push__s2l, {msg_id=16001, resource_id, num, action_id}).
-record(m__match__start_match__l2s, {msg_id=17001, player_list}).
-record(m__match__end_match__l2s, {msg_id=17002}).
-record(m__match__end_match__s2l, {msg_id=17003}).
-record(m__match__again_match__s2l, {msg_id=17004}).
-record(m__match__notice_enter_match__s2l, {msg_id=17005, wait_id, wait_list}).
-record(m__match__enter_match__l2s, {msg_id=17006, wait_id}).
-record(m__match__enter_match_list__s2l, {msg_id=17007, wait_id, ready_list, wait_list}).
-record(p_rank, {player_show_base, rank, value}).
-record(m__rank__get_rank__l2s, {msg_id=18001, rank_type, start_rank, end_rank}).
-record(m__rank__get_rank__s2l, {msg_id=18002, rank_type, start_rank, end_rank, rank_list}).
