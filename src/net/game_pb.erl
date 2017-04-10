-module(game_pb).

-export([encode/1, encode/2, decode/2,
	 encode_m__friend__remove_friend__s2l/1,
	 decode_m__friend__remove_friend__s2l/1,
	 encode_m__friend__add_friend__s2l/1,
	 decode_m__friend__add_friend__s2l/1,
	 encode_m__friend__get_chat_list__s2l/1,
	 decode_m__friend__get_chat_list__s2l/1,
	 encode_m__friend__get_chat_list__l2s/1,
	 decode_m__friend__get_chat_list__l2s/1,
	 encode_m__friend__private_chat__s2l/1,
	 decode_m__friend__private_chat__s2l/1,
	 encode_m__friend__private_chat__l2s/1,
	 decode_m__friend__private_chat__l2s/1,
	 encode_m__friend__remove_friend__l2s/1,
	 decode_m__friend__remove_friend__l2s/1,
	 encode_m__friend__add_friend__l2s/1,
	 decode_m__friend__add_friend__l2s/1,
	 encode_m__friend__get_friend__s2l/1,
	 decode_m__friend__get_friend__s2l/1,
	 encode_m__friend__get_friend__l2s/1,
	 decode_m__friend__get_friend__l2s/1, encode_p_friend/1,
	 decode_p_friend/1, encode_m__rank__get_rank__s2l/1,
	 decode_m__rank__get_rank__s2l/1,
	 encode_m__rank__get_rank__l2s/1,
	 decode_m__rank__get_rank__l2s/1, encode_p_rank/1,
	 decode_p_rank/1,
	 encode_m__match__enter_match_list__s2l/1,
	 decode_m__match__enter_match_list__s2l/1,
	 encode_m__match__enter_match__l2s/1,
	 decode_m__match__enter_match__l2s/1,
	 encode_m__match__notice_enter_match__s2l/1,
	 decode_m__match__notice_enter_match__s2l/1,
	 encode_m__match__again_match__s2l/1,
	 decode_m__match__again_match__s2l/1,
	 encode_m__match__end_match__s2l/1,
	 decode_m__match__end_match__s2l/1,
	 encode_m__match__end_match__l2s/1,
	 decode_m__match__end_match__l2s/1,
	 encode_m__match__start_match__l2s/1,
	 decode_m__match__start_match__l2s/1,
	 encode_m__resource__push__s2l/1,
	 decode_m__resource__push__s2l/1,
	 encode_m__fight__end_info__s2l/1,
	 decode_m__fight__end_info__s2l/1, encode_p_die_info/1,
	 decode_p_die_info/1, encode_m__fight__daozei_op__s2l/1,
	 decode_m__fight__daozei_op__s2l/1,
	 encode_m__fight_over_error__s2l/1,
	 decode_m__fight_over_error__s2l/1,
	 encode_m__fight__nvwu_op__s2l/1,
	 decode_m__fight__nvwu_op__s2l/1,
	 encode_m__fight__langren_op__s2l/1,
	 decode_m__fight__langren_op__s2l/1,
	 encode_m__fight__dync_langren_op_data__s2l/1,
	 decode_m__fight__dync_langren_op_data__s2l/1,
	 encode_m__fight__chat_input__s2l/1,
	 decode_m__fight__chat_input__s2l/1,
	 encode_m__fight__chat_input__l2s/1,
	 decode_m__fight__chat_input__l2s/1,
	 encode_m__fight__forbid_other_speak__s2l/1,
	 decode_m__fight__forbid_other_speak__s2l/1,
	 encode_m__fight__forbid_other_speak__l2s/1,
	 decode_m__fight__forbid_other_speak__l2s/1,
	 encode_m__fight__notice_langren__s2l/1,
	 decode_m__fight__notice_langren__s2l/1,
	 encode_m__fight__select_duty__s2l/1,
	 decode_m__fight__select_duty__s2l/1,
	 encode_m__fight__random_duty__s2l/1,
	 decode_m__fight__random_duty__s2l/1,
	 encode_m__fight__update_duty__s2l/1,
	 decode_m__fight__update_duty__s2l/1,
	 encode_m__fight__leave__s2l/1,
	 decode_m__fight__leave__s2l/1,
	 encode_m__fight__over_info__s2l/1,
	 decode_m__fight__over_info__s2l/1,
	 encode_m__fight__shouwei_op__s2l/1,
	 decode_m__fight__shouwei_op__s2l/1,
	 encode_m__fight__langren_team_speak__s2l/1,
	 decode_m__fight__langren_team_speak__s2l/1,
	 encode_m__fight__op_timetick__s2l/1,
	 decode_m__fight__op_timetick__s2l/1,
	 encode_m__fight__offline__s2l/1,
	 decode_m__fight__offline__s2l/1,
	 encode_m__fight__online__s2l/1,
	 decode_m__fight__online__s2l/1, encode_p_flop/1,
	 decode_p_flop/1, encode_m__fight__do_skill__l2s/1,
	 decode_m__fight__do_skill__l2s/1,
	 encode_m__fight__notice_skill__s2l/1,
	 decode_m__fight__notice_skill__s2l/1,
	 encode_m__fight__notice_part_jingzhang__s2l/1,
	 decode_m__fight__notice_part_jingzhang__s2l/1,
	 encode_m__fight__notice_hunxuer__s2l/1,
	 decode_m__fight__notice_hunxuer__s2l/1,
	 encode_m__fight__stop_fayan__s2l/1,
	 decode_m__fight__stop_fayan__s2l/1,
	 encode_m__fight__notice_fayan__s2l/1,
	 decode_m__fight__notice_fayan__s2l/1,
	 encode_m__fight__guipiao__s2l/1,
	 decode_m__fight__guipiao__s2l/1,
	 encode_m__fight__result__s2l/1,
	 decode_m__fight__result__s2l/1, encode_p_duty/1,
	 decode_p_duty/1, encode_m__fight__night_result__s2l/1,
	 decode_m__fight__night_result__s2l/1,
	 encode_m__fight__xuanju_result__s2l/1,
	 decode_m__fight__xuanju_result__s2l/1,
	 encode_p_xuanju_result/1, decode_p_xuanju_result/1,
	 encode_m__fight__notice_yuyanjia_result__s2l/1,
	 decode_m__fight__notice_yuyanjia_result__s2l/1,
	 encode_m__fight__notice_lover__s2l/1,
	 decode_m__fight__notice_lover__s2l/1,
	 encode_m__fight__speak__s2l/1,
	 decode_m__fight__speak__s2l/1,
	 encode_m__fight__speak__l2s/1,
	 decode_m__fight__speak__l2s/1,
	 encode_m__fight__notice_op__l2s/1,
	 decode_m__fight__notice_op__l2s/1,
	 encode_m__fight__notice_op__s2l/1,
	 decode_m__fight__notice_op__s2l/1,
	 encode_m__fight__notice_duty__s2l/1,
	 decode_m__fight__notice_duty__s2l/1,
	 encode_m__fight__game_state_change__s2l/1,
	 decode_m__fight__game_state_change__s2l/1,
	 encode_m__chat__public_speak__s2l/1,
	 decode_m__chat__public_speak__s2l/1,
	 encode_m__chat__public_speak__l2s/1,
	 decode_m__chat__public_speak__l2s/1, encode_p_chat/1,
	 decode_p_chat/1,
	 encode_m__room__get_not_full_normal_room_id_list__s2l/1,
	 decode_m__room__get_not_full_normal_room_id_list__s2l/1,
	 encode_m__room__get_not_full_normal_room_id_list__l2s/1,
	 decode_m__room__get_not_full_normal_room_id_list__l2s/1,
	 encode_m__room__get_room_info_fail__s2l/1,
	 decode_m__room__get_room_info_fail__s2l/1,
	 encode_m__room__get_room_info__s2l/1,
	 decode_m__room__get_room_info__s2l/1,
	 encode_m__room__get_room_info__l2s/1,
	 decode_m__room__get_room_info__l2s/1,
	 encode_m__room__enter_simple_room__l2s/1,
	 decode_m__room__enter_simple_room__l2s/1,
	 encode_m__room__enter_fail__s2l/1,
	 decode_m__room__enter_fail__s2l/1,
	 encode_m__room__login_not_in_room__s2l/1,
	 decode_m__room__login_not_in_room__s2l/1,
	 encode_m__room__notice_all_ready__s2l/1,
	 decode_m__room__notice_all_ready__s2l/1,
	 encode_m__room__cancle_ready__l2s/1,
	 decode_m__room__cancle_ready__l2s/1,
	 encode_m__room__ready__l2s/1,
	 decode_m__room__ready__l2s/1,
	 encode_m__room__kick_player__s2l/1,
	 decode_m__room__kick_player__s2l/1,
	 encode_m__room__kick_player__l2s/1,
	 decode_m__room__kick_player__l2s/1,
	 encode_m__room__send_gift__s2l/1,
	 decode_m__room__send_gift__s2l/1,
	 encode_m__room__send_gift__l2s/1,
	 decode_m__room__send_gift__l2s/1,
	 encode_m__room__notice_chat_info__s2l/1,
	 decode_m__room__notice_chat_info__s2l/1,
	 encode_m__room__want_chat_list__s2l/1,
	 decode_m__room__want_chat_list__s2l/1,
	 encode_m__room__want_chat_list__l2s/1,
	 decode_m__room__want_chat_list__l2s/1,
	 encode_m__room__end_chat__l2s/1,
	 decode_m__room__end_chat__l2s/1,
	 encode_m__room__notice_start_chat__s2l/1,
	 decode_m__room__notice_start_chat__s2l/1,
	 encode_m__room__want_chat__s2l/1,
	 decode_m__room__want_chat__s2l/1,
	 encode_m__room__want_chat__l2s/1,
	 decode_m__room__want_chat__l2s/1,
	 encode_m__room__notice_member_change__s2l/1,
	 decode_m__room__notice_member_change__s2l/1,
	 encode_m__room__start_fight__l2s/1,
	 decode_m__room__start_fight__l2s/1,
	 encode_m__room__rand_enter__l2s/1,
	 decode_m__room__rand_enter__l2s/1,
	 encode_m__room__leave_room__s2l/1,
	 decode_m__room__leave_room__s2l/1,
	 encode_m__room__leave_room__l2s/1,
	 decode_m__room__leave_room__l2s/1,
	 encode_m__room__create_room__s2l/1,
	 decode_m__room__create_room__s2l/1,
	 encode_m__room__create_room__l2s/1,
	 decode_m__room__create_room__l2s/1,
	 encode_m__room__enter_room__s2l/1,
	 decode_m__room__enter_room__s2l/1,
	 encode_m__room__enter_room__l2s/1,
	 decode_m__room__enter_room__l2s/1,
	 encode_m__room__get_list__s2l/1,
	 decode_m__room__get_list__s2l/1, encode_p_room/1,
	 decode_p_room/1, encode_p_fight/1, decode_p_fight/1,
	 encode_m__room__get_list__l2s/1,
	 decode_m__room__get_list__l2s/1,
	 encode_m__player__friend_invite__s2l/1,
	 decode_m__player__friend_invite__s2l/1,
	 encode_m__player__invite_friends__s2l/1,
	 decode_m__player__invite_friends__s2l/1,
	 encode_m__player__invite_friends__l2s/1,
	 decode_m__player__invite_friends__l2s/1,
	 encode_m__player__get_head_img_name__s2l/1,
	 decode_m__player__get_head_img_name__s2l/1,
	 encode_m__player__get_head_img_name__l2s/1,
	 decode_m__player__get_head_img_name__l2s/1,
	 encode_m__player__upload_head_img_name__s2l/1,
	 decode_m__player__upload_head_img_name__s2l/1,
	 encode_m__player__upload_head_img_name__l2s/1,
	 decode_m__player__upload_head_img_name__l2s/1,
	 encode_m__player__change_sex__s2l/1,
	 decode_m__player__change_sex__s2l/1,
	 encode_m__player__change_sex__l2s/1,
	 decode_m__player__change_sex__l2s/1,
	 encode_m__player__get_head__s2l/1,
	 decode_m__player__get_head__s2l/1,
	 encode_m__player__get_head__l2s/1,
	 decode_m__player__get_head__l2s/1,
	 encode_m__player__upload_head__s2l/1,
	 decode_m__player__upload_head__s2l/1,
	 encode_m__player__upload_head__l2s/1,
	 decode_m__player__upload_head__l2s/1,
	 encode_m__player__kick__s2l/1,
	 decode_m__player__kick__s2l/1,
	 encode_m__player__change_name__s2l/1,
	 decode_m__player__change_name__s2l/1,
	 encode_m__player__change_name__l2s/1,
	 decode_m__player__change_name__l2s/1,
	 encode_m__player__add_diamond__l2s/1,
	 decode_m__player__add_diamond__l2s/1,
	 encode_m__player__add_coin__l2s/1,
	 decode_m__player__add_coin__l2s/1,
	 encode_m__player__other_info__l2s/1,
	 decode_m__player__other_info__l2s/1,
	 encode_m__player__errcode__s2l/1,
	 decode_m__player__errcode__s2l/1,
	 encode_m__player__info__s2l/1,
	 decode_m__player__info__s2l/1, encode_p_win_rate/1,
	 decode_p_win_rate/1, encode_m__player__info__l2s/1,
	 decode_m__player__info__l2s/1,
	 encode_m__account__heart_beat__s2l/1,
	 decode_m__account__heart_beat__s2l/1,
	 encode_m__account__heart_beat__l2s/1,
	 decode_m__account__heart_beat__l2s/1,
	 encode_m__account__login__s2l/1,
	 decode_m__account__login__s2l/1,
	 encode_m__account__login__l2s/1,
	 decode_m__account__login__l2s/1, encode_p_resource/1,
	 decode_p_resource/1, encode_p_player_show_base/1,
	 decode_p_player_show_base/1]).

-record(m__friend__remove_friend__s2l,
	{msg_id, remove_friend}).

-record(m__friend__add_friend__s2l, {msg_id, friend}).

-record(m__friend__get_chat_list__s2l,
	{msg_id, chat_list}).

-record(m__friend__get_chat_list__l2s,
	{msg_id, friend_id}).

-record(m__friend__private_chat__s2l,
	{msg_id, target_info, speak_info, chat}).

-record(m__friend__private_chat__l2s,
	{msg_id, chat, target_id}).

-record(m__friend__remove_friend__l2s,
	{msg_id, remove_friend}).

-record(m__friend__add_friend__l2s,
	{msg_id, add_friend}).

-record(m__friend__get_friend__s2l,
	{msg_id, friend_list}).

-record(m__friend__get_friend__l2s, {msg_id}).

-record(p_friend, {player_show_base, status, room_id}).

-record(m__rank__get_rank__s2l,
	{msg_id, rank_type, start_rank, end_rank, rank_list}).

-record(m__rank__get_rank__l2s,
	{msg_id, rank_type, start_rank, end_rank}).

-record(p_rank, {player_show_base, rank, value}).

-record(m__match__enter_match_list__s2l,
	{msg_id, wait_id, ready_list, wait_list}).

-record(m__match__enter_match__l2s,
	{msg_id, mode, wait_id}).

-record(m__match__notice_enter_match__s2l,
	{msg_id, wait_id, mode, wait_list}).

-record(m__match__again_match__s2l,
	{msg_id, mode, is_again}).

-record(m__match__end_match__s2l, {msg_id}).

-record(m__match__end_match__l2s, {msg_id, mode}).

-record(m__match__start_match__l2s,
	{msg_id, mode, player_list}).

-record(m__resource__push__s2l,
	{msg_id, resource_id, num, action_id}).

-record(m__fight__end_info__s2l,
	{msg_id, duty_list, die_info, result_type}).

-record(p_die_info,
	{seat_id, die_type, game_round, is_night}).

-record(m__fight__daozei_op__s2l, {msg_id, duty}).

-record(m__fight_over_error__s2l,
	{msg_id, room_id, reason}).

-record(m__fight__nvwu_op__s2l,
	{msg_id, du_seat_id, save_seat_id}).

-record(m__fight__langren_op__s2l, {msg_id, seat_id}).

-record(m__fight__dync_langren_op_data__s2l,
	{msg_id, op_data}).

-record(m__fight__chat_input__s2l,
	{msg_id, is_expression, chat_type, player_id, content}).

-record(m__fight__chat_input__l2s,
	{msg_id, is_expression, chat_type, content}).

-record(m__fight__forbid_other_speak__s2l,
	{msg_id, forbid_info}).

-record(m__fight__forbid_other_speak__l2s,
	{msg_id, is_forbid}).

-record(m__fight__notice_langren__s2l,
	{msg_id, langren_list, bailang_list}).

-record(m__fight__select_duty__s2l,
	{msg_id, result, duty, seat_id}).

-record(m__fight__random_duty__s2l,
	{msg_id, left_time, duty_list}).

-record(m__fight__update_duty__s2l,
	{msg_id, pre_duty, cur_duty}).

-record(m__fight__leave__s2l, {msg_id, leave_list}).

-record(m__fight__over_info__s2l,
	{msg_id, winner, duty_list, dead_list}).

-record(m__fight__shouwei_op__s2l, {msg_id, seat_id}).

-record(m__fight__langren_team_speak__s2l,
	{msg_id, chat}).

-record(m__fight__op_timetick__s2l,
	{msg_id, timetick, wait_op}).

-record(m__fight__offline__s2l, {msg_id, offline_list}).

-record(m__fight__online__s2l,
	{msg_id, duty, game_status, round, die_list, seat_id,
	 attach_data1, attach_data2, offline_list, leave_list,
	 flop_list, winner, wait_op, wait_op_list,
	 wait_op_attach_data, wait_op_tick, jingzhang,
	 lover_list, duty_list, parting_jingzhang, fight_info,
	 duty_select_over, duty_select_time, duty_select_info,
	 is_night, fight_mode, speak_forbid_info, game_round,
	 night_op_left_time, bailang_list,
	 duty_select_seat_list}).

-record(p_flop, {seat_id, op}).

-record(m__fight__do_skill__l2s, {msg_id, op, op_list}).

-record(m__fight__notice_skill__s2l,
	{msg_id, op, op_list, seat_id}).

-record(m__fight__notice_part_jingzhang__s2l,
	{msg_id, seat_list}).

