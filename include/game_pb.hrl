-record(p_player_show_base, {player_id, nick_name, head_img_name}).
-record(p_resource, {resource_id, num}).
-record(m__account__login__l2s, {msg_id=10001, account_name}).
-record(m__account__login__s2l, {msg_id=10002, result}).
-record(m__account__heart_beat__l2s, {msg_id=10003}).
-record(m__account__heart_beat__s2l, {msg_id=10004}).
-record(m__player__info__l2s, {msg_id=12001}).
-record(p_win_rate, {duty_id, win_cnt, all_cnt}).
-record(m__player__info__s2l, {msg_id=12002, player_id, nick_name, grade, month_vip, equip, resource_list, win_rate_list, other_player, sex, head_img_name}).
-record(m__player__errcode__s2l, {msg_id=12004, errcode}).
-record(m__player__other_info__l2s, {msg_id=12005, player_id}).
-record(m__player__add_coin__l2s, {msg_id=12006}).
-record(m__player__add_diamond__l2s, {msg_id=12007}).
-record(m__player__change_name__l2s, {msg_id=12008, name}).
-record(m__player__change_name__s2l, {msg_id=12009, name, result}).
-record(m__player__kick__s2l, {msg_id=12010, kick_reason}).
-record(m__player__upload_head__l2s, {msg_id=12011, img_data}).
-record(m__player__upload_head__s2l, {msg_id=12012, result}).
-record(m__player__get_head__l2s, {msg_id=12013, player_id}).
-record(m__player__get_head__s2l, {msg_id=12014, player_id, img_data}).
-record(m__player__change_sex__l2s, {msg_id=12015, sex}).
-record(m__player__change_sex__s2l, {msg_id=12016, sex}).
-record(m__player__upload_head_img_name__l2s, {msg_id=12017, head_img_name}).
-record(m__player__upload_head_img_name__s2l, {msg_id=12018}).
-record(m__player__get_head_img_name__l2s, {msg_id=12019, player_id}).
-record(m__player__get_head_img_name__s2l, {msg_id=12020, player_id, head_img_name}).
-record(m__player__invite_friends__l2s, {msg_id=12021, player_list, room_id}).
-record(m__player__invite_friends__s2l, {msg_id=12022}).
-record(m__player__friend_invite__s2l, {msg_id=12023, player_info, room_id}).
-record(m__room__get_list__l2s, {msg_id=13001}).
-record(p_fight, {room_name, duty_list, player_info_list}).
-record(p_room, {room_id, cur_player_num, max_player_num, owner, room_name, room_status, duty_list, ready_list}).
-record(m__room__get_list__s2l, {msg_id=13002, room_list}).
-record(m__room__enter_room__l2s, {msg_id=13003, room_id}).
-record(m__room__enter_room__s2l, {msg_id=13004, room_info, member_list}).
-record(m__room__create_room__l2s, {msg_id=13005, max_player_num, room_name, duty_list}).
-record(m__room__create_room__s2l, {msg_id=13006, room_info}).
-record(m__room__leave_room__l2s, {msg_id=13007}).
-record(m__room__leave_room__s2l, {msg_id=13008, result}).
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
-record(m__room__enter_fail__s2l, {msg_id=13028, result}).
-record(m__room__enter_simple_room__l2s, {msg_id=13029}).
-record(m__room__get_room_info__l2s, {msg_id=13030, room_id}).
-record(m__room__get_room_info__s2l, {msg_id=13031, room_info}).
-record(m__room__get_room_info_fail__s2l, {msg_id=13032, reason}).
-record(m__room__get_not_full_normal_room_id_list__l2s, {msg_id=13033}).
-record(m__room__get_not_full_normal_room_id_list__s2l, {msg_id=13034, room_id_list}).
-record(p_chat, {voice, content, length, compress, chat_type, room_id, msg_type}).
-record(m__chat__public_speak__l2s, {msg_id=14001, chat}).
-record(m__chat__public_speak__s2l, {msg_id=14002, chat, player_id}).
-record(m__fight__game_state_change__s2l, {msg_id=15001, game_status, attach_data}).
-record(m__fight__notice_duty__s2l, {msg_id=15002, duty, seat_id, fight_info, fight_mode, duty_valid}).
-record(m__fight__notice_op__s2l, {msg_id=15003, op, attach_data}).
-record(m__fight__notice_op__l2s, {msg_id=15004, op, op_list, confirm}).
-record(m__fight__speak__l2s, {msg_id=15005, chat, speak_type}).
-record(m__fight__speak__s2l, {msg_id=15006, chat, player_id}).
-record(m__fight__notice_lover__s2l, {msg_id=15007, lover_list}).
-record(m__fight__notice_yuyanjia_result__s2l, {msg_id=15008, seat_id, duty}).
-record(p_xuanju_result, {seat_id, select_list}).
-record(m__fight__xuanju_result__s2l, {msg_id=15009, xuanju_type, result_list, is_draw, result_id, max_list}).
-record(m__fight__night_result__s2l, {msg_id=15010, die_list}).
-record(p_duty, {seat_id, duty_id, player_id}).
-record(m__fight__result__s2l, {msg_id=15011, winner, duty_list, lover, hunxuer, daozei, mvp, carry, coin_add, cur_level, cur_exp, exp_add, pre_level_up_exp, level_up_exp, next_level_up_exp, victory_party, room_id, own_seat_id, third_list, rank_add}).
-record(m__fight__guipiao__s2l, {msg_id=15012, guipiao_list}).
-record(m__fight__notice_fayan__s2l, {msg_id=15013, seat_id}).
-record(m__fight__stop_fayan__s2l, {msg_id=15014, seat_id}).
-record(m__fight__notice_hunxuer__s2l, {msg_id=15015, select_seat}).
-record(m__fight__notice_part_jingzhang__s2l, {msg_id=15016, seat_list}).
-record(m__fight__notice_skill__s2l, {msg_id=15017, op, op_list, seat_id}).
-record(m__fight__do_skill__l2s, {msg_id=15018, op, op_list}).
-record(p_flop, {seat_id, op}).
-record(m__fight__online__s2l, {msg_id=15019, duty, game_status, round, die_list, seat_id, attach_data1, attach_data2, offline_list, leave_list, flop_list, winner, wait_op, wait_op_list, wait_op_attach_data, wait_op_tick, jingzhang, lover_list, duty_list, parting_jingzhang, fight_info, duty_select_over, duty_select_time, duty_select_info, is_night, fight_mode, speak_forbid_info, game_round, night_op_left_time, bailang_list, duty_select_seat_list}).
-record(m__fight__offline__s2l, {msg_id=15020, offline_list}).
-record(m__fight__op_timetick__s2l, {msg_id=15021, timetick, wait_op}).
-record(m__fight__langren_team_speak__s2l, {msg_id=15022, chat}).
-record(m__fight__shouwei_op__s2l, {msg_id=15023, seat_id}).
-record(m__fight__over_info__s2l, {msg_id=15024, winner, duty_list, dead_list}).
-record(m__fight__leave__s2l, {msg_id=15025, leave_list}).
-record(m__fight__update_duty__s2l, {msg_id=15026, pre_duty, cur_duty}).
-record(m__fight__random_duty__s2l, {msg_id=15027, left_time, duty_list}).
-record(m__fight__select_duty__s2l, {msg_id=15028, result, duty, seat_id}).
-record(m__fight__notice_langren__s2l, {msg_id=15029, langren_list, bailang_list}).
-record(m__fight__forbid_other_speak__l2s, {msg_id=15030, is_forbid}).
-record(m__fight__forbid_other_speak__s2l, {msg_id=15031, forbid_info}).
-record(m__fight__chat_input__l2s, {msg_id=15032, is_expression, chat_type, content}).
-record(m__fight__chat_input__s2l, {msg_id=15033, is_expression, chat_type, player_id, content}).
-record(m__fight__dync_langren_op_data__s2l, {msg_id=15034, op_data}).
-record(m__fight__langren_op__s2l, {msg_id=15035, seat_id}).
-record(m__fight__nvwu_op__s2l, {msg_id=15036, du_seat_id, save_seat_id}).
-record(m__fight_over_error__s2l, {msg_id=15037, room_id, reason}).
-record(m__fight__daozei_op__s2l, {msg_id=15038, duty}).
-record(p_die_info, {seat_id, die_type, game_round, is_night}).
-record(m__fight__end_info__s2l, {msg_id=15039, duty_list, die_info, result_type}).
-record(m__resource__push__s2l, {msg_id=16001, resource_id, num, action_id}).
-record(m__match__start_match__l2s, {msg_id=17001, mode, player_list}).
-record(m__match__end_match__l2s, {msg_id=17002, mode}).
-record(m__match__end_match__s2l, {msg_id=17003}).
-record(m__match__again_match__s2l, {msg_id=17004, mode, is_again}).
-record(m__match__notice_enter_match__s2l, {msg_id=17005, wait_id, mode, wait_list}).
-record(m__match__enter_match__l2s, {msg_id=17006, mode, wait_id}).
-record(m__match__enter_match_list__s2l, {msg_id=17007, wait_id, ready_list, wait_list}).
-record(p_rank, {player_show_base, rank, value}).
-record(m__rank__get_rank__l2s, {msg_id=18001, rank_type, start_rank, end_rank}).
-record(m__rank__get_rank__s2l, {msg_id=18002, rank_type, start_rank, end_rank, rank_list}).
-record(p_friend, {player_show_base, status, room_id}).
-record(m__friend__get_friend__l2s, {msg_id=19001}).
-record(m__friend__get_friend__s2l, {msg_id=19002, friend_list}).
-record(m__friend__add_friend__l2s, {msg_id=19003, add_friend}).
-record(m__friend__remove_friend__l2s, {msg_id=19005, remove_friend}).
-record(m__friend__private_chat__l2s, {msg_id=19007, chat, target_id}).
-record(m__friend__private_chat__s2l, {msg_id=19008, target_info, speak_info, chat}).
-record(m__friend__get_chat_list__l2s, {msg_id=19009, friend_id}).
-record(m__friend__get_chat_list__s2l, {msg_id=19010, chat_list}).
-record(m__friend__add_friend__s2l, {msg_id=19011, friend}).
-record(m__friend__remove_friend__s2l, {msg_id=19012, remove_friend}).
