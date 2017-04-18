-module(b_proto_route).
-export([get/1]).

get(10001) -> {m__account__login__l2s, mod_account, login}; 
get(10002) -> {m__account__login__s2l, mod_account, login}; 
get(10003) -> {m__account__heart_beat__l2s, mod_account, heart_beat}; 
get(10004) -> {m__account__heart_beat__s2l, mod_account, heart_beat}; 
get(12001) -> {m__player__info__l2s, mod_player, info}; 
get(12002) -> {m__player__info__s2l, mod_player, info}; 
get(12004) -> {m__player__errcode__s2l, mod_player, errcode}; 
get(12005) -> {m__player__other_info__l2s, mod_player, other_info}; 
get(12006) -> {m__player__add_coin__l2s, mod_player, add_coin}; 
get(12007) -> {m__player__add_diamond__l2s, mod_player, add_diamond}; 
get(12008) -> {m__player__change_name__l2s, mod_player, change_name}; 
get(12009) -> {m__player__change_name__s2l, mod_player, change_name}; 
get(12010) -> {m__player__kick__s2l, mod_player, kick}; 
get(12011) -> {m__player__upload_head__l2s, mod_player, upload_head}; 
get(12012) -> {m__player__upload_head__s2l, mod_player, upload_head}; 
get(12013) -> {m__player__get_head__l2s, mod_player, get_head}; 
get(12014) -> {m__player__get_head__s2l, mod_player, get_head}; 
get(12015) -> {m__player__change_sex__l2s, mod_player, change_sex}; 
get(12016) -> {m__player__change_sex__s2l, mod_player, change_sex}; 
get(12017) -> {m__player__upload_head_img_name__l2s, mod_player, upload_head_img_name}; 
get(12018) -> {m__player__upload_head_img_name__s2l, mod_player, upload_head_img_name}; 
get(12019) -> {m__player__get_head_img_name__l2s, mod_player, get_head_img_name}; 
get(12020) -> {m__player__get_head_img_name__s2l, mod_player, get_head_img_name}; 
get(12021) -> {m__player__invite_friends__l2s, mod_player, invite_friends}; 
get(12022) -> {m__player__invite_friends__s2l, mod_player, invite_friends}; 
get(12023) -> {m__player__friend_invite__s2l, mod_player, friend_invite}; 
get(12024) -> {m__player__update_player_base_info__s2l, mod_player, update_player_base_info}; 
get(12025) -> {m__player__update_gvoice_status__l2s, mod_player, update_gvoice_status}; 
get(13001) -> {m__room__get_list__l2s, mod_room, get_list}; 
get(13002) -> {m__room__get_list__s2l, mod_room, get_list}; 
get(13003) -> {m__room__enter_room__l2s, mod_room, enter_room}; 
get(13004) -> {m__room__enter_room__s2l, mod_room, enter_room}; 
get(13005) -> {m__room__create_room__l2s, mod_room, create_room}; 
get(13006) -> {m__room__create_room__s2l, mod_room, create_room}; 
get(13007) -> {m__room__leave_room__l2s, mod_room, leave_room}; 
get(13008) -> {m__room__leave_room__s2l, mod_room, leave_room}; 
get(13009) -> {m__room__rand_enter__l2s, mod_room, rand_enter}; 
get(13011) -> {m__room__start_fight__l2s, mod_room, start_fight}; 
get(13012) -> {m__room__notice_member_change__s2l, mod_room, notice_member_change}; 
get(13013) -> {m__room__want_chat__l2s, mod_room, want_chat}; 
get(13014) -> {m__room__want_chat__s2l, mod_room, want_chat}; 
get(13015) -> {m__room__notice_start_chat__s2l, mod_room, notice_start_chat}; 
get(13016) -> {m__room__end_chat__l2s, mod_room, end_chat}; 
get(13017) -> {m__room__want_chat_list__l2s, mod_room, want_chat_list}; 
get(13018) -> {m__room__want_chat_list__s2l, mod_room, want_chat_list}; 
get(13019) -> {m__room__notice_chat_info__s2l, mod_room, notice_chat_info}; 
get(13020) -> {m__room__send_gift__l2s, mod_room, send_gift}; 
get(13021) -> {m__room__send_gift__s2l, mod_room, send_gift}; 
get(13022) -> {m__room__kick_player__l2s, mod_room, kick_player}; 
get(13023) -> {m__room__kick_player__s2l, mod_room, kick_player}; 
get(13024) -> {m__room__ready__l2s, mod_room, ready}; 
get(13025) -> {m__room__cancle_ready__l2s, mod_room, cancle_ready}; 
get(13026) -> {m__room__notice_all_ready__s2l, mod_room, notice_all_ready}; 
get(13027) -> {m__room__login_not_in_room__s2l, mod_room, login_not_in_room}; 
get(13028) -> {m__room__enter_fail__s2l, mod_room, enter_fail}; 
get(13029) -> {m__room__enter_simple_room__l2s, mod_room, enter_simple_room}; 
get(13030) -> {m__room__get_room_info__l2s, mod_room, get_room_info}; 
get(13031) -> {m__room__get_room_info__s2l, mod_room, get_room_info}; 
get(13032) -> {m__room__get_room_info_fail__s2l, mod_room, get_room_info_fail}; 
get(13033) -> {m__room__get_not_full_normal_room_id_list__l2s, mod_room, get_not_full_normal_room_id_list}; 
get(13034) -> {m__room__get_not_full_normal_room_id_list__s2l, mod_room, get_not_full_normal_room_id_list}; 
get(14001) -> {m__chat__public_speak__l2s, mod_chat, public_speak}; 
get(14002) -> {m__chat__public_speak__s2l, mod_chat, public_speak}; 
get(15001) -> {m__fight__game_state_change__s2l, mod_fight, game_state_change}; 
get(15002) -> {m__fight__notice_duty__s2l, mod_fight, notice_duty}; 
get(15003) -> {m__fight__notice_op__s2l, mod_fight, notice_op}; 
get(15004) -> {m__fight__notice_op__l2s, mod_fight, notice_op}; 
get(15005) -> {m__fight__speak__l2s, mod_fight, speak}; 
get(15006) -> {m__fight__speak__s2l, mod_fight, speak}; 
get(15007) -> {m__fight__notice_lover__s2l, mod_fight, notice_lover}; 
get(15008) -> {m__fight__notice_yuyanjia_result__s2l, mod_fight, notice_yuyanjia_result}; 
get(15009) -> {m__fight__xuanju_result__s2l, mod_fight, xuanju_result}; 
get(15010) -> {m__fight__night_result__s2l, mod_fight, night_result}; 
get(15011) -> {m__fight__result__s2l, mod_fight, result}; 
get(15012) -> {m__fight__guipiao__s2l, mod_fight, guipiao}; 
get(15013) -> {m__fight__notice_fayan__s2l, mod_fight, notice_fayan}; 
get(15014) -> {m__fight__stop_fayan__s2l, mod_fight, stop_fayan}; 
get(15015) -> {m__fight__notice_hunxuer__s2l, mod_fight, notice_hunxuer}; 
get(15016) -> {m__fight__notice_part_jingzhang__s2l, mod_fight, notice_part_jingzhang}; 
get(15017) -> {m__fight__notice_skill__s2l, mod_fight, notice_skill}; 
get(15018) -> {m__fight__do_skill__l2s, mod_fight, do_skill}; 
get(15019) -> {m__fight__online__s2l, mod_fight, online}; 
get(15020) -> {m__fight__offline__s2l, mod_fight, offline}; 
get(15021) -> {m__fight__op_timetick__s2l, mod_fight, op_timetick}; 
get(15022) -> {m__fight__langren_team_speak__s2l, mod_fight, langren_team_speak}; 
get(15023) -> {m__fight__shouwei_op__s2l, mod_fight, shouwei_op}; 
get(15024) -> {m__fight__over_info__s2l, mod_fight, over_info}; 
get(15025) -> {m__fight__leave__s2l, mod_fight, leave}; 
get(15026) -> {m__fight__update_duty__s2l, mod_fight, update_duty}; 
get(15027) -> {m__fight__random_duty__s2l, mod_fight, random_duty}; 
get(15028) -> {m__fight__select_duty__s2l, mod_fight, select_duty}; 
get(15029) -> {m__fight__notice_langren__s2l, mod_fight, notice_langren}; 
get(15030) -> {m__fight__forbid_other_speak__l2s, mod_fight, forbid_other_speak}; 
get(15031) -> {m__fight__forbid_other_speak__s2l, mod_fight, forbid_other_speak}; 
get(15032) -> {m__fight__chat_input__l2s, mod_fight, chat_input}; 
get(15033) -> {m__fight__chat_input__s2l, mod_fight, chat_input}; 
get(15034) -> {m__fight__dync_langren_op_data__s2l, mod_fight, dync_langren_op_data}; 
get(15035) -> {m__fight__langren_op__s2l, mod_fight, langren_op}; 
get(15036) -> {m__fight__nvwu_op__s2l, mod_fight, nvwu_op}; 
get(15038) -> {m__fight__daozei_op__s2l, mod_fight, daozei_op}; 
get(15039) -> {m__fight__end_info__s2l, mod_fight, end_info}; 
get(16001) -> {m__resource__push__s2l, mod_resource, push}; 
get(17001) -> {m__match__start_match__l2s, mod_match, start_match}; 
get(17002) -> {m__match__end_match__l2s, mod_match, end_match}; 
get(17003) -> {m__match__end_match__s2l, mod_match, end_match}; 
get(17004) -> {m__match__again_match__s2l, mod_match, again_match}; 
get(17005) -> {m__match__notice_enter_match__s2l, mod_match, notice_enter_match}; 
get(17006) -> {m__match__enter_match__l2s, mod_match, enter_match}; 
get(17007) -> {m__match__enter_match_list__s2l, mod_match, enter_match_list}; 
get(18001) -> {m__rank__get_rank__l2s, mod_rank, get_rank}; 
get(18002) -> {m__rank__get_rank__s2l, mod_rank, get_rank}; 
get(19001) -> {m__friend__get_friend__l2s, mod_friend, get_friend}; 
get(19002) -> {m__friend__get_friend__s2l, mod_friend, get_friend}; 
get(19003) -> {m__friend__add_friend__l2s, mod_friend, add_friend}; 
get(19005) -> {m__friend__remove_friend__l2s, mod_friend, remove_friend}; 
get(19007) -> {m__friend__private_chat__l2s, mod_friend, private_chat}; 
get(19008) -> {m__friend__private_chat__s2l, mod_friend, private_chat}; 
get(19009) -> {m__friend__get_chat_list__l2s, mod_friend, get_chat_list}; 
get(19010) -> {m__friend__get_chat_list__s2l, mod_friend, get_chat_list}; 
get(19011) -> {m__friend__add_friend__s2l, mod_friend, add_friend}; 
get(19012) -> {m__friend__remove_friend__s2l, mod_friend, remove_friend}; 
get(_) -> undefined. 