-record(m__fight__notice_hunxuer__s2l,
	{msg_id, select_seat}).

-record(m__fight__stop_fayan__s2l, {msg_id, seat_id}).

-record(m__fight__notice_fayan__s2l, {msg_id, seat_id}).

-record(m__fight__guipiao__s2l, {msg_id, guipiao_list}).

-record(m__fight__result__s2l,
	{msg_id, winner, duty_list, lover, hunxuer, daozei, mvp,
	 carry, coin_add, cur_level, cur_exp, exp_add,
	 pre_level_up_exp, level_up_exp, next_level_up_exp,
	 victory_party, room_id, own_seat_id, third_list,
	 rank_add}).

-record(p_duty, {seat_id, duty_id, player_id}).

-record(m__fight__night_result__s2l,
	{msg_id, die_list}).

-record(m__fight__xuanju_result__s2l,
	{msg_id, xuanju_type, result_list, is_draw, result_id,
	 max_list}).

-record(p_xuanju_result, {seat_id, select_list}).

-record(m__fight__notice_yuyanjia_result__s2l,
	{msg_id, seat_id, duty}).

-record(m__fight__notice_lover__s2l,
	{msg_id, lover_list}).

-record(m__fight__speak__s2l,
	{msg_id, chat, player_id}).

-record(m__fight__speak__l2s,
	{msg_id, chat, speak_type}).

-record(m__fight__notice_op__l2s,
	{msg_id, op, op_list, confirm}).

-record(m__fight__notice_op__s2l,
	{msg_id, op, attach_data}).

-record(m__fight__notice_duty__s2l,
	{msg_id, duty, seat_id, fight_info, fight_mode,
	 duty_valid}).

-record(m__fight__game_state_change__s2l,
	{msg_id, game_status, attach_data}).

-record(m__chat__public_speak__s2l,
	{msg_id, chat, player_id}).

-record(m__chat__public_speak__l2s, {msg_id, chat}).

-record(p_chat,
	{voice, content, length, compress, chat_type, room_id,
	 msg_type}).

-record(m__room__get_not_full_normal_room_id_list__s2l,
	{msg_id, room_id_list}).

-record(m__room__get_not_full_normal_room_id_list__l2s,
	{msg_id}).

-record(m__room__get_room_info_fail__s2l,
	{msg_id, reason}).

-record(m__room__get_room_info__s2l,
	{msg_id, room_info}).

-record(m__room__get_room_info__l2s, {msg_id, room_id}).

-record(m__room__enter_simple_room__l2s, {msg_id}).

-record(m__room__enter_fail__s2l, {msg_id, result}).

-record(m__room__login_not_in_room__s2l, {msg_id}).

-record(m__room__notice_all_ready__s2l, {msg_id}).

-record(m__room__cancle_ready__l2s, {msg_id}).

-record(m__room__ready__l2s, {msg_id}).

-record(m__room__kick_player__s2l,
	{msg_id, kicked_player_id, player_name, result}).

-record(m__room__kick_player__l2s,
	{msg_id, kicked_player_id}).

-record(m__room__send_gift__s2l,
	{msg_id, gift_id, player_id, result, luck_add}).

-record(m__room__send_gift__l2s,
	{msg_id, gift_id, player_id}).

-record(m__room__notice_chat_info__s2l,
	{msg_id, player_id, wait_time}).

-record(m__room__want_chat_list__s2l,
	{msg_id, wait_list}).

-record(m__room__want_chat_list__l2s, {msg_id}).

-record(m__room__end_chat__l2s, {msg_id}).

-record(m__room__notice_start_chat__s2l,
	{msg_id, start_id, wait_list, duration}).

-record(m__room__want_chat__s2l, {msg_id, wait_list}).

-record(m__room__want_chat__l2s, {msg_id}).

-record(m__room__notice_member_change__s2l,
	{msg_id, room_info, member_list}).

-record(m__room__start_fight__l2s, {msg_id}).

-record(m__room__rand_enter__l2s, {msg_id}).

-record(m__room__leave_room__s2l, {msg_id, result}).

-record(m__room__leave_room__l2s, {msg_id}).

-record(m__room__create_room__s2l, {msg_id, room_info}).

-record(m__room__create_room__l2s,
	{msg_id, max_player_num, room_name, duty_list}).

-record(m__room__enter_room__s2l,
	{msg_id, room_info, member_list}).

-record(m__room__enter_room__l2s, {msg_id, room_id}).

-record(m__room__get_list__s2l, {msg_id, room_list}).

-record(p_room,
	{room_id, cur_player_num, max_player_num, owner,
	 room_name, room_status, duty_list, ready_list}).

-record(p_fight,
	{room_name, duty_list, player_info_list}).

-record(m__room__get_list__l2s, {msg_id}).

-record(m__player__friend_invite__s2l,
	{msg_id, player_info, room_id}).

-record(m__player__invite_friends__s2l, {msg_id}).

-record(m__player__invite_friends__l2s,
	{msg_id, player_list, room_id}).

-record(m__player__get_head_img_name__s2l,
	{msg_id, player_id, head_img_name}).

-record(m__player__get_head_img_name__l2s,
	{msg_id, player_id}).

-record(m__player__upload_head_img_name__s2l, {msg_id}).

-record(m__player__upload_head_img_name__l2s,
	{msg_id, head_img_name}).

-record(m__player__change_sex__s2l, {msg_id, sex}).

-record(m__player__change_sex__l2s, {msg_id, sex}).

-record(m__player__get_head__s2l,
	{msg_id, player_id, img_data}).

-record(m__player__get_head__l2s, {msg_id, player_id}).

-record(m__player__upload_head__s2l, {msg_id, result}).

-record(m__player__upload_head__l2s,
	{msg_id, img_data}).

-record(m__player__kick__s2l, {msg_id, kick_reason}).

-record(m__player__change_name__s2l,
	{msg_id, name, result}).

-record(m__player__change_name__l2s, {msg_id, name}).

-record(m__player__add_diamond__l2s, {msg_id}).

-record(m__player__add_coin__l2s, {msg_id}).

-record(m__player__other_info__l2s,
	{msg_id, player_id}).

-record(m__player__errcode__s2l, {msg_id, errcode}).

-record(m__player__info__s2l,
	{msg_id, player_id, nick_name, grade, month_vip, equip,
	 resource_list, win_rate_list, other_player, sex,
	 head_img_name}).

-record(p_win_rate, {duty_id, win_cnt, all_cnt}).

-record(m__player__info__l2s, {msg_id}).

-record(m__account__heart_beat__s2l, {msg_id}).

-record(m__account__heart_beat__l2s, {msg_id}).

-record(m__account__login__s2l, {msg_id, result}).

-record(m__account__login__l2s, {msg_id, account_name}).

-record(p_resource, {resource_id, num}).

-record(p_player_show_base,
	{player_id, nick_name, head_img_name}).

encode(Record) ->
    encode(erlang:element(1, Record), Record).

encode_m__friend__remove_friend__s2l(Record)
    when is_record(Record, m__friend__remove_friend__s2l) ->
    encode(m__friend__remove_friend__s2l, Record).

encode_m__friend__add_friend__s2l(Record)
    when is_record(Record, m__friend__add_friend__s2l) ->
    encode(m__friend__add_friend__s2l, Record).

encode_m__friend__get_chat_list__s2l(Record)
    when is_record(Record, m__friend__get_chat_list__s2l) ->
    encode(m__friend__get_chat_list__s2l, Record).

encode_m__friend__get_chat_list__l2s(Record)
    when is_record(Record, m__friend__get_chat_list__l2s) ->
    encode(m__friend__get_chat_list__l2s, Record).

encode_m__friend__private_chat__s2l(Record)
    when is_record(Record, m__friend__private_chat__s2l) ->
    encode(m__friend__private_chat__s2l, Record).

encode_m__friend__private_chat__l2s(Record)
    when is_record(Record, m__friend__private_chat__l2s) ->
    encode(m__friend__private_chat__l2s, Record).

encode_m__friend__remove_friend__l2s(Record)
    when is_record(Record, m__friend__remove_friend__l2s) ->
    encode(m__friend__remove_friend__l2s, Record).

encode_m__friend__add_friend__l2s(Record)
    when is_record(Record, m__friend__add_friend__l2s) ->
    encode(m__friend__add_friend__l2s, Record).

encode_m__friend__get_friend__s2l(Record)
    when is_record(Record, m__friend__get_friend__s2l) ->
    encode(m__friend__get_friend__s2l, Record).

encode_m__friend__get_friend__l2s(Record)
    when is_record(Record, m__friend__get_friend__l2s) ->
    encode(m__friend__get_friend__l2s, Record).

encode_p_friend(Record)
    when is_record(Record, p_friend) ->
    encode(p_friend, Record).

encode_m__rank__get_rank__s2l(Record)
    when is_record(Record, m__rank__get_rank__s2l) ->
    encode(m__rank__get_rank__s2l, Record).

encode_m__rank__get_rank__l2s(Record)
    when is_record(Record, m__rank__get_rank__l2s) ->
    encode(m__rank__get_rank__l2s, Record).

encode_p_rank(Record) when is_record(Record, p_rank) ->
    encode(p_rank, Record).

encode_m__match__enter_match_list__s2l(Record)
    when is_record(Record,
		   m__match__enter_match_list__s2l) ->
    encode(m__match__enter_match_list__s2l, Record).

encode_m__match__enter_match__l2s(Record)
    when is_record(Record, m__match__enter_match__l2s) ->
    encode(m__match__enter_match__l2s, Record).

encode_m__match__notice_enter_match__s2l(Record)
    when is_record(Record,
		   m__match__notice_enter_match__s2l) ->
    encode(m__match__notice_enter_match__s2l, Record).

encode_m__match__again_match__s2l(Record)
    when is_record(Record, m__match__again_match__s2l) ->
    encode(m__match__again_match__s2l, Record).

encode_m__match__end_match__s2l(Record)
    when is_record(Record, m__match__end_match__s2l) ->
    encode(m__match__end_match__s2l, Record).

encode_m__match__end_match__l2s(Record)
    when is_record(Record, m__match__end_match__l2s) ->
    encode(m__match__end_match__l2s, Record).

encode_m__match__start_match__l2s(Record)
    when is_record(Record, m__match__start_match__l2s) ->
    encode(m__match__start_match__l2s, Record).

encode_m__resource__push__s2l(Record)
    when is_record(Record, m__resource__push__s2l) ->
    encode(m__resource__push__s2l, Record).

encode_m__fight__end_info__s2l(Record)
    when is_record(Record, m__fight__end_info__s2l) ->
    encode(m__fight__end_info__s2l, Record).

encode_p_die_info(Record)
    when is_record(Record, p_die_info) ->
    encode(p_die_info, Record).

encode_m__fight__daozei_op__s2l(Record)
    when is_record(Record, m__fight__daozei_op__s2l) ->
    encode(m__fight__daozei_op__s2l, Record).

encode_m__fight_over_error__s2l(Record)
    when is_record(Record, m__fight_over_error__s2l) ->
    encode(m__fight_over_error__s2l, Record).

encode_m__fight__nvwu_op__s2l(Record)
    when is_record(Record, m__fight__nvwu_op__s2l) ->
    encode(m__fight__nvwu_op__s2l, Record).

encode_m__fight__langren_op__s2l(Record)
    when is_record(Record, m__fight__langren_op__s2l) ->
    encode(m__fight__langren_op__s2l, Record).

encode_m__fight__dync_langren_op_data__s2l(Record)
    when is_record(Record,
		   m__fight__dync_langren_op_data__s2l) ->
    encode(m__fight__dync_langren_op_data__s2l, Record).

encode_m__fight__chat_input__s2l(Record)
    when is_record(Record, m__fight__chat_input__s2l) ->
    encode(m__fight__chat_input__s2l, Record).

encode_m__fight__chat_input__l2s(Record)
    when is_record(Record, m__fight__chat_input__l2s) ->
    encode(m__fight__chat_input__l2s, Record).

encode_m__fight__forbid_other_speak__s2l(Record)
    when is_record(Record,
		   m__fight__forbid_other_speak__s2l) ->
    encode(m__fight__forbid_other_speak__s2l, Record).

encode_m__fight__forbid_other_speak__l2s(Record)
    when is_record(Record,
		   m__fight__forbid_other_speak__l2s) ->
    encode(m__fight__forbid_other_speak__l2s, Record).

encode_m__fight__notice_langren__s2l(Record)
    when is_record(Record, m__fight__notice_langren__s2l) ->
    encode(m__fight__notice_langren__s2l, Record).

encode_m__fight__select_duty__s2l(Record)
    when is_record(Record, m__fight__select_duty__s2l) ->
    encode(m__fight__select_duty__s2l, Record).

encode_m__fight__random_duty__s2l(Record)
    when is_record(Record, m__fight__random_duty__s2l) ->
    encode(m__fight__random_duty__s2l, Record).

encode_m__fight__update_duty__s2l(Record)
    when is_record(Record, m__fight__update_duty__s2l) ->
    encode(m__fight__update_duty__s2l, Record).

encode_m__fight__leave__s2l(Record)
    when is_record(Record, m__fight__leave__s2l) ->
    encode(m__fight__leave__s2l, Record).

encode_m__fight__over_info__s2l(Record)
    when is_record(Record, m__fight__over_info__s2l) ->
    encode(m__fight__over_info__s2l, Record).

encode_m__fight__shouwei_op__s2l(Record)
    when is_record(Record, m__fight__shouwei_op__s2l) ->
    encode(m__fight__shouwei_op__s2l, Record).

encode_m__fight__langren_team_speak__s2l(Record)
    when is_record(Record,
		   m__fight__langren_team_speak__s2l) ->
    encode(m__fight__langren_team_speak__s2l, Record).

encode_m__fight__op_timetick__s2l(Record)
    when is_record(Record, m__fight__op_timetick__s2l) ->
    encode(m__fight__op_timetick__s2l, Record).

encode_m__fight__offline__s2l(Record)
    when is_record(Record, m__fight__offline__s2l) ->
    encode(m__fight__offline__s2l, Record).

encode_m__fight__online__s2l(Record)
    when is_record(Record, m__fight__online__s2l) ->
    encode(m__fight__online__s2l, Record).

encode_p_flop(Record) when is_record(Record, p_flop) ->
    encode(p_flop, Record).

encode_m__fight__do_skill__l2s(Record)
    when is_record(Record, m__fight__do_skill__l2s) ->
    encode(m__fight__do_skill__l2s, Record).

encode_m__fight__notice_skill__s2l(Record)
    when is_record(Record, m__fight__notice_skill__s2l) ->
    encode(m__fight__notice_skill__s2l, Record).

encode_m__fight__notice_part_jingzhang__s2l(Record)
    when is_record(Record,
		   m__fight__notice_part_jingzhang__s2l) ->
    encode(m__fight__notice_part_jingzhang__s2l, Record).

encode_m__fight__notice_hunxuer__s2l(Record)
    when is_record(Record, m__fight__notice_hunxuer__s2l) ->
    encode(m__fight__notice_hunxuer__s2l, Record).

encode_m__fight__stop_fayan__s2l(Record)
    when is_record(Record, m__fight__stop_fayan__s2l) ->
    encode(m__fight__stop_fayan__s2l, Record).

encode_m__fight__notice_fayan__s2l(Record)
    when is_record(Record, m__fight__notice_fayan__s2l) ->
    encode(m__fight__notice_fayan__s2l, Record).

encode_m__fight__guipiao__s2l(Record)
    when is_record(Record, m__fight__guipiao__s2l) ->
    encode(m__fight__guipiao__s2l, Record).

encode_m__fight__result__s2l(Record)
    when is_record(Record, m__fight__result__s2l) ->
    encode(m__fight__result__s2l, Record).

encode_p_duty(Record) when is_record(Record, p_duty) ->
    encode(p_duty, Record).

encode_m__fight__night_result__s2l(Record)
    when is_record(Record, m__fight__night_result__s2l) ->
    encode(m__fight__night_result__s2l, Record).

encode_m__fight__xuanju_result__s2l(Record)
    when is_record(Record, m__fight__xuanju_result__s2l) ->
    encode(m__fight__xuanju_result__s2l, Record).

encode_p_xuanju_result(Record)
    when is_record(Record, p_xuanju_result) ->
    encode(p_xuanju_result, Record).

encode_m__fight__notice_yuyanjia_result__s2l(Record)
    when is_record(Record,
		   m__fight__notice_yuyanjia_result__s2l) ->
    encode(m__fight__notice_yuyanjia_result__s2l, Record).

encode_m__fight__notice_lover__s2l(Record)
    when is_record(Record, m__fight__notice_lover__s2l) ->
    encode(m__fight__notice_lover__s2l, Record).

encode_m__fight__speak__s2l(Record)
    when is_record(Record, m__fight__speak__s2l) ->
    encode(m__fight__speak__s2l, Record).

encode_m__fight__speak__l2s(Record)
    when is_record(Record, m__fight__speak__l2s) ->
    encode(m__fight__speak__l2s, Record).

encode_m__fight__notice_op__l2s(Record)
    when is_record(Record, m__fight__notice_op__l2s) ->
    encode(m__fight__notice_op__l2s, Record).

encode_m__fight__notice_op__s2l(Record)
    when is_record(Record, m__fight__notice_op__s2l) ->
    encode(m__fight__notice_op__s2l, Record).

encode_m__fight__notice_duty__s2l(Record)
    when is_record(Record, m__fight__notice_duty__s2l) ->
    encode(m__fight__notice_duty__s2l, Record).

encode_m__fight__game_state_change__s2l(Record)
    when is_record(Record,
		   m__fight__game_state_change__s2l) ->
    encode(m__fight__game_state_change__s2l, Record).

encode_m__chat__public_speak__s2l(Record)
    when is_record(Record, m__chat__public_speak__s2l) ->
    encode(m__chat__public_speak__s2l, Record).

encode_m__chat__public_speak__l2s(Record)
    when is_record(Record, m__chat__public_speak__l2s) ->
    encode(m__chat__public_speak__l2s, Record).

encode_p_chat(Record) when is_record(Record, p_chat) ->
    encode(p_chat, Record).

encode_m__room__get_not_full_normal_room_id_list__s2l(Record)
    when is_record(Record,
		   m__room__get_not_full_normal_room_id_list__s2l) ->
    encode(m__room__get_not_full_normal_room_id_list__s2l,
	   Record).

encode_m__room__get_not_full_normal_room_id_list__l2s(Record)
    when is_record(Record,
		   m__room__get_not_full_normal_room_id_list__l2s) ->
    encode(m__room__get_not_full_normal_room_id_list__l2s,
	   Record).

encode_m__room__get_room_info_fail__s2l(Record)
    when is_record(Record,
		   m__room__get_room_info_fail__s2l) ->
    encode(m__room__get_room_info_fail__s2l, Record).

encode_m__room__get_room_info__s2l(Record)
    when is_record(Record, m__room__get_room_info__s2l) ->
    encode(m__room__get_room_info__s2l, Record).

encode_m__room__get_room_info__l2s(Record)
    when is_record(Record, m__room__get_room_info__l2s) ->
    encode(m__room__get_room_info__l2s, Record).

encode_m__room__enter_simple_room__l2s(Record)
    when is_record(Record,
		   m__room__enter_simple_room__l2s) ->
    encode(m__room__enter_simple_room__l2s, Record).

encode_m__room__enter_fail__s2l(Record)
    when is_record(Record, m__room__enter_fail__s2l) ->
    encode(m__room__enter_fail__s2l, Record).

encode_m__room__login_not_in_room__s2l(Record)
    when is_record(Record,
		   m__room__login_not_in_room__s2l) ->
    encode(m__room__login_not_in_room__s2l, Record).

encode_m__room__notice_all_ready__s2l(Record)
    when is_record(Record,
		   m__room__notice_all_ready__s2l) ->
    encode(m__room__notice_all_ready__s2l, Record).

encode_m__room__cancle_ready__l2s(Record)
    when is_record(Record, m__room__cancle_ready__l2s) ->
    encode(m__room__cancle_ready__l2s, Record).

encode_m__room__ready__l2s(Record)
    when is_record(Record, m__room__ready__l2s) ->
    encode(m__room__ready__l2s, Record).

encode_m__room__kick_player__s2l(Record)
    when is_record(Record, m__room__kick_player__s2l) ->
    encode(m__room__kick_player__s2l, Record).

encode_m__room__kick_player__l2s(Record)
    when is_record(Record, m__room__kick_player__l2s) ->
    encode(m__room__kick_player__l2s, Record).

encode_m__room__send_gift__s2l(Record)
    when is_record(Record, m__room__send_gift__s2l) ->
    encode(m__room__send_gift__s2l, Record).

encode_m__room__send_gift__l2s(Record)
    when is_record(Record, m__room__send_gift__l2s) ->
    encode(m__room__send_gift__l2s, Record).

encode_m__room__notice_chat_info__s2l(Record)
    when is_record(Record,
		   m__room__notice_chat_info__s2l) ->
    encode(m__room__notice_chat_info__s2l, Record).

encode_m__room__want_chat_list__s2l(Record)
    when is_record(Record, m__room__want_chat_list__s2l) ->
    encode(m__room__want_chat_list__s2l, Record).

encode_m__room__want_chat_list__l2s(Record)
    when is_record(Record, m__room__want_chat_list__l2s) ->
    encode(m__room__want_chat_list__l2s, Record).

encode_m__room__end_chat__l2s(Record)
    when is_record(Record, m__room__end_chat__l2s) ->
    encode(m__room__end_chat__l2s, Record).

encode_m__room__notice_start_chat__s2l(Record)
    when is_record(Record,
		   m__room__notice_start_chat__s2l) ->
    encode(m__room__notice_start_chat__s2l, Record).

encode_m__room__want_chat__s2l(Record)
    when is_record(Record, m__room__want_chat__s2l) ->
    encode(m__room__want_chat__s2l, Record).

encode_m__room__want_chat__l2s(Record)
    when is_record(Record, m__room__want_chat__l2s) ->
    encode(m__room__want_chat__l2s, Record).

encode_m__room__notice_member_change__s2l(Record)
    when is_record(Record,
		   m__room__notice_member_change__s2l) ->
    encode(m__room__notice_member_change__s2l, Record).

encode_m__room__start_fight__l2s(Record)
    when is_record(Record, m__room__start_fight__l2s) ->
    encode(m__room__start_fight__l2s, Record).

encode_m__room__rand_enter__l2s(Record)
    when is_record(Record, m__room__rand_enter__l2s) ->
    encode(m__room__rand_enter__l2s, Record).

encode_m__room__leave_room__s2l(Record)
    when is_record(Record, m__room__leave_room__s2l) ->
    encode(m__room__leave_room__s2l, Record).

encode_m__room__leave_room__l2s(Record)
    when is_record(Record, m__room__leave_room__l2s) ->
    encode(m__room__leave_room__l2s, Record).

encode_m__room__create_room__s2l(Record)
    when is_record(Record, m__room__create_room__s2l) ->
    encode(m__room__create_room__s2l, Record).

encode_m__room__create_room__l2s(Record)
    when is_record(Record, m__room__create_room__l2s) ->
    encode(m__room__create_room__l2s, Record).

encode_m__room__enter_room__s2l(Record)
    when is_record(Record, m__room__enter_room__s2l) ->
    encode(m__room__enter_room__s2l, Record).

encode_m__room__enter_room__l2s(Record)
    when is_record(Record, m__room__enter_room__l2s) ->
    encode(m__room__enter_room__l2s, Record).

encode_m__room__get_list__s2l(Record)
    when is_record(Record, m__room__get_list__s2l) ->
    encode(m__room__get_list__s2l, Record).

encode_p_room(Record) when is_record(Record, p_room) ->
    encode(p_room, Record).

encode_p_fight(Record)
    when is_record(Record, p_fight) ->
    encode(p_fight, Record).

encode_m__room__get_list__l2s(Record)
    when is_record(Record, m__room__get_list__l2s) ->
    encode(m__room__get_list__l2s, Record).

encode_m__player__friend_invite__s2l(Record)
    when is_record(Record, m__player__friend_invite__s2l) ->
    encode(m__player__friend_invite__s2l, Record).

encode_m__player__invite_friends__s2l(Record)
    when is_record(Record,
		   m__player__invite_friends__s2l) ->
    encode(m__player__invite_friends__s2l, Record).

encode_m__player__invite_friends__l2s(Record)
    when is_record(Record,
		   m__player__invite_friends__l2s) ->
    encode(m__player__invite_friends__l2s, Record).

encode_m__player__get_head_img_name__s2l(Record)
    when is_record(Record,
		   m__player__get_head_img_name__s2l) ->
    encode(m__player__get_head_img_name__s2l, Record).

encode_m__player__get_head_img_name__l2s(Record)
    when is_record(Record,
		   m__player__get_head_img_name__l2s) ->
    encode(m__player__get_head_img_name__l2s, Record).

encode_m__player__upload_head_img_name__s2l(Record)
    when is_record(Record,
		   m__player__upload_head_img_name__s2l) ->
    encode(m__player__upload_head_img_name__s2l, Record).

encode_m__player__upload_head_img_name__l2s(Record)
    when is_record(Record,
		   m__player__upload_head_img_name__l2s) ->
    encode(m__player__upload_head_img_name__l2s, Record).

encode_m__player__change_sex__s2l(Record)
    when is_record(Record, m__player__change_sex__s2l) ->
    encode(m__player__change_sex__s2l, Record).

encode_m__player__change_sex__l2s(Record)
    when is_record(Record, m__player__change_sex__l2s) ->
    encode(m__player__change_sex__l2s, Record).

encode_m__player__get_head__s2l(Record)
    when is_record(Record, m__player__get_head__s2l) ->
    encode(m__player__get_head__s2l, Record).

encode_m__player__get_head__l2s(Record)
    when is_record(Record, m__player__get_head__l2s) ->
    encode(m__player__get_head__l2s, Record).

encode_m__player__upload_head__s2l(Record)
    when is_record(Record, m__player__upload_head__s2l) ->
    encode(m__player__upload_head__s2l, Record).

encode_m__player__upload_head__l2s(Record)
    when is_record(Record, m__player__upload_head__l2s) ->
    encode(m__player__upload_head__l2s, Record).

encode_m__player__kick__s2l(Record)
    when is_record(Record, m__player__kick__s2l) ->
    encode(m__player__kick__s2l, Record).

encode_m__player__change_name__s2l(Record)
    when is_record(Record, m__player__change_name__s2l) ->
    encode(m__player__change_name__s2l, Record).

encode_m__player__change_name__l2s(Record)
    when is_record(Record, m__player__change_name__l2s) ->
    encode(m__player__change_name__l2s, Record).

encode_m__player__add_diamond__l2s(Record)
    when is_record(Record, m__player__add_diamond__l2s) ->
    encode(m__player__add_diamond__l2s, Record).

encode_m__player__add_coin__l2s(Record)
    when is_record(Record, m__player__add_coin__l2s) ->
    encode(m__player__add_coin__l2s, Record).

encode_m__player__other_info__l2s(Record)
    when is_record(Record, m__player__other_info__l2s) ->
    encode(m__player__other_info__l2s, Record).

encode_m__player__errcode__s2l(Record)
    when is_record(Record, m__player__errcode__s2l) ->
    encode(m__player__errcode__s2l, Record).

encode_m__player__info__s2l(Record)
    when is_record(Record, m__player__info__s2l) ->
    encode(m__player__info__s2l, Record).

encode_p_win_rate(Record)
    when is_record(Record, p_win_rate) ->
    encode(p_win_rate, Record).

encode_m__player__info__l2s(Record)
    when is_record(Record, m__player__info__l2s) ->
    encode(m__player__info__l2s, Record).

encode_m__account__heart_beat__s2l(Record)
    when is_record(Record, m__account__heart_beat__s2l) ->
    encode(m__account__heart_beat__s2l, Record).

encode_m__account__heart_beat__l2s(Record)
    when is_record(Record, m__account__heart_beat__l2s) ->
    encode(m__account__heart_beat__l2s, Record).

encode_m__account__login__s2l(Record)
    when is_record(Record, m__account__login__s2l) ->
    encode(m__account__login__s2l, Record).

encode_m__account__login__l2s(Record)
    when is_record(Record, m__account__login__l2s) ->
    encode(m__account__login__l2s, Record).

encode_p_resource(Record)
    when is_record(Record, p_resource) ->
    encode(p_resource, Record).

encode_p_player_show_base(Record)
    when is_record(Record, p_player_show_base) ->
    encode(p_player_show_base, Record).

encode(p_player_show_base, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_player_show_base.player_id,
					none),
			   uint32, []),
		      pack(2, required,
			   with_default(_Record#p_player_show_base.nick_name,
					none),
			   string, []),
		      pack(3, required,
			   with_default(_Record#p_player_show_base.head_img_name,
					none),
			   string, [])]);
encode(p_resource, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_resource.resource_id, none),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#p_resource.num, none), int32,
			   [])]);
encode(m__account__login__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__account__login__l2s.msg_id,
					10001),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__account__login__l2s.account_name,
					none),
			   string, [])]);
encode(m__account__login__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__account__login__s2l.msg_id,
					10002),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__account__login__s2l.result,
					none),
			   int32, [])]);
encode(m__account__heart_beat__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__account__heart_beat__l2s.msg_id,
					10003),
			   int32, [])]);
encode(m__account__heart_beat__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__account__heart_beat__s2l.msg_id,
					10004),
			   int32, [])]);
encode(m__player__info__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__info__l2s.msg_id,
					12001),
			   int32, [])]);
encode(p_win_rate, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_win_rate.duty_id, none),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#p_win_rate.win_cnt, none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#p_win_rate.all_cnt, none),
			   int32, [])]);
encode(m__player__info__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__info__s2l.msg_id,
					12002),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__info__s2l.player_id,
					none),
			   uint32, []),
		      pack(3, required,
			   with_default(_Record#m__player__info__s2l.nick_name,
					none),
			   string, []),
		      pack(4, required,
			   with_default(_Record#m__player__info__s2l.grade,
					none),
			   int32, []),
		      pack(5, required,
			   with_default(_Record#m__player__info__s2l.month_vip,
					none),
			   int32, []),
		      pack(6, required,
			   with_default(_Record#m__player__info__s2l.equip,
					none),
			   int32, []),
		      pack(8, repeated,
			   with_default(_Record#m__player__info__s2l.resource_list,
					none),
			   p_resource, []),
		      pack(9, repeated,
			   with_default(_Record#m__player__info__s2l.win_rate_list,
					none),
			   p_win_rate, []),
		      pack(10, required,
			   with_default(_Record#m__player__info__s2l.other_player,
					none),
			   int32, []),
		      pack(11, required,
			   with_default(_Record#m__player__info__s2l.sex, none),
			   int32, []),
		      pack(12, required,
			   with_default(_Record#m__player__info__s2l.head_img_name,
					none),
			   string, [])]);
encode(m__player__errcode__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__errcode__s2l.msg_id,
					12004),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__errcode__s2l.errcode,
					none),
			   int32, [])]);
encode(m__player__other_info__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__other_info__l2s.msg_id,
					12005),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__other_info__l2s.player_id,
					none),
			   uint32, [])]);
encode(m__player__add_coin__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__add_coin__l2s.msg_id,
					12006),
			   int32, [])]);
encode(m__player__add_diamond__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__add_diamond__l2s.msg_id,
					12007),
			   int32, [])]);
encode(m__player__change_name__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__change_name__l2s.msg_id,
					12008),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__change_name__l2s.name,
					none),
			   string, [])]);
encode(m__player__change_name__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__change_name__s2l.msg_id,
					12009),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__change_name__s2l.name,
					none),
			   string, []),
		      pack(3, required,
			   with_default(_Record#m__player__change_name__s2l.result,
					none),
			   int32, [])]);
encode(m__player__kick__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__kick__s2l.msg_id,
					12010),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__kick__s2l.kick_reason,
					none),
			   int32, [])]);
encode(m__player__upload_head__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__upload_head__l2s.msg_id,
					12011),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__upload_head__l2s.img_data,
					none),
			   bytes, [])]);
encode(m__player__upload_head__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__upload_head__s2l.msg_id,
					12012),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__upload_head__s2l.result,
					none),
			   int32, [])]);
encode(m__player__get_head__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__get_head__l2s.msg_id,
					12013),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__get_head__l2s.player_id,
					none),
			   uint32, [])]);
encode(m__player__get_head__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__get_head__s2l.msg_id,
					12014),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__get_head__s2l.player_id,
					none),
			   uint32, []),
		      pack(3, required,
			   with_default(_Record#m__player__get_head__s2l.img_data,
					none),
			   bytes, [])]);
encode(m__player__change_sex__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__change_sex__l2s.msg_id,
					12015),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__change_sex__l2s.sex,
					none),
			   int32, [])]);
encode(m__player__change_sex__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__change_sex__s2l.msg_id,
					12016),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__change_sex__s2l.sex,
					none),
			   int32, [])]);
encode(m__player__upload_head_img_name__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__upload_head_img_name__l2s.msg_id,
					12017),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__upload_head_img_name__l2s.head_img_name,
					none),
			   string, [])]);
encode(m__player__upload_head_img_name__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__upload_head_img_name__s2l.msg_id,
					12018),
			   int32, [])]);
encode(m__player__get_head_img_name__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__get_head_img_name__l2s.msg_id,
					12019),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__get_head_img_name__l2s.player_id,
					none),
			   uint32, [])]);
encode(m__player__get_head_img_name__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__get_head_img_name__s2l.msg_id,
					12020),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__get_head_img_name__s2l.player_id,
					none),
			   uint32, []),
		      pack(3, required,
			   with_default(_Record#m__player__get_head_img_name__s2l.head_img_name,
					none),
			   string, [])]);
encode(m__player__invite_friends__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__invite_friends__l2s.msg_id,
					12021),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__player__invite_friends__l2s.player_list,
					none),
			   uint32, []),
		      pack(3, required,
			   with_default(_Record#m__player__invite_friends__l2s.room_id,
					none),
			   int32, [])]);
encode(m__player__invite_friends__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__invite_friends__s2l.msg_id,
					12022),
			   int32, [])]);
encode(m__player__friend_invite__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__friend_invite__s2l.msg_id,
					12023),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__friend_invite__s2l.player_info,
					none),
			   p_player_show_base, []),
		      pack(3, required,
			   with_default(_Record#m__player__friend_invite__s2l.room_id,
					none),
			   int32, [])]);
encode(m__room__get_list__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__get_list__l2s.msg_id,
					13001),
			   int32, [])]);
encode(p_fight, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_fight.room_name, none),
			   string, []),
		      pack(2, repeated,
			   with_default(_Record#p_fight.duty_list, none), int32,
			   []),
		      pack(4, repeated,
			   with_default(_Record#p_fight.player_info_list, none),
			   p_player_show_base, [])]);
encode(p_room, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_room.room_id, none), int32,
			   []),
		      pack(2, required,
			   with_default(_Record#p_room.cur_player_num, none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#p_room.max_player_num, none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#p_room.owner, none),
			   p_player_show_base, []),
		      pack(5, required,
			   with_default(_Record#p_room.room_name, none), string,
			   []),
		      pack(6, required,
			   with_default(_Record#p_room.room_status, none),
			   int32, []),
		      pack(7, repeated,
			   with_default(_Record#p_room.duty_list, none), int32,
			   []),
		      pack(8, repeated,
			   with_default(_Record#p_room.ready_list, none),
			   uint32, [])]);
encode(m__room__get_list__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__get_list__s2l.msg_id,
					13002),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__room__get_list__s2l.room_list,
					none),
			   p_room, [])]);
encode(m__room__enter_room__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__enter_room__l2s.msg_id,
					13003),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__enter_room__l2s.room_id,
					none),
			   int32, [])]);
encode(m__room__enter_room__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__enter_room__s2l.msg_id,
					13004),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__enter_room__s2l.room_info,
					none),
			   p_room, []),
		      pack(3, repeated,
			   with_default(_Record#m__room__enter_room__s2l.member_list,
					none),
			   p_player_show_base, [])]);
encode(m__room__create_room__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__create_room__l2s.msg_id,
					13005),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__create_room__l2s.max_player_num,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__room__create_room__l2s.room_name,
					none),
			   string, []),
		      pack(4, repeated,
			   with_default(_Record#m__room__create_room__l2s.duty_list,
					none),
			   int32, [])]);
encode(m__room__create_room__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__create_room__s2l.msg_id,
					13006),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__create_room__s2l.room_info,
					none),
			   p_room, [])]);
encode(m__room__leave_room__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__leave_room__l2s.msg_id,
					13007),
			   int32, [])]);
encode(m__room__leave_room__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__leave_room__s2l.msg_id,
					13008),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__leave_room__s2l.result,
					none),
			   int32, [])]);
encode(m__room__rand_enter__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__rand_enter__l2s.msg_id,
					13009),
			   int32, [])]);
encode(m__room__start_fight__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__start_fight__l2s.msg_id,
					13011),
			   int32, [])]);
encode(m__room__notice_member_change__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__notice_member_change__s2l.msg_id,
					13012),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__notice_member_change__s2l.room_info,
					none),
			   p_room, []),
		      pack(3, repeated,
			   with_default(_Record#m__room__notice_member_change__s2l.member_list,
					none),
			   p_player_show_base, [])]);
encode(m__room__want_chat__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__want_chat__l2s.msg_id,
					13013),
			   int32, [])]);
encode(m__room__want_chat__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__want_chat__s2l.msg_id,
					13014),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__room__want_chat__s2l.wait_list,
					none),
			   uint32, [])]);
encode(m__room__notice_start_chat__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__notice_start_chat__s2l.msg_id,
					13015),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__notice_start_chat__s2l.start_id,
					none),
			   uint32, []),
		      pack(3, repeated,
			   with_default(_Record#m__room__notice_start_chat__s2l.wait_list,
					none),
			   uint32, []),
		      pack(4, required,
			   with_default(_Record#m__room__notice_start_chat__s2l.duration,
					none),
			   uint32, [])]);
encode(m__room__end_chat__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__end_chat__l2s.msg_id,
					13016),
			   int32, [])]);
encode(m__room__want_chat_list__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__want_chat_list__l2s.msg_id,
					13017),
			   int32, [])]);
encode(m__room__want_chat_list__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__want_chat_list__s2l.msg_id,
					13018),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__room__want_chat_list__s2l.wait_list,
					none),
			   string, [])]);
encode(m__room__notice_chat_info__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__notice_chat_info__s2l.msg_id,
					13019),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__notice_chat_info__s2l.player_id,
					none),
			   uint32, []),
		      pack(3, required,
			   with_default(_Record#m__room__notice_chat_info__s2l.wait_time,
					none),
			   uint32, [])]);
encode(m__room__send_gift__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__send_gift__l2s.msg_id,
					13020),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__send_gift__l2s.gift_id,
					none),
			   uint32, []),
		      pack(3, required,
			   with_default(_Record#m__room__send_gift__l2s.player_id,
					none),
			   uint32, [])]);
encode(m__room__send_gift__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__send_gift__s2l.msg_id,
					13021),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__send_gift__s2l.gift_id,
					none),
			   uint32, []),
		      pack(3, required,
			   with_default(_Record#m__room__send_gift__s2l.player_id,
					none),
			   uint32, []),
		      pack(4, required,
			   with_default(_Record#m__room__send_gift__s2l.result,
					none),
			   uint32, []),
		      pack(5, required,
			   with_default(_Record#m__room__send_gift__s2l.luck_add,
					none),
			   uint32, [])]);
encode(m__room__kick_player__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__kick_player__l2s.msg_id,
					13022),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__kick_player__l2s.kicked_player_id,
					none),
			   uint32, [])]);
encode(m__room__kick_player__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__kick_player__s2l.msg_id,
					13023),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__kick_player__s2l.kicked_player_id,
					none),
			   uint32, []),
		      pack(3, required,
			   with_default(_Record#m__room__kick_player__s2l.player_name,
					none),
			   string, []),
		      pack(4, required,
			   with_default(_Record#m__room__kick_player__s2l.result,
					none),
			   uint32, [])]);
encode(m__room__ready__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__ready__l2s.msg_id,
					13024),
			   int32, [])]);
encode(m__room__cancle_ready__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__cancle_ready__l2s.msg_id,
					13025),
			   int32, [])]);
encode(m__room__notice_all_ready__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__notice_all_ready__s2l.msg_id,
					13026),
			   int32, [])]);
encode(m__room__login_not_in_room__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__login_not_in_room__s2l.msg_id,
					13027),
			   int32, [])]);
encode(m__room__enter_fail__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__enter_fail__s2l.msg_id,
					13028),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__enter_fail__s2l.result,
					none),
			   int32, [])]);
encode(m__room__enter_simple_room__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__enter_simple_room__l2s.msg_id,
					13029),
			   int32, [])]);
encode(m__room__get_room_info__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__get_room_info__l2s.msg_id,
					13030),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__get_room_info__l2s.room_id,
					none),
			   int32, [])]);
encode(m__room__get_room_info__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__get_room_info__s2l.msg_id,
					13031),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__get_room_info__s2l.room_info,
					none),
			   p_room, [])]);
encode(m__room__get_room_info_fail__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__get_room_info_fail__s2l.msg_id,
					13032),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__get_room_info_fail__s2l.reason,
					none),
			   int32, [])]);
encode(m__room__get_not_full_normal_room_id_list__l2s,
       _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__get_not_full_normal_room_id_list__l2s.msg_id,
					13033),
			   int32, [])]);
encode(m__room__get_not_full_normal_room_id_list__s2l,
       _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__get_not_full_normal_room_id_list__s2l.msg_id,
					13034),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__room__get_not_full_normal_room_id_list__s2l.room_id_list,
					none),
			   int32, [])]);
encode(p_chat, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_chat.voice, none), bytes, []),
		      pack(2, required,
			   with_default(_Record#p_chat.content, none), string,
			   []),
		      pack(3, required,
			   with_default(_Record#p_chat.length, none), int32,
			   []),
		      pack(4, required,
			   with_default(_Record#p_chat.compress, none), int32,
			   []),
		      pack(5, required,
			   with_default(_Record#p_chat.chat_type, none), int32,
			   []),
		      pack(6, optional,
			   with_default(_Record#p_chat.room_id, none), int32,
			   []),
		      pack(7, required,
			   with_default(_Record#p_chat.msg_type, none), int32,
			   [])]);
encode(m__chat__public_speak__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__chat__public_speak__l2s.msg_id,
					14001),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__chat__public_speak__l2s.chat,
					none),
			   p_chat, [])]);
encode(m__chat__public_speak__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__chat__public_speak__s2l.msg_id,
					14002),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__chat__public_speak__s2l.chat,
					none),
			   p_chat, []),
		      pack(3, required,
			   with_default(_Record#m__chat__public_speak__s2l.player_id,
					none),
			   uint32, [])]);
encode(m__fight__game_state_change__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__game_state_change__s2l.msg_id,
					15001),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__game_state_change__s2l.game_status,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__game_state_change__s2l.attach_data,
					none),
			   int32, [])]);
encode(m__fight__notice_duty__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_duty__s2l.msg_id,
					15002),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__notice_duty__s2l.duty,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight__notice_duty__s2l.seat_id,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__fight__notice_duty__s2l.fight_info,
					none),
			   p_fight, []),
		      pack(5, required,
			   with_default(_Record#m__fight__notice_duty__s2l.fight_mode,
					none),
			   int32, []),
		      pack(6, required,
			   with_default(_Record#m__fight__notice_duty__s2l.duty_valid,
					none),
			   int32, [])]);
encode(m__fight__notice_op__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_op__s2l.msg_id,
					15003),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__notice_op__s2l.op,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__notice_op__s2l.attach_data,
					none),
			   int32, [])]);
encode(m__fight__notice_op__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_op__l2s.msg_id,
					15004),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__notice_op__l2s.op,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__notice_op__l2s.op_list,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__fight__notice_op__l2s.confirm,
					none),
			   int32, [])]);
encode(m__fight__speak__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__speak__l2s.msg_id,
					15005),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__speak__l2s.chat,
					none),
			   p_chat, []),
		      pack(3, required,
			   with_default(_Record#m__fight__speak__l2s.speak_type,
					none),
			   int32, [])]);
encode(m__fight__speak__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__speak__s2l.msg_id,
					15006),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__speak__s2l.chat,
					none),
			   p_chat, []),
		      pack(3, required,
			   with_default(_Record#m__fight__speak__s2l.player_id,
					none),
			   uint32, [])]);
encode(m__fight__notice_lover__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_lover__s2l.msg_id,
					15007),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__notice_lover__s2l.lover_list,
					none),
			   int32, [])]);
encode(m__fight__notice_yuyanjia_result__s2l,
       _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_yuyanjia_result__s2l.msg_id,
					15008),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__notice_yuyanjia_result__s2l.seat_id,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight__notice_yuyanjia_result__s2l.duty,
					none),
			   int32, [])]);
encode(p_xuanju_result, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_xuanju_result.seat_id, none),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#p_xuanju_result.select_list,
					none),
			   int32, [])]);
encode(m__fight__xuanju_result__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__xuanju_result__s2l.msg_id,
					15009),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__xuanju_result__s2l.xuanju_type,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__xuanju_result__s2l.result_list,
					none),
			   p_xuanju_result, []),
		      pack(4, required,
			   with_default(_Record#m__fight__xuanju_result__s2l.is_draw,
					none),
			   int32, []),
		      pack(5, required,
			   with_default(_Record#m__fight__xuanju_result__s2l.result_id,
					none),
			   int32, []),
		      pack(6, repeated,
			   with_default(_Record#m__fight__xuanju_result__s2l.max_list,
					none),
			   int32, [])]);
encode(m__fight__night_result__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__night_result__s2l.msg_id,
					15010),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__night_result__s2l.die_list,
					none),
			   int32, [])]);
encode(p_duty, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_duty.seat_id, none), int32,
			   []),
		      pack(2, required,
			   with_default(_Record#p_duty.duty_id, none), int32,
			   []),
		      pack(3, required,
			   with_default(_Record#p_duty.player_id, none), uint32,
			   [])]);
encode(m__fight__result__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__result__s2l.msg_id,
					15011),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__result__s2l.winner,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__result__s2l.duty_list,
					none),
			   p_duty, []),
		      pack(4, repeated,
			   with_default(_Record#m__fight__result__s2l.lover,
					none),
			   int32, []),
		      pack(5, required,
			   with_default(_Record#m__fight__result__s2l.hunxuer,
					none),
			   int32, []),
		      pack(6, required,
			   with_default(_Record#m__fight__result__s2l.daozei,
					none),
			   int32, []),
		      pack(7, required,
			   with_default(_Record#m__fight__result__s2l.mvp,
					none),
			   int32, []),
		      pack(8, required,
			   with_default(_Record#m__fight__result__s2l.carry,
					none),
			   int32, []),
		      pack(9, required,
			   with_default(_Record#m__fight__result__s2l.coin_add,
					none),
			   int32, []),
		      pack(10, required,
			   with_default(_Record#m__fight__result__s2l.cur_level,
					none),
			   int32, []),
		      pack(11, required,
			   with_default(_Record#m__fight__result__s2l.cur_exp,
					none),
			   int32, []),
		      pack(12, required,
			   with_default(_Record#m__fight__result__s2l.exp_add,
					none),
			   int32, []),
		      pack(13, required,
			   with_default(_Record#m__fight__result__s2l.pre_level_up_exp,
					none),
			   int32, []),
		      pack(14, required,
			   with_default(_Record#m__fight__result__s2l.level_up_exp,
					none),
			   int32, []),
		      pack(15, required,
			   with_default(_Record#m__fight__result__s2l.next_level_up_exp,
					none),
			   int32, []),
		      pack(16, required,
			   with_default(_Record#m__fight__result__s2l.victory_party,
					none),
			   int32, []),
		      pack(17, required,
			   with_default(_Record#m__fight__result__s2l.room_id,
					none),
			   int32, []),
		      pack(18, required,
			   with_default(_Record#m__fight__result__s2l.own_seat_id,
					none),
			   int32, []),
		      pack(19, repeated,
			   with_default(_Record#m__fight__result__s2l.third_list,
					none),
			   int32, []),
		      pack(20, required,
			   with_default(_Record#m__fight__result__s2l.rank_add,
					none),
			   int32, [])]);
encode(m__fight__guipiao__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__guipiao__s2l.msg_id,
					15012),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__guipiao__s2l.guipiao_list,
					none),
			   int32, [])]);
encode(m__fight__notice_fayan__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_fayan__s2l.msg_id,
					15013),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__notice_fayan__s2l.seat_id,
					none),
			   int32, [])]);
encode(m__fight__stop_fayan__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__stop_fayan__s2l.msg_id,
					15014),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__stop_fayan__s2l.seat_id,
					none),
			   int32, [])]);
encode(m__fight__notice_hunxuer__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_hunxuer__s2l.msg_id,
					15015),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__notice_hunxuer__s2l.select_seat,
					none),
			   int32, [])]);
encode(m__fight__notice_part_jingzhang__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_part_jingzhang__s2l.msg_id,
					15016),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__notice_part_jingzhang__s2l.seat_list,
					none),
			   int32, [])]);
encode(m__fight__notice_skill__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_skill__s2l.msg_id,
					15017),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__notice_skill__s2l.op,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__notice_skill__s2l.op_list,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__fight__notice_skill__s2l.seat_id,
					none),
			   int32, [])]);
encode(m__fight__do_skill__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__do_skill__l2s.msg_id,
					15018),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__do_skill__l2s.op,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__do_skill__l2s.op_list,
					none),
			   int32, [])]);
encode(p_flop, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_flop.seat_id, none), int32,
			   []),
		      pack(2, required, with_default(_Record#p_flop.op, none),
			   int32, [])]);
encode(m__fight__online__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__online__s2l.msg_id,
					15019),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__online__s2l.duty,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight__online__s2l.game_status,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__fight__online__s2l.round,
					none),
			   int32, []),
		      pack(5, repeated,
			   with_default(_Record#m__fight__online__s2l.die_list,
					none),
			   int32, []),
		      pack(6, required,
			   with_default(_Record#m__fight__online__s2l.seat_id,
					none),
			   int32, []),
		      pack(7, repeated,
			   with_default(_Record#m__fight__online__s2l.attach_data1,
					none),
			   int32, []),
		      pack(8, repeated,
			   with_default(_Record#m__fight__online__s2l.attach_data2,
					none),
			   int32, []),
		      pack(9, repeated,
			   with_default(_Record#m__fight__online__s2l.offline_list,
					none),
			   int32, []),
		      pack(10, repeated,
			   with_default(_Record#m__fight__online__s2l.leave_list,
					none),
			   int32, []),
		      pack(11, repeated,
			   with_default(_Record#m__fight__online__s2l.flop_list,
					none),
			   p_flop, []),
		      pack(12, repeated,
			   with_default(_Record#m__fight__online__s2l.winner,
					none),
			   int32, []),
		      pack(13, required,
			   with_default(_Record#m__fight__online__s2l.wait_op,
					none),
			   int32, []),
		      pack(14, repeated,
			   with_default(_Record#m__fight__online__s2l.wait_op_list,
					none),
			   int32, []),
		      pack(15, repeated,
			   with_default(_Record#m__fight__online__s2l.wait_op_attach_data,
					none),
			   int32, []),
		      pack(16, required,
			   with_default(_Record#m__fight__online__s2l.wait_op_tick,
					none),
			   int32, []),
		      pack(17, required,
			   with_default(_Record#m__fight__online__s2l.jingzhang,
					none),
			   int32, []),
		      pack(18, repeated,
			   with_default(_Record#m__fight__online__s2l.lover_list,
					none),
			   int32, []),
		      pack(19, repeated,
			   with_default(_Record#m__fight__online__s2l.duty_list,
					none),
			   p_duty, []),
		      pack(20, repeated,
			   with_default(_Record#m__fight__online__s2l.parting_jingzhang,
					none),
			   int32, []),
		      pack(21, required,
			   with_default(_Record#m__fight__online__s2l.fight_info,
					none),
			   p_fight, []),
		      pack(22, required,
			   with_default(_Record#m__fight__online__s2l.duty_select_over,
					none),
			   int32, []),
		      pack(23, required,
			   with_default(_Record#m__fight__online__s2l.duty_select_time,
					none),
			   int32, []),
		      pack(24, repeated,
			   with_default(_Record#m__fight__online__s2l.duty_select_info,
					none),
			   int32, []),
		      pack(25, required,
			   with_default(_Record#m__fight__online__s2l.is_night,
					none),
			   int32, []),
		      pack(26, required,
			   with_default(_Record#m__fight__online__s2l.fight_mode,
					none),
			   int32, []),
		      pack(27, repeated,
			   with_default(_Record#m__fight__online__s2l.speak_forbid_info,
					none),
			   int32, []),
		      pack(28, required,
			   with_default(_Record#m__fight__online__s2l.game_round,
					none),
			   int32, []),
		      pack(29, required,
			   with_default(_Record#m__fight__online__s2l.night_op_left_time,
					none),
			   int32, []),
		      pack(30, repeated,
			   with_default(_Record#m__fight__online__s2l.bailang_list,
					none),
			   int32, []),
		      pack(31, repeated,
			   with_default(_Record#m__fight__online__s2l.duty_select_seat_list,
					none),
			   int32, [])]);
encode(m__fight__offline__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__offline__s2l.msg_id,
					15020),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__offline__s2l.offline_list,
					none),
			   int32, [])]);
encode(m__fight__op_timetick__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__op_timetick__s2l.msg_id,
					15021),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__op_timetick__s2l.timetick,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight__op_timetick__s2l.wait_op,
					none),
			   int32, [])]);
encode(m__fight__langren_team_speak__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__langren_team_speak__s2l.msg_id,
					15022),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__langren_team_speak__s2l.chat,
					none),
			   p_chat, [])]);
encode(m__fight__shouwei_op__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__shouwei_op__s2l.msg_id,
					15023),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__shouwei_op__s2l.seat_id,
					none),
			   int32, [])]);
encode(m__fight__over_info__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__over_info__s2l.msg_id,
					15024),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__over_info__s2l.winner,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__over_info__s2l.duty_list,
					none),
			   p_duty, []),
		      pack(4, repeated,
			   with_default(_Record#m__fight__over_info__s2l.dead_list,
					none),
			   int32, [])]);
encode(m__fight__leave__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__leave__s2l.msg_id,
					15025),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__leave__s2l.leave_list,
					none),
			   int32, [])]);
encode(m__fight__update_duty__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__update_duty__s2l.msg_id,
					15026),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__update_duty__s2l.pre_duty,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight__update_duty__s2l.cur_duty,
					none),
			   int32, [])]);
encode(m__fight__random_duty__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__random_duty__s2l.msg_id,
					15027),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__random_duty__s2l.left_time,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__random_duty__s2l.duty_list,
					none),
			   int32, [])]);
encode(m__fight__select_duty__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__select_duty__s2l.msg_id,
					15028),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__select_duty__s2l.result,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight__select_duty__s2l.duty,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__fight__select_duty__s2l.seat_id,
					none),
			   int32, [])]);
encode(m__fight__notice_langren__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__notice_langren__s2l.msg_id,
					15029),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__notice_langren__s2l.langren_list,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__notice_langren__s2l.bailang_list,
					none),
			   int32, [])]);
encode(m__fight__forbid_other_speak__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__forbid_other_speak__l2s.msg_id,
					15030),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__forbid_other_speak__l2s.is_forbid,
					none),
			   int32, [])]);
encode(m__fight__forbid_other_speak__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__forbid_other_speak__s2l.msg_id,
					15031),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__forbid_other_speak__s2l.forbid_info,
					none),
			   int32, [])]);
encode(m__fight__chat_input__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__chat_input__l2s.msg_id,
					15032),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__chat_input__l2s.is_expression,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight__chat_input__l2s.chat_type,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__fight__chat_input__l2s.content,
					none),
			   string, [])]);
encode(m__fight__chat_input__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__chat_input__s2l.msg_id,
					15033),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__chat_input__s2l.is_expression,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight__chat_input__s2l.chat_type,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__fight__chat_input__s2l.player_id,
					none),
			   uint32, []),
		      pack(5, required,
			   with_default(_Record#m__fight__chat_input__s2l.content,
					none),
			   string, [])]);
encode(m__fight__dync_langren_op_data__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__dync_langren_op_data__s2l.msg_id,
					15034),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__dync_langren_op_data__s2l.op_data,
					none),
			   int32, [])]);
encode(m__fight__langren_op__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__langren_op__s2l.msg_id,
					15035),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__langren_op__s2l.seat_id,
					none),
			   int32, [])]);
encode(m__fight__nvwu_op__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__nvwu_op__s2l.msg_id,
					15036),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__nvwu_op__s2l.du_seat_id,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight__nvwu_op__s2l.save_seat_id,
					none),
			   int32, [])]);
encode(m__fight_over_error__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight_over_error__s2l.msg_id,
					15037),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight_over_error__s2l.room_id,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__fight_over_error__s2l.reason,
					none),
			   int32, [])]);
encode(m__fight__daozei_op__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__daozei_op__s2l.msg_id,
					15038),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__fight__daozei_op__s2l.duty,
					none),
			   int32, [])]);
encode(p_die_info, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_die_info.seat_id, none),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#p_die_info.die_type, none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#p_die_info.game_round, none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#p_die_info.is_night, none),
			   int32, [])]);
encode(m__fight__end_info__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__fight__end_info__s2l.msg_id,
					15039),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__fight__end_info__s2l.duty_list,
					none),
			   p_duty, []),
		      pack(3, repeated,
			   with_default(_Record#m__fight__end_info__s2l.die_info,
					none),
			   p_die_info, []),
		      pack(4, required,
			   with_default(_Record#m__fight__end_info__s2l.result_type,
					none),
			   int32, [])]);
encode(m__resource__push__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__resource__push__s2l.msg_id,
					16001),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__resource__push__s2l.resource_id,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__resource__push__s2l.num,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__resource__push__s2l.action_id,
					none),
			   int32, [])]);
encode(m__match__start_match__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__match__start_match__l2s.msg_id,
					17001),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__match__start_match__l2s.mode,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__match__start_match__l2s.player_list,
					none),
			   int32, [])]);
encode(m__match__end_match__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__match__end_match__l2s.msg_id,
					17002),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__match__end_match__l2s.mode,
					none),
			   int32, [])]);
encode(m__match__end_match__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__match__end_match__s2l.msg_id,
					17003),
			   int32, [])]);
encode(m__match__again_match__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__match__again_match__s2l.msg_id,
					17004),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__match__again_match__s2l.mode,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__match__again_match__s2l.is_again,
					none),
			   int32, [])]);
encode(m__match__notice_enter_match__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__match__notice_enter_match__s2l.msg_id,
					17005),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__match__notice_enter_match__s2l.wait_id,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__match__notice_enter_match__s2l.mode,
					none),
			   int32, []),
		      pack(4, repeated,
			   with_default(_Record#m__match__notice_enter_match__s2l.wait_list,
					none),
			   p_player_show_base, [])]);
encode(m__match__enter_match__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__match__enter_match__l2s.msg_id,
					17006),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__match__enter_match__l2s.mode,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__match__enter_match__l2s.wait_id,
					none),
			   int32, [])]);
encode(m__match__enter_match_list__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__match__enter_match_list__s2l.msg_id,
					17007),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__match__enter_match_list__s2l.wait_id,
					none),
			   int32, []),
		      pack(3, repeated,
			   with_default(_Record#m__match__enter_match_list__s2l.ready_list,
					none),
			   p_player_show_base, []),
		      pack(4, repeated,
			   with_default(_Record#m__match__enter_match_list__s2l.wait_list,
					none),
			   p_player_show_base, [])]);
encode(p_rank, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_rank.player_show_base, none),
			   p_player_show_base, []),
		      pack(2, required,
			   with_default(_Record#p_rank.rank, none), int32, []),
		      pack(3, required,
			   with_default(_Record#p_rank.value, none), int32,
			   [])]);
encode(m__rank__get_rank__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__rank__get_rank__l2s.msg_id,
					18001),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__rank__get_rank__l2s.rank_type,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__rank__get_rank__l2s.start_rank,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__rank__get_rank__l2s.end_rank,
					none),
			   int32, [])]);
encode(m__rank__get_rank__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__rank__get_rank__s2l.msg_id,
					18002),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__rank__get_rank__s2l.rank_type,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__rank__get_rank__s2l.start_rank,
					none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#m__rank__get_rank__s2l.end_rank,
					none),
			   int32, []),
		      pack(5, repeated,
			   with_default(_Record#m__rank__get_rank__s2l.rank_list,
					none),
			   p_rank, [])]);
encode(p_friend, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_friend.player_show_base,
					none),
			   p_player_show_base, []),
		      pack(2, required,
			   with_default(_Record#p_friend.status, none), int32,
			   []),
		      pack(3, required,
			   with_default(_Record#p_friend.room_id, none), int32,
			   [])]);
encode(m__friend__get_friend__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__get_friend__l2s.msg_id,
					19001),
			   int32, [])]);
encode(m__friend__get_friend__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__get_friend__s2l.msg_id,
					19002),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__friend__get_friend__s2l.friend_list,
					none),
			   p_friend, [])]);
encode(m__friend__add_friend__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__add_friend__l2s.msg_id,
					19003),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__friend__add_friend__l2s.add_friend,
					none),
			   int32, [])]);
encode(m__friend__remove_friend__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__remove_friend__l2s.msg_id,
					19005),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__friend__remove_friend__l2s.remove_friend,
					none),
			   int32, [])]);
encode(m__friend__private_chat__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__private_chat__l2s.msg_id,
					19007),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__friend__private_chat__l2s.chat,
					none),
			   p_chat, []),
		      pack(3, required,
			   with_default(_Record#m__friend__private_chat__l2s.target_id,
					none),
			   uint32, [])]);
encode(m__friend__private_chat__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__private_chat__s2l.msg_id,
					19008),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__friend__private_chat__s2l.target_info,
					none),
			   p_player_show_base, []),
		      pack(3, required,
			   with_default(_Record#m__friend__private_chat__s2l.speak_info,
					none),
			   p_player_show_base, []),
		      pack(4, required,
			   with_default(_Record#m__friend__private_chat__s2l.chat,
					none),
			   p_chat, [])]);
encode(m__friend__get_chat_list__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__get_chat_list__l2s.msg_id,
					19009),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__friend__get_chat_list__l2s.friend_id,
					none),
			   uint32, [])]);
encode(m__friend__get_chat_list__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__get_chat_list__s2l.msg_id,
					19010),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__friend__get_chat_list__s2l.chat_list,
					none),
			   p_chat, [])]);
encode(m__friend__add_friend__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__add_friend__s2l.msg_id,
					19011),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__friend__add_friend__s2l.friend,
					none),
			   p_friend, [])]);
encode(m__friend__remove_friend__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__friend__remove_friend__s2l.msg_id,
					19012),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__friend__remove_friend__s2l.remove_friend,
					none),
			   int32, [])]).

with_default(undefined, none) -> undefined;
with_default(undefined, Default) -> Default;
with_default(Val, _) -> Val.

pack(_, optional, undefined, _, _) -> [];
pack(_, repeated, undefined, _, _) -> [];
pack(FNum, required, undefined, Type, _) ->
    exit({error,
	  {required_field_is_undefined, FNum, Type}});
pack(_, repeated, [], _, Acc) -> lists:reverse(Acc);
pack(FNum, repeated, [Head | Tail], Type, Acc) ->
    pack(FNum, repeated, Tail, Type,
	 [pack(FNum, optional, Head, Type, []) | Acc]);
pack(FNum, _, Data, _, _) when is_tuple(Data) ->
    RecName = erlang:element(1, Data),
    protobuffs:encode(FNum, encode(RecName, Data), bytes);
pack(FNum, _, Data, Type, _) ->
    protobuffs:encode(FNum, Data, Type).

decode_m__friend__remove_friend__s2l(Bytes) ->
    decode(m__friend__remove_friend__s2l, Bytes).

decode_m__friend__add_friend__s2l(Bytes) ->
    decode(m__friend__add_friend__s2l, Bytes).

decode_m__friend__get_chat_list__s2l(Bytes) ->
    decode(m__friend__get_chat_list__s2l, Bytes).

decode_m__friend__get_chat_list__l2s(Bytes) ->
    decode(m__friend__get_chat_list__l2s, Bytes).

decode_m__friend__private_chat__s2l(Bytes) ->
    decode(m__friend__private_chat__s2l, Bytes).

decode_m__friend__private_chat__l2s(Bytes) ->
    decode(m__friend__private_chat__l2s, Bytes).

decode_m__friend__remove_friend__l2s(Bytes) ->
    decode(m__friend__remove_friend__l2s, Bytes).

decode_m__friend__add_friend__l2s(Bytes) ->
    decode(m__friend__add_friend__l2s, Bytes).

decode_m__friend__get_friend__s2l(Bytes) ->
    decode(m__friend__get_friend__s2l, Bytes).

decode_m__friend__get_friend__l2s(Bytes) ->
    decode(m__friend__get_friend__l2s, Bytes).

decode_p_friend(Bytes) -> decode(p_friend, Bytes).

decode_m__rank__get_rank__s2l(Bytes) ->
    decode(m__rank__get_rank__s2l, Bytes).

decode_m__rank__get_rank__l2s(Bytes) ->
    decode(m__rank__get_rank__l2s, Bytes).

decode_p_rank(Bytes) -> decode(p_rank, Bytes).

decode_m__match__enter_match_list__s2l(Bytes) ->
    decode(m__match__enter_match_list__s2l, Bytes).

decode_m__match__enter_match__l2s(Bytes) ->
    decode(m__match__enter_match__l2s, Bytes).

decode_m__match__notice_enter_match__s2l(Bytes) ->
    decode(m__match__notice_enter_match__s2l, Bytes).

decode_m__match__again_match__s2l(Bytes) ->
    decode(m__match__again_match__s2l, Bytes).

decode_m__match__end_match__s2l(Bytes) ->
    decode(m__match__end_match__s2l, Bytes).

decode_m__match__end_match__l2s(Bytes) ->
    decode(m__match__end_match__l2s, Bytes).

decode_m__match__start_match__l2s(Bytes) ->
    decode(m__match__start_match__l2s, Bytes).

decode_m__resource__push__s2l(Bytes) ->
    decode(m__resource__push__s2l, Bytes).

decode_m__fight__end_info__s2l(Bytes) ->
    decode(m__fight__end_info__s2l, Bytes).

decode_p_die_info(Bytes) -> decode(p_die_info, Bytes).

decode_m__fight__daozei_op__s2l(Bytes) ->
    decode(m__fight__daozei_op__s2l, Bytes).

decode_m__fight_over_error__s2l(Bytes) ->
    decode(m__fight_over_error__s2l, Bytes).

decode_m__fight__nvwu_op__s2l(Bytes) ->
    decode(m__fight__nvwu_op__s2l, Bytes).

decode_m__fight__langren_op__s2l(Bytes) ->
    decode(m__fight__langren_op__s2l, Bytes).

decode_m__fight__dync_langren_op_data__s2l(Bytes) ->
    decode(m__fight__dync_langren_op_data__s2l, Bytes).

decode_m__fight__chat_input__s2l(Bytes) ->
    decode(m__fight__chat_input__s2l, Bytes).

decode_m__fight__chat_input__l2s(Bytes) ->
    decode(m__fight__chat_input__l2s, Bytes).

decode_m__fight__forbid_other_speak__s2l(Bytes) ->
    decode(m__fight__forbid_other_speak__s2l, Bytes).

decode_m__fight__forbid_other_speak__l2s(Bytes) ->
    decode(m__fight__forbid_other_speak__l2s, Bytes).

decode_m__fight__notice_langren__s2l(Bytes) ->
    decode(m__fight__notice_langren__s2l, Bytes).

decode_m__fight__select_duty__s2l(Bytes) ->
    decode(m__fight__select_duty__s2l, Bytes).

decode_m__fight__random_duty__s2l(Bytes) ->
    decode(m__fight__random_duty__s2l, Bytes).

decode_m__fight__update_duty__s2l(Bytes) ->
    decode(m__fight__update_duty__s2l, Bytes).

decode_m__fight__leave__s2l(Bytes) ->
    decode(m__fight__leave__s2l, Bytes).

decode_m__fight__over_info__s2l(Bytes) ->
    decode(m__fight__over_info__s2l, Bytes).

decode_m__fight__shouwei_op__s2l(Bytes) ->
    decode(m__fight__shouwei_op__s2l, Bytes).

decode_m__fight__langren_team_speak__s2l(Bytes) ->
    decode(m__fight__langren_team_speak__s2l, Bytes).

decode_m__fight__op_timetick__s2l(Bytes) ->
    decode(m__fight__op_timetick__s2l, Bytes).

decode_m__fight__offline__s2l(Bytes) ->
    decode(m__fight__offline__s2l, Bytes).

decode_m__fight__online__s2l(Bytes) ->
    decode(m__fight__online__s2l, Bytes).

decode_p_flop(Bytes) -> decode(p_flop, Bytes).

decode_m__fight__do_skill__l2s(Bytes) ->
    decode(m__fight__do_skill__l2s, Bytes).

decode_m__fight__notice_skill__s2l(Bytes) ->
    decode(m__fight__notice_skill__s2l, Bytes).

decode_m__fight__notice_part_jingzhang__s2l(Bytes) ->
    decode(m__fight__notice_part_jingzhang__s2l, Bytes).

decode_m__fight__notice_hunxuer__s2l(Bytes) ->
    decode(m__fight__notice_hunxuer__s2l, Bytes).

decode_m__fight__stop_fayan__s2l(Bytes) ->
    decode(m__fight__stop_fayan__s2l, Bytes).

decode_m__fight__notice_fayan__s2l(Bytes) ->
    decode(m__fight__notice_fayan__s2l, Bytes).

decode_m__fight__guipiao__s2l(Bytes) ->
    decode(m__fight__guipiao__s2l, Bytes).

decode_m__fight__result__s2l(Bytes) ->
    decode(m__fight__result__s2l, Bytes).

decode_p_duty(Bytes) -> decode(p_duty, Bytes).

decode_m__fight__night_result__s2l(Bytes) ->
    decode(m__fight__night_result__s2l, Bytes).

decode_m__fight__xuanju_result__s2l(Bytes) ->
    decode(m__fight__xuanju_result__s2l, Bytes).

decode_p_xuanju_result(Bytes) ->
    decode(p_xuanju_result, Bytes).

decode_m__fight__notice_yuyanjia_result__s2l(Bytes) ->
    decode(m__fight__notice_yuyanjia_result__s2l, Bytes).

decode_m__fight__notice_lover__s2l(Bytes) ->
    decode(m__fight__notice_lover__s2l, Bytes).

decode_m__fight__speak__s2l(Bytes) ->
    decode(m__fight__speak__s2l, Bytes).

decode_m__fight__speak__l2s(Bytes) ->
    decode(m__fight__speak__l2s, Bytes).

decode_m__fight__notice_op__l2s(Bytes) ->
    decode(m__fight__notice_op__l2s, Bytes).

decode_m__fight__notice_op__s2l(Bytes) ->
    decode(m__fight__notice_op__s2l, Bytes).

decode_m__fight__notice_duty__s2l(Bytes) ->
    decode(m__fight__notice_duty__s2l, Bytes).

decode_m__fight__game_state_change__s2l(Bytes) ->
    decode(m__fight__game_state_change__s2l, Bytes).

decode_m__chat__public_speak__s2l(Bytes) ->
    decode(m__chat__public_speak__s2l, Bytes).

decode_m__chat__public_speak__l2s(Bytes) ->
    decode(m__chat__public_speak__l2s, Bytes).

decode_p_chat(Bytes) -> decode(p_chat, Bytes).

decode_m__room__get_not_full_normal_room_id_list__s2l(Bytes) ->
    decode(m__room__get_not_full_normal_room_id_list__s2l,
	   Bytes).

decode_m__room__get_not_full_normal_room_id_list__l2s(Bytes) ->
    decode(m__room__get_not_full_normal_room_id_list__l2s,
	   Bytes).

decode_m__room__get_room_info_fail__s2l(Bytes) ->
    decode(m__room__get_room_info_fail__s2l, Bytes).

decode_m__room__get_room_info__s2l(Bytes) ->
    decode(m__room__get_room_info__s2l, Bytes).

decode_m__room__get_room_info__l2s(Bytes) ->
    decode(m__room__get_room_info__l2s, Bytes).

decode_m__room__enter_simple_room__l2s(Bytes) ->
    decode(m__room__enter_simple_room__l2s, Bytes).

decode_m__room__enter_fail__s2l(Bytes) ->
    decode(m__room__enter_fail__s2l, Bytes).

decode_m__room__login_not_in_room__s2l(Bytes) ->
    decode(m__room__login_not_in_room__s2l, Bytes).

decode_m__room__notice_all_ready__s2l(Bytes) ->
    decode(m__room__notice_all_ready__s2l, Bytes).

decode_m__room__cancle_ready__l2s(Bytes) ->
    decode(m__room__cancle_ready__l2s, Bytes).

decode_m__room__ready__l2s(Bytes) ->
    decode(m__room__ready__l2s, Bytes).

decode_m__room__kick_player__s2l(Bytes) ->
    decode(m__room__kick_player__s2l, Bytes).

decode_m__room__kick_player__l2s(Bytes) ->
    decode(m__room__kick_player__l2s, Bytes).

decode_m__room__send_gift__s2l(Bytes) ->
    decode(m__room__send_gift__s2l, Bytes).

decode_m__room__send_gift__l2s(Bytes) ->
    decode(m__room__send_gift__l2s, Bytes).

decode_m__room__notice_chat_info__s2l(Bytes) ->
    decode(m__room__notice_chat_info__s2l, Bytes).

decode_m__room__want_chat_list__s2l(Bytes) ->
    decode(m__room__want_chat_list__s2l, Bytes).

decode_m__room__want_chat_list__l2s(Bytes) ->
    decode(m__room__want_chat_list__l2s, Bytes).

decode_m__room__end_chat__l2s(Bytes) ->
    decode(m__room__end_chat__l2s, Bytes).

decode_m__room__notice_start_chat__s2l(Bytes) ->
    decode(m__room__notice_start_chat__s2l, Bytes).

decode_m__room__want_chat__s2l(Bytes) ->
    decode(m__room__want_chat__s2l, Bytes).

decode_m__room__want_chat__l2s(Bytes) ->
    decode(m__room__want_chat__l2s, Bytes).

decode_m__room__notice_member_change__s2l(Bytes) ->
    decode(m__room__notice_member_change__s2l, Bytes).

decode_m__room__start_fight__l2s(Bytes) ->
    decode(m__room__start_fight__l2s, Bytes).

decode_m__room__rand_enter__l2s(Bytes) ->
    decode(m__room__rand_enter__l2s, Bytes).

decode_m__room__leave_room__s2l(Bytes) ->
    decode(m__room__leave_room__s2l, Bytes).

decode_m__room__leave_room__l2s(Bytes) ->
    decode(m__room__leave_room__l2s, Bytes).

decode_m__room__create_room__s2l(Bytes) ->
    decode(m__room__create_room__s2l, Bytes).

decode_m__room__create_room__l2s(Bytes) ->
    decode(m__room__create_room__l2s, Bytes).

decode_m__room__enter_room__s2l(Bytes) ->
    decode(m__room__enter_room__s2l, Bytes).

decode_m__room__enter_room__l2s(Bytes) ->
    decode(m__room__enter_room__l2s, Bytes).

decode_m__room__get_list__s2l(Bytes) ->
    decode(m__room__get_list__s2l, Bytes).

decode_p_room(Bytes) -> decode(p_room, Bytes).

decode_p_fight(Bytes) -> decode(p_fight, Bytes).

decode_m__room__get_list__l2s(Bytes) ->
    decode(m__room__get_list__l2s, Bytes).

decode_m__player__friend_invite__s2l(Bytes) ->
    decode(m__player__friend_invite__s2l, Bytes).

decode_m__player__invite_friends__s2l(Bytes) ->
    decode(m__player__invite_friends__s2l, Bytes).

decode_m__player__invite_friends__l2s(Bytes) ->
    decode(m__player__invite_friends__l2s, Bytes).

decode_m__player__get_head_img_name__s2l(Bytes) ->
    decode(m__player__get_head_img_name__s2l, Bytes).

decode_m__player__get_head_img_name__l2s(Bytes) ->
    decode(m__player__get_head_img_name__l2s, Bytes).

decode_m__player__upload_head_img_name__s2l(Bytes) ->
    decode(m__player__upload_head_img_name__s2l, Bytes).

decode_m__player__upload_head_img_name__l2s(Bytes) ->
    decode(m__player__upload_head_img_name__l2s, Bytes).

decode_m__player__change_sex__s2l(Bytes) ->
    decode(m__player__change_sex__s2l, Bytes).

decode_m__player__change_sex__l2s(Bytes) ->
    decode(m__player__change_sex__l2s, Bytes).

decode_m__player__get_head__s2l(Bytes) ->
    decode(m__player__get_head__s2l, Bytes).

decode_m__player__get_head__l2s(Bytes) ->
    decode(m__player__get_head__l2s, Bytes).

decode_m__player__upload_head__s2l(Bytes) ->
    decode(m__player__upload_head__s2l, Bytes).

decode_m__player__upload_head__l2s(Bytes) ->
    decode(m__player__upload_head__l2s, Bytes).

decode_m__player__kick__s2l(Bytes) ->
    decode(m__player__kick__s2l, Bytes).

decode_m__player__change_name__s2l(Bytes) ->
    decode(m__player__change_name__s2l, Bytes).

decode_m__player__change_name__l2s(Bytes) ->
    decode(m__player__change_name__l2s, Bytes).

decode_m__player__add_diamond__l2s(Bytes) ->
    decode(m__player__add_diamond__l2s, Bytes).

decode_m__player__add_coin__l2s(Bytes) ->
    decode(m__player__add_coin__l2s, Bytes).

decode_m__player__other_info__l2s(Bytes) ->
    decode(m__player__other_info__l2s, Bytes).

decode_m__player__errcode__s2l(Bytes) ->
    decode(m__player__errcode__s2l, Bytes).

decode_m__player__info__s2l(Bytes) ->
    decode(m__player__info__s2l, Bytes).

decode_p_win_rate(Bytes) -> decode(p_win_rate, Bytes).

decode_m__player__info__l2s(Bytes) ->
    decode(m__player__info__l2s, Bytes).

decode_m__account__heart_beat__s2l(Bytes) ->
    decode(m__account__heart_beat__s2l, Bytes).

decode_m__account__heart_beat__l2s(Bytes) ->
    decode(m__account__heart_beat__l2s, Bytes).

decode_m__account__login__s2l(Bytes) ->
    decode(m__account__login__s2l, Bytes).

decode_m__account__login__l2s(Bytes) ->
    decode(m__account__login__l2s, Bytes).

decode_p_resource(Bytes) -> decode(p_resource, Bytes).

decode_p_player_show_base(Bytes) ->
    decode(p_player_show_base, Bytes).

decode(p_player_show_base, Bytes) ->
    Types = [{3, head_img_name, string, []},
	     {2, nick_name, string, []}, {1, player_id, uint32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_player_show_base, Decoded);
decode(p_resource, Bytes) ->
    Types = [{2, num, int32, []},
	     {1, resource_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_resource, Decoded);
decode(m__account__login__l2s, Bytes) ->
    Types = [{2, account_name, string, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__account__login__l2s, Decoded);
decode(m__account__login__s2l, Bytes) ->
    Types = [{2, result, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__account__login__s2l, Decoded);
decode(m__account__heart_beat__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__account__heart_beat__l2s, Decoded);
decode(m__account__heart_beat__s2l, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__account__heart_beat__s2l, Decoded);
decode(m__player__info__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__info__l2s, Decoded);
decode(p_win_rate, Bytes) ->
    Types = [{3, all_cnt, int32, []},
	     {2, win_cnt, int32, []}, {1, duty_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_win_rate, Decoded);
decode(m__player__info__s2l, Bytes) ->
    Types = [{12, head_img_name, string, []},
	     {11, sex, int32, []}, {10, other_player, int32, []},
	     {9, win_rate_list, p_win_rate, [is_record, repeated]},
	     {8, resource_list, p_resource, [is_record, repeated]},
	     {6, equip, int32, []}, {5, month_vip, int32, []},
	     {4, grade, int32, []}, {3, nick_name, string, []},
	     {2, player_id, uint32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__info__s2l, Decoded);
decode(m__player__errcode__s2l, Bytes) ->
    Types = [{2, errcode, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__errcode__s2l, Decoded);
decode(m__player__other_info__l2s, Bytes) ->
    Types = [{2, player_id, uint32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__other_info__l2s, Decoded);
decode(m__player__add_coin__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__add_coin__l2s, Decoded);
decode(m__player__add_diamond__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__add_diamond__l2s, Decoded);
decode(m__player__change_name__l2s, Bytes) ->
    Types = [{2, name, string, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__change_name__l2s, Decoded);
decode(m__player__change_name__s2l, Bytes) ->
    Types = [{3, result, int32, []}, {2, name, string, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__change_name__s2l, Decoded);
decode(m__player__kick__s2l, Bytes) ->
    Types = [{2, kick_reason, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__kick__s2l, Decoded);
decode(m__player__upload_head__l2s, Bytes) ->
    Types = [{2, img_data, bytes, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__upload_head__l2s, Decoded);
decode(m__player__upload_head__s2l, Bytes) ->
    Types = [{2, result, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__upload_head__s2l, Decoded);
decode(m__player__get_head__l2s, Bytes) ->
    Types = [{2, player_id, uint32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__get_head__l2s, Decoded);
decode(m__player__get_head__s2l, Bytes) ->
    Types = [{3, img_data, bytes, []},
	     {2, player_id, uint32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__get_head__s2l, Decoded);
decode(m__player__change_sex__l2s, Bytes) ->
    Types = [{2, sex, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__change_sex__l2s, Decoded);
decode(m__player__change_sex__s2l, Bytes) ->
    Types = [{2, sex, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__change_sex__s2l, Decoded);
decode(m__player__upload_head_img_name__l2s, Bytes) ->
    Types = [{2, head_img_name, string, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__upload_head_img_name__l2s,
	      Decoded);
decode(m__player__upload_head_img_name__s2l, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__upload_head_img_name__s2l,
	      Decoded);
decode(m__player__get_head_img_name__l2s, Bytes) ->
    Types = [{2, player_id, uint32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__get_head_img_name__l2s, Decoded);
decode(m__player__get_head_img_name__s2l, Bytes) ->
    Types = [{3, head_img_name, string, []},
	     {2, player_id, uint32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__get_head_img_name__s2l, Decoded);
decode(m__player__invite_friends__l2s, Bytes) ->
    Types = [{3, room_id, int32, []},
	     {2, player_list, uint32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__invite_friends__l2s, Decoded);
decode(m__player__invite_friends__s2l, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__invite_friends__s2l, Decoded);
decode(m__player__friend_invite__s2l, Bytes) ->
    Types = [{3, room_id, int32, []},
	     {2, player_info, p_player_show_base, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__friend_invite__s2l, Decoded);
decode(m__room__get_list__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__get_list__l2s, Decoded);
decode(p_fight, Bytes) ->
    Types = [{4, player_info_list, p_player_show_base,
	      [is_record, repeated]},
	     {2, duty_list, int32, [repeated]},
	     {1, room_name, string, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_fight, Decoded);
decode(p_room, Bytes) ->
    Types = [{8, ready_list, uint32, [repeated]},
	     {7, duty_list, int32, [repeated]},
	     {6, room_status, int32, []}, {5, room_name, string, []},
	     {4, owner, p_player_show_base, [is_record]},
	     {3, max_player_num, int32, []},
	     {2, cur_player_num, int32, []},
	     {1, room_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_room, Decoded);
decode(m__room__get_list__s2l, Bytes) ->
    Types = [{2, room_list, p_room, [is_record, repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__get_list__s2l, Decoded);
decode(m__room__enter_room__l2s, Bytes) ->
    Types = [{2, room_id, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__enter_room__l2s, Decoded);
decode(m__room__enter_room__s2l, Bytes) ->
    Types = [{3, member_list, p_player_show_base,
	      [is_record, repeated]},
	     {2, room_info, p_room, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__enter_room__s2l, Decoded);
decode(m__room__create_room__l2s, Bytes) ->
    Types = [{4, duty_list, int32, [repeated]},
	     {3, room_name, string, []},
	     {2, max_player_num, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__create_room__l2s, Decoded);
decode(m__room__create_room__s2l, Bytes) ->
    Types = [{2, room_info, p_room, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__create_room__s2l, Decoded);
decode(m__room__leave_room__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__leave_room__l2s, Decoded);
decode(m__room__leave_room__s2l, Bytes) ->
    Types = [{2, result, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__leave_room__s2l, Decoded);
decode(m__room__rand_enter__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__rand_enter__l2s, Decoded);
decode(m__room__start_fight__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__start_fight__l2s, Decoded);
decode(m__room__notice_member_change__s2l, Bytes) ->
    Types = [{3, member_list, p_player_show_base,
	      [is_record, repeated]},
	     {2, room_info, p_room, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__notice_member_change__s2l, Decoded);
decode(m__room__want_chat__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__want_chat__l2s, Decoded);
decode(m__room__want_chat__s2l, Bytes) ->
    Types = [{2, wait_list, uint32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__want_chat__s2l, Decoded);
decode(m__room__notice_start_chat__s2l, Bytes) ->
    Types = [{4, duration, uint32, []},
	     {3, wait_list, uint32, [repeated]},
	     {2, start_id, uint32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__notice_start_chat__s2l, Decoded);
decode(m__room__end_chat__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__end_chat__l2s, Decoded);
decode(m__room__want_chat_list__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__want_chat_list__l2s, Decoded);
decode(m__room__want_chat_list__s2l, Bytes) ->
    Types = [{2, wait_list, string, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__want_chat_list__s2l, Decoded);
decode(m__room__notice_chat_info__s2l, Bytes) ->
    Types = [{3, wait_time, uint32, []},
	     {2, player_id, uint32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__notice_chat_info__s2l, Decoded);
decode(m__room__send_gift__l2s, Bytes) ->
    Types = [{3, player_id, uint32, []},
	     {2, gift_id, uint32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__send_gift__l2s, Decoded);
decode(m__room__send_gift__s2l, Bytes) ->
    Types = [{5, luck_add, uint32, []},
	     {4, result, uint32, []}, {3, player_id, uint32, []},
	     {2, gift_id, uint32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__send_gift__s2l, Decoded);
decode(m__room__kick_player__l2s, Bytes) ->
    Types = [{2, kicked_player_id, uint32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__kick_player__l2s, Decoded);
decode(m__room__kick_player__s2l, Bytes) ->
    Types = [{4, result, uint32, []},
	     {3, player_name, string, []},
	     {2, kicked_player_id, uint32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__kick_player__s2l, Decoded);
decode(m__room__ready__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__ready__l2s, Decoded);
decode(m__room__cancle_ready__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__cancle_ready__l2s, Decoded);
decode(m__room__notice_all_ready__s2l, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__notice_all_ready__s2l, Decoded);
decode(m__room__login_not_in_room__s2l, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__login_not_in_room__s2l, Decoded);
decode(m__room__enter_fail__s2l, Bytes) ->
    Types = [{2, result, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__enter_fail__s2l, Decoded);
decode(m__room__enter_simple_room__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__enter_simple_room__l2s, Decoded);
decode(m__room__get_room_info__l2s, Bytes) ->
    Types = [{2, room_id, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__get_room_info__l2s, Decoded);
decode(m__room__get_room_info__s2l, Bytes) ->
    Types = [{2, room_info, p_room, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__get_room_info__s2l, Decoded);
decode(m__room__get_room_info_fail__s2l, Bytes) ->
    Types = [{2, reason, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__get_room_info_fail__s2l, Decoded);
decode(m__room__get_not_full_normal_room_id_list__l2s,
       Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__get_not_full_normal_room_id_list__l2s,
	      Decoded);
decode(m__room__get_not_full_normal_room_id_list__s2l,
       Bytes) ->
    Types = [{2, room_id_list, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__get_not_full_normal_room_id_list__s2l,
	      Decoded);
decode(p_chat, Bytes) ->
    Types = [{7, msg_type, int32, []},
	     {6, room_id, int32, []}, {5, chat_type, int32, []},
	     {4, compress, int32, []}, {3, length, int32, []},
	     {2, content, string, []}, {1, voice, bytes, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_chat, Decoded);
decode(m__chat__public_speak__l2s, Bytes) ->
    Types = [{2, chat, p_chat, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__chat__public_speak__l2s, Decoded);
decode(m__chat__public_speak__s2l, Bytes) ->
    Types = [{3, player_id, uint32, []},
	     {2, chat, p_chat, [is_record]}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__chat__public_speak__s2l, Decoded);
decode(m__fight__game_state_change__s2l, Bytes) ->
    Types = [{3, attach_data, int32, [repeated]},
	     {2, game_status, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__game_state_change__s2l, Decoded);
decode(m__fight__notice_duty__s2l, Bytes) ->
    Types = [{6, duty_valid, int32, []},
	     {5, fight_mode, int32, []},
	     {4, fight_info, p_fight, [is_record]},
	     {3, seat_id, int32, []}, {2, duty, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_duty__s2l, Decoded);
decode(m__fight__notice_op__s2l, Bytes) ->
    Types = [{3, attach_data, int32, [repeated]},
	     {2, op, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_op__s2l, Decoded);
decode(m__fight__notice_op__l2s, Bytes) ->
    Types = [{4, confirm, int32, []},
	     {3, op_list, int32, [repeated]}, {2, op, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_op__l2s, Decoded);
decode(m__fight__speak__l2s, Bytes) ->
    Types = [{3, speak_type, int32, []},
	     {2, chat, p_chat, [is_record]}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__speak__l2s, Decoded);
decode(m__fight__speak__s2l, Bytes) ->
    Types = [{3, player_id, uint32, []},
	     {2, chat, p_chat, [is_record]}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__speak__s2l, Decoded);
decode(m__fight__notice_lover__s2l, Bytes) ->
    Types = [{2, lover_list, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_lover__s2l, Decoded);
decode(m__fight__notice_yuyanjia_result__s2l, Bytes) ->
    Types = [{3, duty, int32, []}, {2, seat_id, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_yuyanjia_result__s2l,
	      Decoded);
decode(p_xuanju_result, Bytes) ->
    Types = [{2, select_list, int32, [repeated]},
	     {1, seat_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_xuanju_result, Decoded);
decode(m__fight__xuanju_result__s2l, Bytes) ->
    Types = [{6, max_list, int32, [repeated]},
	     {5, result_id, int32, []}, {4, is_draw, int32, []},
	     {3, result_list, p_xuanju_result,
	      [is_record, repeated]},
	     {2, xuanju_type, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__xuanju_result__s2l, Decoded);
decode(m__fight__night_result__s2l, Bytes) ->
    Types = [{2, die_list, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__night_result__s2l, Decoded);
decode(p_duty, Bytes) ->
    Types = [{3, player_id, uint32, []},
	     {2, duty_id, int32, []}, {1, seat_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_duty, Decoded);
decode(m__fight__result__s2l, Bytes) ->
    Types = [{20, rank_add, int32, []},
	     {19, third_list, int32, [repeated]},
	     {18, own_seat_id, int32, []}, {17, room_id, int32, []},
	     {16, victory_party, int32, []},
	     {15, next_level_up_exp, int32, []},
	     {14, level_up_exp, int32, []},
	     {13, pre_level_up_exp, int32, []},
	     {12, exp_add, int32, []}, {11, cur_exp, int32, []},
	     {10, cur_level, int32, []}, {9, coin_add, int32, []},
	     {8, carry, int32, []}, {7, mvp, int32, []},
	     {6, daozei, int32, []}, {5, hunxuer, int32, []},
	     {4, lover, int32, [repeated]},
	     {3, duty_list, p_duty, [is_record, repeated]},
	     {2, winner, int32, [repeated]}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__result__s2l, Decoded);
decode(m__fight__guipiao__s2l, Bytes) ->
    Types = [{2, guipiao_list, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__guipiao__s2l, Decoded);
decode(m__fight__notice_fayan__s2l, Bytes) ->
    Types = [{2, seat_id, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_fayan__s2l, Decoded);
decode(m__fight__stop_fayan__s2l, Bytes) ->
    Types = [{2, seat_id, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__stop_fayan__s2l, Decoded);
decode(m__fight__notice_hunxuer__s2l, Bytes) ->
    Types = [{2, select_seat, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_hunxuer__s2l, Decoded);
decode(m__fight__notice_part_jingzhang__s2l, Bytes) ->
    Types = [{2, seat_list, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_part_jingzhang__s2l,
	      Decoded);
decode(m__fight__notice_skill__s2l, Bytes) ->
    Types = [{4, seat_id, int32, []},
	     {3, op_list, int32, [repeated]}, {2, op, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_skill__s2l, Decoded);
decode(m__fight__do_skill__l2s, Bytes) ->
    Types = [{3, op_list, int32, [repeated]},
	     {2, op, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__do_skill__l2s, Decoded);
decode(p_flop, Bytes) ->
    Types = [{2, op, int32, []}, {1, seat_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_flop, Decoded);
decode(m__fight__online__s2l, Bytes) ->
    Types = [{31, duty_select_seat_list, int32, [repeated]},
	     {30, bailang_list, int32, [repeated]},
	     {29, night_op_left_time, int32, []},
	     {28, game_round, int32, []},
	     {27, speak_forbid_info, int32, [repeated]},
	     {26, fight_mode, int32, []}, {25, is_night, int32, []},
	     {24, duty_select_info, int32, [repeated]},
	     {23, duty_select_time, int32, []},
	     {22, duty_select_over, int32, []},
	     {21, fight_info, p_fight, [is_record]},
	     {20, parting_jingzhang, int32, [repeated]},
	     {19, duty_list, p_duty, [is_record, repeated]},
	     {18, lover_list, int32, [repeated]},
	     {17, jingzhang, int32, []},
	     {16, wait_op_tick, int32, []},
	     {15, wait_op_attach_data, int32, [repeated]},
	     {14, wait_op_list, int32, [repeated]},
	     {13, wait_op, int32, []},
	     {12, winner, int32, [repeated]},
	     {11, flop_list, p_flop, [is_record, repeated]},
	     {10, leave_list, int32, [repeated]},
	     {9, offline_list, int32, [repeated]},
	     {8, attach_data2, int32, [repeated]},
	     {7, attach_data1, int32, [repeated]},
	     {6, seat_id, int32, []},
	     {5, die_list, int32, [repeated]}, {4, round, int32, []},
	     {3, game_status, int32, []}, {2, duty, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__online__s2l, Decoded);
decode(m__fight__offline__s2l, Bytes) ->
    Types = [{2, offline_list, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__offline__s2l, Decoded);
decode(m__fight__op_timetick__s2l, Bytes) ->
    Types = [{3, wait_op, int32, []},
	     {2, timetick, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__op_timetick__s2l, Decoded);
decode(m__fight__langren_team_speak__s2l, Bytes) ->
    Types = [{2, chat, p_chat, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__langren_team_speak__s2l, Decoded);
decode(m__fight__shouwei_op__s2l, Bytes) ->
    Types = [{2, seat_id, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__shouwei_op__s2l, Decoded);
decode(m__fight__over_info__s2l, Bytes) ->
    Types = [{4, dead_list, int32, [repeated]},
	     {3, duty_list, p_duty, [is_record, repeated]},
	     {2, winner, int32, [repeated]}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__over_info__s2l, Decoded);
decode(m__fight__leave__s2l, Bytes) ->
    Types = [{2, leave_list, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__leave__s2l, Decoded);
decode(m__fight__update_duty__s2l, Bytes) ->
    Types = [{3, cur_duty, int32, []},
	     {2, pre_duty, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__update_duty__s2l, Decoded);
decode(m__fight__random_duty__s2l, Bytes) ->
    Types = [{3, duty_list, int32, [repeated]},
	     {2, left_time, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__random_duty__s2l, Decoded);
decode(m__fight__select_duty__s2l, Bytes) ->
    Types = [{4, seat_id, int32, []}, {3, duty, int32, []},
	     {2, result, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__select_duty__s2l, Decoded);
decode(m__fight__notice_langren__s2l, Bytes) ->
    Types = [{3, bailang_list, int32, [repeated]},
	     {2, langren_list, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__notice_langren__s2l, Decoded);
decode(m__fight__forbid_other_speak__l2s, Bytes) ->
    Types = [{2, is_forbid, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__forbid_other_speak__l2s, Decoded);
decode(m__fight__forbid_other_speak__s2l, Bytes) ->
    Types = [{2, forbid_info, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__forbid_other_speak__s2l, Decoded);
decode(m__fight__chat_input__l2s, Bytes) ->
    Types = [{4, content, string, []},
	     {3, chat_type, int32, []},
	     {2, is_expression, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__chat_input__l2s, Decoded);
decode(m__fight__chat_input__s2l, Bytes) ->
    Types = [{5, content, string, []},
	     {4, player_id, uint32, []}, {3, chat_type, int32, []},
	     {2, is_expression, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__chat_input__s2l, Decoded);
decode(m__fight__dync_langren_op_data__s2l, Bytes) ->
    Types = [{2, op_data, int32, [repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__dync_langren_op_data__s2l, Decoded);
decode(m__fight__langren_op__s2l, Bytes) ->
    Types = [{2, seat_id, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__langren_op__s2l, Decoded);
decode(m__fight__nvwu_op__s2l, Bytes) ->
    Types = [{3, save_seat_id, int32, []},
	     {2, du_seat_id, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__nvwu_op__s2l, Decoded);
decode(m__fight_over_error__s2l, Bytes) ->
    Types = [{3, reason, int32, []},
	     {2, room_id, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight_over_error__s2l, Decoded);
decode(m__fight__daozei_op__s2l, Bytes) ->
    Types = [{2, duty, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__daozei_op__s2l, Decoded);
decode(p_die_info, Bytes) ->
    Types = [{4, is_night, int32, []},
	     {3, game_round, int32, []}, {2, die_type, int32, []},
	     {1, seat_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_die_info, Decoded);
decode(m__fight__end_info__s2l, Bytes) ->
    Types = [{4, result_type, int32, []},
	     {3, die_info, p_die_info, [is_record, repeated]},
	     {2, duty_list, p_duty, [is_record, repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__fight__end_info__s2l, Decoded);
decode(m__resource__push__s2l, Bytes) ->
    Types = [{4, action_id, int32, []}, {3, num, int32, []},
	     {2, resource_id, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__resource__push__s2l, Decoded);
decode(m__match__start_match__l2s, Bytes) ->
    Types = [{3, player_list, int32, [repeated]},
	     {2, mode, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__match__start_match__l2s, Decoded);
decode(m__match__end_match__l2s, Bytes) ->
    Types = [{2, mode, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__match__end_match__l2s, Decoded);
decode(m__match__end_match__s2l, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__match__end_match__s2l, Decoded);
decode(m__match__again_match__s2l, Bytes) ->
    Types = [{3, is_again, int32, []}, {2, mode, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__match__again_match__s2l, Decoded);
decode(m__match__notice_enter_match__s2l, Bytes) ->
    Types = [{4, wait_list, p_player_show_base,
	      [is_record, repeated]},
	     {3, mode, int32, []}, {2, wait_id, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__match__notice_enter_match__s2l, Decoded);
decode(m__match__enter_match__l2s, Bytes) ->
    Types = [{3, wait_id, int32, []}, {2, mode, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__match__enter_match__l2s, Decoded);
decode(m__match__enter_match_list__s2l, Bytes) ->
    Types = [{4, wait_list, p_player_show_base,
	      [is_record, repeated]},
	     {3, ready_list, p_player_show_base,
	      [is_record, repeated]},
	     {2, wait_id, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__match__enter_match_list__s2l, Decoded);
decode(p_rank, Bytes) ->
    Types = [{3, value, int32, []}, {2, rank, int32, []},
	     {1, player_show_base, p_player_show_base, [is_record]}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_rank, Decoded);
decode(m__rank__get_rank__l2s, Bytes) ->
    Types = [{4, end_rank, int32, []},
	     {3, start_rank, int32, []}, {2, rank_type, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__rank__get_rank__l2s, Decoded);
decode(m__rank__get_rank__s2l, Bytes) ->
    Types = [{5, rank_list, p_rank, [is_record, repeated]},
	     {4, end_rank, int32, []}, {3, start_rank, int32, []},
	     {2, rank_type, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__rank__get_rank__s2l, Decoded);
decode(p_friend, Bytes) ->
    Types = [{3, room_id, int32, []},
	     {2, status, int32, []},
	     {1, player_show_base, p_player_show_base, [is_record]}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_friend, Decoded);
decode(m__friend__get_friend__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__get_friend__l2s, Decoded);
decode(m__friend__get_friend__s2l, Bytes) ->
    Types = [{2, friend_list, p_friend,
	      [is_record, repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__get_friend__s2l, Decoded);
decode(m__friend__add_friend__l2s, Bytes) ->
    Types = [{2, add_friend, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__add_friend__l2s, Decoded);
decode(m__friend__remove_friend__l2s, Bytes) ->
    Types = [{2, remove_friend, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__remove_friend__l2s, Decoded);
decode(m__friend__private_chat__l2s, Bytes) ->
    Types = [{3, target_id, uint32, []},
	     {2, chat, p_chat, [is_record]}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__private_chat__l2s, Decoded);
decode(m__friend__private_chat__s2l, Bytes) ->
    Types = [{4, chat, p_chat, [is_record]},
	     {3, speak_info, p_player_show_base, [is_record]},
	     {2, target_info, p_player_show_base, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__private_chat__s2l, Decoded);
decode(m__friend__get_chat_list__l2s, Bytes) ->
    Types = [{2, friend_id, uint32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__get_chat_list__l2s, Decoded);
decode(m__friend__get_chat_list__s2l, Bytes) ->
    Types = [{2, chat_list, p_chat, [is_record, repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__get_chat_list__s2l, Decoded);
decode(m__friend__add_friend__s2l, Bytes) ->
    Types = [{2, friend, p_friend, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__add_friend__s2l, Decoded);
decode(m__friend__remove_friend__s2l, Bytes) ->
    Types = [{2, remove_friend, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__friend__remove_friend__s2l, Decoded).

decode(<<>>, _, Acc) -> Acc;
decode(<<Bytes/binary>>, Types, Acc) ->
    {{FNum, WireType}, Rest} =
	protobuffs:read_field_num_and_wire_type(Bytes),
    case lists:keysearch(FNum, 1, Types) of
      {value, {FNum, Name, Type, Opts}} ->
	  {Value1, Rest1} = case lists:member(is_record, Opts) of
			      true ->
				  {V, R} = protobuffs:decode_value(WireType,
								   bytes, Rest),
				  RecVal = decode(Type, V),
				  {RecVal, R};
			      false ->
				  {V, R} = protobuffs:decode_value(WireType,
								   Type, Rest),
				  {unpack_value(V, Type), R}
			    end,
	  case lists:member(repeated, Opts) of
	    true ->
		case lists:keytake(FNum, 1, Acc) of
		  {value, {FNum, Name, List}, Acc1} ->
		      decode(Rest1, Types,
			     [{FNum, Name,
			       lists:reverse([Value1 | lists:reverse(List)])}
			      | Acc1]);
		  false ->
		      decode(Rest1, Types, [{FNum, Name, [Value1]} | Acc])
		end;
	    false ->
		decode(Rest1, Types, [{FNum, Name, Value1} | Acc])
	  end;
      false -> exit({error, {unexpected_field_index, FNum}})
    end.

unpack_value(<<Binary/binary>>, string) ->
    binary_to_list(Binary);
unpack_value(Value, _) -> Value.

to_record(p_player_show_base, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     p_player_show_base),
					 Record, Name, Val)
		end,
		#p_player_show_base{}, DecodedTuples);
to_record(p_resource, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_resource),
					 Record, Name, Val)
		end,
		#p_resource{}, DecodedTuples);
to_record(m__account__login__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__account__login__l2s),
					 Record, Name, Val)
		end,
		#m__account__login__l2s{}, DecodedTuples);
to_record(m__account__login__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__account__login__s2l),
					 Record, Name, Val)
		end,
		#m__account__login__s2l{}, DecodedTuples);
to_record(m__account__heart_beat__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__account__heart_beat__l2s),
					 Record, Name, Val)
		end,
		#m__account__heart_beat__l2s{}, DecodedTuples);
to_record(m__account__heart_beat__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__account__heart_beat__s2l),
					 Record, Name, Val)
		end,
		#m__account__heart_beat__s2l{}, DecodedTuples);
to_record(m__player__info__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__info__l2s),
					 Record, Name, Val)
		end,
		#m__player__info__l2s{}, DecodedTuples);
to_record(p_win_rate, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_win_rate),
					 Record, Name, Val)
		end,
		#p_win_rate{}, DecodedTuples);
to_record(m__player__info__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__info__s2l),
					 Record, Name, Val)
		end,
		#m__player__info__s2l{}, DecodedTuples);
to_record(m__player__errcode__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__errcode__s2l),
					 Record, Name, Val)
		end,
		#m__player__errcode__s2l{}, DecodedTuples);
to_record(m__player__other_info__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__other_info__l2s),
					 Record, Name, Val)
		end,
		#m__player__other_info__l2s{}, DecodedTuples);
to_record(m__player__add_coin__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__add_coin__l2s),
					 Record, Name, Val)
		end,
		#m__player__add_coin__l2s{}, DecodedTuples);
to_record(m__player__add_diamond__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__add_diamond__l2s),
					 Record, Name, Val)
		end,
		#m__player__add_diamond__l2s{}, DecodedTuples);
to_record(m__player__change_name__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__change_name__l2s),
					 Record, Name, Val)
		end,
		#m__player__change_name__l2s{}, DecodedTuples);
to_record(m__player__change_name__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__change_name__s2l),
					 Record, Name, Val)
		end,
		#m__player__change_name__s2l{}, DecodedTuples);
to_record(m__player__kick__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__kick__s2l),
					 Record, Name, Val)
		end,
		#m__player__kick__s2l{}, DecodedTuples);
to_record(m__player__upload_head__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__upload_head__l2s),
					 Record, Name, Val)
		end,
		#m__player__upload_head__l2s{}, DecodedTuples);
to_record(m__player__upload_head__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__upload_head__s2l),
					 Record, Name, Val)
		end,
		#m__player__upload_head__s2l{}, DecodedTuples);
to_record(m__player__get_head__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__get_head__l2s),
					 Record, Name, Val)
		end,
		#m__player__get_head__l2s{}, DecodedTuples);
to_record(m__player__get_head__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__get_head__s2l),
					 Record, Name, Val)
		end,
		#m__player__get_head__s2l{}, DecodedTuples);
to_record(m__player__change_sex__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__change_sex__l2s),
					 Record, Name, Val)
		end,
		#m__player__change_sex__l2s{}, DecodedTuples);
to_record(m__player__change_sex__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__change_sex__s2l),
					 Record, Name, Val)
		end,
		#m__player__change_sex__s2l{}, DecodedTuples);
to_record(m__player__upload_head_img_name__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__upload_head_img_name__l2s),
					 Record, Name, Val)
		end,
		#m__player__upload_head_img_name__l2s{}, DecodedTuples);
to_record(m__player__upload_head_img_name__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__upload_head_img_name__s2l),
					 Record, Name, Val)
		end,
		#m__player__upload_head_img_name__s2l{}, DecodedTuples);
to_record(m__player__get_head_img_name__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__get_head_img_name__l2s),
					 Record, Name, Val)
		end,
		#m__player__get_head_img_name__l2s{}, DecodedTuples);
to_record(m__player__get_head_img_name__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__get_head_img_name__s2l),
					 Record, Name, Val)
		end,
		#m__player__get_head_img_name__s2l{}, DecodedTuples);
to_record(m__player__invite_friends__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__invite_friends__l2s),
					 Record, Name, Val)
		end,
		#m__player__invite_friends__l2s{}, DecodedTuples);
to_record(m__player__invite_friends__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__invite_friends__s2l),
					 Record, Name, Val)
		end,
		#m__player__invite_friends__s2l{}, DecodedTuples);
to_record(m__player__friend_invite__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__friend_invite__s2l),
					 Record, Name, Val)
		end,
		#m__player__friend_invite__s2l{}, DecodedTuples);
to_record(m__room__get_list__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__get_list__l2s),
					 Record, Name, Val)
		end,
		#m__room__get_list__l2s{}, DecodedTuples);
to_record(p_fight, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_fight), Record,
					 Name, Val)
		end,
		#p_fight{}, DecodedTuples);
to_record(p_room, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_room), Record,
					 Name, Val)
		end,
		#p_room{}, DecodedTuples);
to_record(m__room__get_list__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__get_list__s2l),
					 Record, Name, Val)
		end,
		#m__room__get_list__s2l{}, DecodedTuples);
to_record(m__room__enter_room__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__enter_room__l2s),
					 Record, Name, Val)
		end,
		#m__room__enter_room__l2s{}, DecodedTuples);
to_record(m__room__enter_room__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__enter_room__s2l),
					 Record, Name, Val)
		end,
		#m__room__enter_room__s2l{}, DecodedTuples);
to_record(m__room__create_room__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__create_room__l2s),
					 Record, Name, Val)
		end,
		#m__room__create_room__l2s{}, DecodedTuples);
to_record(m__room__create_room__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__create_room__s2l),
					 Record, Name, Val)
		end,
		#m__room__create_room__s2l{}, DecodedTuples);
to_record(m__room__leave_room__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__leave_room__l2s),
					 Record, Name, Val)
		end,
		#m__room__leave_room__l2s{}, DecodedTuples);
to_record(m__room__leave_room__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__leave_room__s2l),
					 Record, Name, Val)
		end,
		#m__room__leave_room__s2l{}, DecodedTuples);
to_record(m__room__rand_enter__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__rand_enter__l2s),
					 Record, Name, Val)
		end,
		#m__room__rand_enter__l2s{}, DecodedTuples);
to_record(m__room__start_fight__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__start_fight__l2s),
					 Record, Name, Val)
		end,
		#m__room__start_fight__l2s{}, DecodedTuples);
to_record(m__room__notice_member_change__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__notice_member_change__s2l),
					 Record, Name, Val)
		end,
		#m__room__notice_member_change__s2l{}, DecodedTuples);
to_record(m__room__want_chat__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__want_chat__l2s),
					 Record, Name, Val)
		end,
		#m__room__want_chat__l2s{}, DecodedTuples);
to_record(m__room__want_chat__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__want_chat__s2l),
					 Record, Name, Val)
		end,
		#m__room__want_chat__s2l{}, DecodedTuples);
to_record(m__room__notice_start_chat__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__notice_start_chat__s2l),
					 Record, Name, Val)
		end,
		#m__room__notice_start_chat__s2l{}, DecodedTuples);
to_record(m__room__end_chat__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__end_chat__l2s),
					 Record, Name, Val)
		end,
		#m__room__end_chat__l2s{}, DecodedTuples);
to_record(m__room__want_chat_list__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__want_chat_list__l2s),
					 Record, Name, Val)
		end,
		#m__room__want_chat_list__l2s{}, DecodedTuples);
to_record(m__room__want_chat_list__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__want_chat_list__s2l),
					 Record, Name, Val)
		end,
		#m__room__want_chat_list__s2l{}, DecodedTuples);
to_record(m__room__notice_chat_info__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__notice_chat_info__s2l),
					 Record, Name, Val)
		end,
		#m__room__notice_chat_info__s2l{}, DecodedTuples);
to_record(m__room__send_gift__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__send_gift__l2s),
					 Record, Name, Val)
		end,
		#m__room__send_gift__l2s{}, DecodedTuples);
to_record(m__room__send_gift__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__send_gift__s2l),
					 Record, Name, Val)
		end,
		#m__room__send_gift__s2l{}, DecodedTuples);
to_record(m__room__kick_player__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__kick_player__l2s),
					 Record, Name, Val)
		end,
		#m__room__kick_player__l2s{}, DecodedTuples);
to_record(m__room__kick_player__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__kick_player__s2l),
					 Record, Name, Val)
		end,
		#m__room__kick_player__s2l{}, DecodedTuples);
to_record(m__room__ready__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__ready__l2s),
					 Record, Name, Val)
		end,
		#m__room__ready__l2s{}, DecodedTuples);
to_record(m__room__cancle_ready__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__cancle_ready__l2s),
					 Record, Name, Val)
		end,
		#m__room__cancle_ready__l2s{}, DecodedTuples);
to_record(m__room__notice_all_ready__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__notice_all_ready__s2l),
					 Record, Name, Val)
		end,
		#m__room__notice_all_ready__s2l{}, DecodedTuples);
to_record(m__room__login_not_in_room__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__login_not_in_room__s2l),
					 Record, Name, Val)
		end,
		#m__room__login_not_in_room__s2l{}, DecodedTuples);
to_record(m__room__enter_fail__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__enter_fail__s2l),
					 Record, Name, Val)
		end,
		#m__room__enter_fail__s2l{}, DecodedTuples);
to_record(m__room__enter_simple_room__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__enter_simple_room__l2s),
					 Record, Name, Val)
		end,
		#m__room__enter_simple_room__l2s{}, DecodedTuples);
to_record(m__room__get_room_info__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__get_room_info__l2s),
					 Record, Name, Val)
		end,
		#m__room__get_room_info__l2s{}, DecodedTuples);
to_record(m__room__get_room_info__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__get_room_info__s2l),
					 Record, Name, Val)
		end,
		#m__room__get_room_info__s2l{}, DecodedTuples);
to_record(m__room__get_room_info_fail__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__get_room_info_fail__s2l),
					 Record, Name, Val)
		end,
		#m__room__get_room_info_fail__s2l{}, DecodedTuples);
to_record(m__room__get_not_full_normal_room_id_list__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__get_not_full_normal_room_id_list__l2s),
					 Record, Name, Val)
		end,
		#m__room__get_not_full_normal_room_id_list__l2s{},
		DecodedTuples);
to_record(m__room__get_not_full_normal_room_id_list__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__get_not_full_normal_room_id_list__s2l),
					 Record, Name, Val)
		end,
		#m__room__get_not_full_normal_room_id_list__s2l{},
		DecodedTuples);
to_record(p_chat, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_chat), Record,
					 Name, Val)
		end,
		#p_chat{}, DecodedTuples);
to_record(m__chat__public_speak__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__chat__public_speak__l2s),
					 Record, Name, Val)
		end,
		#m__chat__public_speak__l2s{}, DecodedTuples);
to_record(m__chat__public_speak__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__chat__public_speak__s2l),
					 Record, Name, Val)
		end,
		#m__chat__public_speak__s2l{}, DecodedTuples);
to_record(m__fight__game_state_change__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__game_state_change__s2l),
					 Record, Name, Val)
		end,
		#m__fight__game_state_change__s2l{}, DecodedTuples);
to_record(m__fight__notice_duty__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_duty__s2l),
					 Record, Name, Val)
		end,
		#m__fight__notice_duty__s2l{}, DecodedTuples);
to_record(m__fight__notice_op__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_op__s2l),
					 Record, Name, Val)
		end,
		#m__fight__notice_op__s2l{}, DecodedTuples);
to_record(m__fight__notice_op__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_op__l2s),
					 Record, Name, Val)
		end,
		#m__fight__notice_op__l2s{}, DecodedTuples);
to_record(m__fight__speak__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__speak__l2s),
					 Record, Name, Val)
		end,
		#m__fight__speak__l2s{}, DecodedTuples);
to_record(m__fight__speak__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__speak__s2l),
					 Record, Name, Val)
		end,
		#m__fight__speak__s2l{}, DecodedTuples);
to_record(m__fight__notice_lover__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_lover__s2l),
					 Record, Name, Val)
		end,
		#m__fight__notice_lover__s2l{}, DecodedTuples);
to_record(m__fight__notice_yuyanjia_result__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_yuyanjia_result__s2l),
					 Record, Name, Val)
		end,
		#m__fight__notice_yuyanjia_result__s2l{},
		DecodedTuples);
to_record(p_xuanju_result, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_xuanju_result),
					 Record, Name, Val)
		end,
		#p_xuanju_result{}, DecodedTuples);
to_record(m__fight__xuanju_result__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__xuanju_result__s2l),
					 Record, Name, Val)
		end,
		#m__fight__xuanju_result__s2l{}, DecodedTuples);
to_record(m__fight__night_result__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__night_result__s2l),
					 Record, Name, Val)
		end,
		#m__fight__night_result__s2l{}, DecodedTuples);
to_record(p_duty, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_duty), Record,
					 Name, Val)
		end,
		#p_duty{}, DecodedTuples);
to_record(m__fight__result__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__result__s2l),
					 Record, Name, Val)
		end,
		#m__fight__result__s2l{}, DecodedTuples);
to_record(m__fight__guipiao__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__guipiao__s2l),
					 Record, Name, Val)
		end,
		#m__fight__guipiao__s2l{}, DecodedTuples);
to_record(m__fight__notice_fayan__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_fayan__s2l),
					 Record, Name, Val)
		end,
		#m__fight__notice_fayan__s2l{}, DecodedTuples);
to_record(m__fight__stop_fayan__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__stop_fayan__s2l),
					 Record, Name, Val)
		end,
		#m__fight__stop_fayan__s2l{}, DecodedTuples);
to_record(m__fight__notice_hunxuer__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_hunxuer__s2l),
					 Record, Name, Val)
		end,
		#m__fight__notice_hunxuer__s2l{}, DecodedTuples);
to_record(m__fight__notice_part_jingzhang__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_part_jingzhang__s2l),
					 Record, Name, Val)
		end,
		#m__fight__notice_part_jingzhang__s2l{}, DecodedTuples);
to_record(m__fight__notice_skill__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_skill__s2l),
					 Record, Name, Val)
		end,
		#m__fight__notice_skill__s2l{}, DecodedTuples);
to_record(m__fight__do_skill__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__do_skill__l2s),
					 Record, Name, Val)
		end,
		#m__fight__do_skill__l2s{}, DecodedTuples);
to_record(p_flop, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_flop), Record,
					 Name, Val)
		end,
		#p_flop{}, DecodedTuples);
to_record(m__fight__online__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__online__s2l),
					 Record, Name, Val)
		end,
		#m__fight__online__s2l{}, DecodedTuples);
to_record(m__fight__offline__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__offline__s2l),
					 Record, Name, Val)
		end,
		#m__fight__offline__s2l{}, DecodedTuples);
to_record(m__fight__op_timetick__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__op_timetick__s2l),
					 Record, Name, Val)
		end,
		#m__fight__op_timetick__s2l{}, DecodedTuples);
to_record(m__fight__langren_team_speak__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__langren_team_speak__s2l),
					 Record, Name, Val)
		end,
		#m__fight__langren_team_speak__s2l{}, DecodedTuples);
to_record(m__fight__shouwei_op__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__shouwei_op__s2l),
					 Record, Name, Val)
		end,
		#m__fight__shouwei_op__s2l{}, DecodedTuples);
to_record(m__fight__over_info__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__over_info__s2l),
					 Record, Name, Val)
		end,
		#m__fight__over_info__s2l{}, DecodedTuples);
to_record(m__fight__leave__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__leave__s2l),
					 Record, Name, Val)
		end,
		#m__fight__leave__s2l{}, DecodedTuples);
to_record(m__fight__update_duty__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__update_duty__s2l),
					 Record, Name, Val)
		end,
		#m__fight__update_duty__s2l{}, DecodedTuples);
to_record(m__fight__random_duty__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__random_duty__s2l),
					 Record, Name, Val)
		end,
		#m__fight__random_duty__s2l{}, DecodedTuples);
to_record(m__fight__select_duty__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__select_duty__s2l),
					 Record, Name, Val)
		end,
		#m__fight__select_duty__s2l{}, DecodedTuples);
to_record(m__fight__notice_langren__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__notice_langren__s2l),
					 Record, Name, Val)
		end,
		#m__fight__notice_langren__s2l{}, DecodedTuples);
to_record(m__fight__forbid_other_speak__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__forbid_other_speak__l2s),
					 Record, Name, Val)
		end,
		#m__fight__forbid_other_speak__l2s{}, DecodedTuples);
to_record(m__fight__forbid_other_speak__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__forbid_other_speak__s2l),
					 Record, Name, Val)
		end,
		#m__fight__forbid_other_speak__s2l{}, DecodedTuples);
to_record(m__fight__chat_input__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__chat_input__l2s),
					 Record, Name, Val)
		end,
		#m__fight__chat_input__l2s{}, DecodedTuples);
to_record(m__fight__chat_input__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__chat_input__s2l),
					 Record, Name, Val)
		end,
		#m__fight__chat_input__s2l{}, DecodedTuples);
to_record(m__fight__dync_langren_op_data__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__dync_langren_op_data__s2l),
					 Record, Name, Val)
		end,
		#m__fight__dync_langren_op_data__s2l{}, DecodedTuples);
to_record(m__fight__langren_op__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__langren_op__s2l),
					 Record, Name, Val)
		end,
		#m__fight__langren_op__s2l{}, DecodedTuples);
to_record(m__fight__nvwu_op__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__nvwu_op__s2l),
					 Record, Name, Val)
		end,
		#m__fight__nvwu_op__s2l{}, DecodedTuples);
to_record(m__fight_over_error__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight_over_error__s2l),
					 Record, Name, Val)
		end,
		#m__fight_over_error__s2l{}, DecodedTuples);
to_record(m__fight__daozei_op__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__daozei_op__s2l),
					 Record, Name, Val)
		end,
		#m__fight__daozei_op__s2l{}, DecodedTuples);
to_record(p_die_info, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_die_info),
					 Record, Name, Val)
		end,
		#p_die_info{}, DecodedTuples);
to_record(m__fight__end_info__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__fight__end_info__s2l),
					 Record, Name, Val)
		end,
		#m__fight__end_info__s2l{}, DecodedTuples);
to_record(m__resource__push__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__resource__push__s2l),
					 Record, Name, Val)
		end,
		#m__resource__push__s2l{}, DecodedTuples);
to_record(m__match__start_match__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__match__start_match__l2s),
					 Record, Name, Val)
		end,
		#m__match__start_match__l2s{}, DecodedTuples);
to_record(m__match__end_match__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__match__end_match__l2s),
					 Record, Name, Val)
		end,
		#m__match__end_match__l2s{}, DecodedTuples);
to_record(m__match__end_match__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__match__end_match__s2l),
					 Record, Name, Val)
		end,
		#m__match__end_match__s2l{}, DecodedTuples);
to_record(m__match__again_match__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__match__again_match__s2l),
					 Record, Name, Val)
		end,
		#m__match__again_match__s2l{}, DecodedTuples);
to_record(m__match__notice_enter_match__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__match__notice_enter_match__s2l),
					 Record, Name, Val)
		end,
		#m__match__notice_enter_match__s2l{}, DecodedTuples);
to_record(m__match__enter_match__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__match__enter_match__l2s),
					 Record, Name, Val)
		end,
		#m__match__enter_match__l2s{}, DecodedTuples);
to_record(m__match__enter_match_list__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__match__enter_match_list__s2l),
					 Record, Name, Val)
		end,
		#m__match__enter_match_list__s2l{}, DecodedTuples);
to_record(p_rank, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_rank), Record,
					 Name, Val)
		end,
		#p_rank{}, DecodedTuples);
to_record(m__rank__get_rank__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__rank__get_rank__l2s),
					 Record, Name, Val)
		end,
		#m__rank__get_rank__l2s{}, DecodedTuples);
to_record(m__rank__get_rank__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__rank__get_rank__s2l),
					 Record, Name, Val)
		end,
		#m__rank__get_rank__s2l{}, DecodedTuples);
to_record(p_friend, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_friend), Record,
					 Name, Val)
		end,
		#p_friend{}, DecodedTuples);
to_record(m__friend__get_friend__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__get_friend__l2s),
					 Record, Name, Val)
		end,
		#m__friend__get_friend__l2s{}, DecodedTuples);
to_record(m__friend__get_friend__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__get_friend__s2l),
					 Record, Name, Val)
		end,
		#m__friend__get_friend__s2l{}, DecodedTuples);
to_record(m__friend__add_friend__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__add_friend__l2s),
					 Record, Name, Val)
		end,
		#m__friend__add_friend__l2s{}, DecodedTuples);
to_record(m__friend__remove_friend__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__remove_friend__l2s),
					 Record, Name, Val)
		end,
		#m__friend__remove_friend__l2s{}, DecodedTuples);
to_record(m__friend__private_chat__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__private_chat__l2s),
					 Record, Name, Val)
		end,
		#m__friend__private_chat__l2s{}, DecodedTuples);
to_record(m__friend__private_chat__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__private_chat__s2l),
					 Record, Name, Val)
		end,
		#m__friend__private_chat__s2l{}, DecodedTuples);
to_record(m__friend__get_chat_list__l2s,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__get_chat_list__l2s),
					 Record, Name, Val)
		end,
		#m__friend__get_chat_list__l2s{}, DecodedTuples);
to_record(m__friend__get_chat_list__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__get_chat_list__s2l),
					 Record, Name, Val)
		end,
		#m__friend__get_chat_list__s2l{}, DecodedTuples);
to_record(m__friend__add_friend__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__add_friend__s2l),
					 Record, Name, Val)
		end,
		#m__friend__add_friend__s2l{}, DecodedTuples);
to_record(m__friend__remove_friend__s2l,
	  DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__friend__remove_friend__s2l),
					 Record, Name, Val)
		end,
		#m__friend__remove_friend__s2l{}, DecodedTuples).

set_record_field(Fields, Record, Field, Value) ->
    Index = list_index(Field, Fields),
    erlang:setelement(Index + 1, Record, Value).

list_index(Target, List) -> list_index(Target, List, 1).

list_index(Target, [Target | _], Index) -> Index;
list_index(Target, [_ | Tail], Index) ->
    list_index(Target, Tail, Index + 1);
list_index(_, [], _) -> 0.

