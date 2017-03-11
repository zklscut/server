%% @author zhangkl
%% @doc lib_fight.
%% 2016

-module(lib_fight).
-export([init/5,
         send_to_all_player/2,
         send_to_all_player/3,
         send_to_seat/3,
         is_active_in_fight/2,
         is_offline_all/2,
         get_p_fight/1,
         get_player_id_by_seat/2,
         get_seat_id_by_player_id/2,
         get_duty_by_seat/2,
         get_lieren_kill/1,
         update_duty/4,
         get_duty_seat/2,
         get_duty_seat/3,
         get_all_seat/1,
         get_alive_seat_list/1,
         do_daozei_op/1,
         do_qiubite_op/1,
         do_hunxuer_op/1,
         do_shouwei_op/1,
         do_langren_op/1,
         do_nvwu_op/1,
         do_yuyanjia_op/1,
         do_part_jingzhang_op/1,
         do_xuanju_jingzhang_op/1,
         do_jingzhang_op/1,
         do_no_jingzhang_op/1,
         do_fayan_op/1,
         do_send_fayan/3,
         do_send_langren_team_fayan/4,
         do_guipiao_op/1,
         do_toupiao_op/1,
         do_toupiao_mvp_op/1,
         do_toupiao_carry_op/1,
         is_third_part_win/1,
         get_langren_qiubite_seat/1,
         get_haoren_qiubite_seat/1,
         get_third_part_qiubite_seat/1,
         get_third_part_seat/1,
         is_duty_exist/2,
         get_shenmin_seat/1,
         enable_third_part_qiubite/1,
         get_langren_hunxuer_seat/1,
         get_haoren_hunxuer_seat/1,
         is_seat_alive/2,
         do_skill/4,
         rand_in_alive_seat/1,
         get_someone_die_op/1,
         clear_last_op/1,
         lover_die_judge/2,
         get_lover_kill/1,
         set_skill_die_list/2,
         get_max_luck_seat/2]).

-include("fight.hrl").
-include("game_pb.hrl").
-include("resource.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

init(RoomId, PlayerList, DutyList, Name, State) ->
    State1 = State#{room_id := RoomId},
    State2 = init_seat(PlayerList, State1),
    State3 = init_duty(PlayerList, DutyList, State2),
    StateAfterDutyList = maps:put(duty_list, DutyList, State3),
    StateAfterPlayerList = maps:put(player_list, PlayerList, StateAfterDutyList),
    StateAfterName = maps:put(room_name, Name, StateAfterPlayerList),
    StateAfterName#{player_num := length(DutyList)}.

get_p_fight(State)->
    
    PFight = #p_fight{
        room_name = maps:get(room_name, State),
        duty_list = maps:get(duty_list, State),
        player_info_list = [lib_player:get_player_show_base(PlayerId) || PlayerId <- maps:get(player_list, State)]
    },
    lager:info("get_p_fight~p", [PFight]),
    PFight.

send_to_all_player(Send, State) ->
    send_to_all_player(Send, State, []).

send_to_all_player(Send, State, NotSendList) ->
    [net_send:send(Send, PlayerId) || PlayerId <- maps:keys(maps:get(player_seat_map, State)),
     is_active_in_fight(PlayerId, State) andalso (not lists:member(PlayerId, NotSendList))].

send_to_seat(Send, SeatId, State) ->
    PlayerId = get_player_id_by_seat(SeatId, State),
    case is_active_in_fight(PlayerId, State) of
        true ->
            net_send:send(Send, PlayerId);
        false ->
            ignore
    end.

is_active_in_fight(PlayerId, State) ->
    true.
    % case lists:member(PlayerId, maps:get(leave_player, State)) of
    %     true->
    %         lager:info("is_active_in_fight ~p", [maps:get(leave_player, State)]),
    %         false;
    %     _->
    %         true
    % end.
    % not lists:member(PlayerId, maps:get(leave_player, State)).

%判断是否都处于离线状态
is_offline_all(SeatList, State) ->
    OfflineList = maps:get(offline_list, State) ++ maps:get(leave_player, State),
    case SeatList of
        []->
            true;
        _->
            lists:all(fun(SeatId)-> lists:member(get_player_id_by_seat(SeatId, State), OfflineList) end, SeatList)
    end.

get_player_id_by_seat(SeatId, State) ->
    maps:get(SeatId, maps:get(seat_player_map, State)).

get_seat_id_by_player_id(PlayerId, State) ->
    maps:get(PlayerId, maps:get(player_seat_map, State)).    

get_duty_by_seat(SeatId, State) ->
    maps:get(SeatId, maps:get(seat_duty_map, State)).    

get_duty_seat(?DUTY_LANGREN, State) ->
    get_duty_seat(true, ?DUTY_LANGREN, State) ++ get_duty_seat(true, ?DUTY_BAILANG, State);

get_duty_seat(Duty, State) ->
    get_duty_seat(true, Duty, State).

get_duty_seat(?DUTY_LANGREN, false, State) ->
    get_duty_seat(false, ?DUTY_LANGREN, State) ++ get_duty_seat(false, ?DUTY_BAILANG, State);

get_duty_seat(IsAlive, Duty, State) ->
    DutySeatMap = maps:get(duty_seat_map, State),
    AllDutySeat = maps:get(Duty, DutySeatMap, []),
    case IsAlive of
        true ->
            filter_out_seat(AllDutySeat, State);
        false ->
            AllDutySeat
    end.

get_all_seat(State) ->
    maps:keys(maps:get(seat_player_map, State)).

get_alive_seat_list(State) ->
    filter_out_seat(get_all_seat(State), State).

is_seat_alive(SeatId, State) ->
    case SeatId of
        0 ->
            false;

        _->
            DieList = (maps:get(out_seat_list, State) ++ maps:get(die, State) ++ 
                            [maps:get(quzhu, State)]) -- [maps:get(baichi, State)],
            not lists:member(SeatId, DieList)
    end.

%%是否平安日

%获得神名列表
get_shenmin_seat(State)->
    PlayerNum = maps:get(player_num, State),
    ShenMinList = 
        case PlayerNum =< 12 of
            true->
                ?DUTY_LIST_SHENMIN ++ [?DUTY_QIUBITE];
            false->
                ?DUTY_LIST_SHENMIN
        end,
    lists:flatten([lib_fight:get_duty_seat(DutyId, State) || DutyId <- ShenMinList]).

%判断是否第三方获胜
is_third_part_win(State) ->
    ThirdPartList = get_third_part_seat(State),
    ThirdPartListLen = length(ThirdPartList),
    Alivelist = get_alive_seat_list(State),
    Alivelen = length(Alivelist),
    case enable_third_part_qiubite(State) of
        true->
            case ThirdPartListLen == 3 of
                true ->
                    case Alivelen =< 3 of
                        true ->
                            lists:all(fun(SeatId)-> lists:member(SeatId, ThirdPartList) end, Alivelist);
                        false ->
                            false
                    end;
                false ->
                    false
            end;
        false->
            false
    end.

%获取狼人阵营丘比特(大于12人并且链子是两个狼人)
get_langren_qiubite_seat(State)->
    case is_duty_exist(?DUTY_QIUBITE, State) of
        true->
            PlayerNum = maps:get(player_num, State),
            LangRenList = [?DUTY_LANGREN, ?DUTY_BAILANG],
            [Lover1, Lover2] = maps:get(lover, State),
            LoverDuty1 = get_duty_by_seat(Lover1, State),
            LoverDuty2 = get_duty_by_seat(Lover2, State),
            case PlayerNum > 12 andalso lists:member(LoverDuty1, LangRenList) andalso lists:member(LoverDuty2, LangRenList) of
                true->
                    [get_duty_by_seat(?DUTY_QIUBITE, State)];
                false->
                    []
            end;
        false->
            []
    end.

%获取好人阵营丘比特(小于12人并且链子是两个好人)
get_haoren_qiubite_seat(State)->
    case is_duty_exist(?DUTY_QIUBITE, State) of
        true->
            PlayerNum = maps:get(player_num, State),
            LangRenList = [?DUTY_LANGREN, ?DUTY_BAILANG],
            [Lover1, Lover2] = maps:get(lover, State),
            LoverDuty1 = get_duty_by_seat(Lover1, State),
            LoverDuty2 = get_duty_by_seat(Lover2, State),
            case PlayerNum =< 12 of
                true->
                    [get_duty_by_seat(?DUTY_QIUBITE, State)];
                false->
                    case lists:member(LoverDuty1, LangRenList) orelse lists:member(LoverDuty2, LangRenList) of
                        true->
                            [];
                        false->
                            [get_duty_by_seat(?DUTY_QIUBITE, State)]
                    end
            end;
        false->
            []
    end.

%获取第三方丘比特阵营(大于12人并且链子是一个好人一个坏人)
get_third_part_qiubite_seat(State)->
    case is_duty_exist(?DUTY_QIUBITE, State) of
        true->
            PlayerNum = maps:get(player_num, State),
            LangRenList = [?DUTY_LANGREN, ?DUTY_BAILANG],
            [Lover1, Lover2] = maps:get(lover, State),
            LoverDuty1 = get_duty_by_seat(Lover1, State),
            LoverDuty2 = get_duty_by_seat(Lover2, State),
            case PlayerNum =< 12 of
                true->
                    [];
                false->
                    case lists:member(LoverDuty1, LangRenList) andalso lists:member(LoverDuty2, LangRenList) of
                        true->
                            [];
                        false->
                            case lists:member(LoverDuty1, LangRenList) orelse lists:member(LoverDuty2, LangRenList) of
                                true->
                                    [get_duty_by_seat(?DUTY_QIUBITE, State)];
                                false->
                                    []
                            end
                    end
            end;
        false->
            []
    end.


%
get_langren_hunxuer_seat(State)->
    Hunxuer = maps:get(hunxuer, State),
    case Hunxuer =/= 0 of
        true->
            LangRenList = [?DUTY_LANGREN, ?DUTY_BAILANG],
            HunxuerDuty = get_duty_by_seat(Hunxuer, State),
            case lists:member(HunxuerDuty, LangRenList) of
                true->
                    get_duty_seat(false, ?DUTY_HUNXUEER, State);
                false->
                    []
            end;
        false->
            []
    end.

get_haoren_hunxuer_seat(State)->
    Hunxuer = maps:get(hunxuer, State),
    case Hunxuer =/= 0 of
        true->
            LangRenList = [?DUTY_LANGREN, ?DUTY_BAILANG],
            HunxuerDuty = get_duty_by_seat(Hunxuer, State),
            case lists:member(HunxuerDuty, LangRenList) of
                true->
                    [];
                false->
                    get_duty_seat(false, ?DUTY_HUNXUEER, State)
            end;
        false->
            []
    end.

%是否可作为第三方丘比特
enable_third_part_qiubite(State)->
    case is_duty_exist(?DUTY_QIUBITE, State) of
        true->
            LangRenList = [?DUTY_LANGREN, ?DUTY_BAILANG],
            [Lover1, Lover2] = maps:get(lover, State),
            LoverDuty1 = get_duty_by_seat(Lover1, State),
            LoverDuty2 = get_duty_by_seat(Lover2, State),
            case lists:member(LoverDuty1, LangRenList) andalso lists:member(LoverDuty2, LangRenList) of
                true->
                    false;
                false->
                    case lists:member(LoverDuty1, LangRenList) orelse lists:member(LoverDuty2, LangRenList) of
                        true->
                            true;
                        false->
                            false
                    end
            end;
        false->
            false
    end.

%取得第三方位置列表
get_third_part_seat(State)->
    Lover = maps:get(lover, State),
    SeatIdList = get_duty_seat(false, ?DUTY_QIUBITE, State),
    Lover ++ SeatIdList.

is_duty_exist(Duty, State) ->
    SeatIdList = get_duty_seat(false, Duty, State),
    case SeatIdList of
        [] ->
            false;
        _ ->
            true
    end.

get_lieren_kill(State) ->
    case maps:get(lieren_kill, State) of
        0 ->
            [];
        LieRenKill ->
            [LieRenKill]
    end.

get_lover_kill(State) ->
    case maps:get(lover_kill, State) of
        0 ->
            [];
        LoverKill ->
            [LoverKill]
    end.

filter_out_seat(SeatList, State) ->
    [SeatId || SeatId <- SeatList, not lists:member(SeatId, maps:get(out_seat_list, State))].

update_duty(SeatId, PreDuty, Duty, State) ->
    NewSeatDutyMap = maps:put(SeatId, Duty, maps:get(seat_duty_map, State)),
    DutySeatMap = maps:get(duty_seat_map, State),
    NewPreDutySeatList = maps:get(PreDuty, DutySeatMap, []) -- [SeatId],
    NewNewDutySeatList = maps:get(Duty, DutySeatMap, []) ++ [SeatId],
    NewDutySeatMap = DutySeatMap#{PreDuty => NewPreDutySeatList,
                                  Duty => NewNewDutySeatList},
    State#{duty_seat_map := NewDutySeatMap,
           seat_duty_map := NewSeatDutyMap}.                                  

do_daozei_op(State) ->
    LastOpData = get_last_op(State),
    [{SeatId, [Duty]}] = maps:to_list(LastOpData),
    StateDaoZeiSeat = maps:put(daozei_seat, SeatId, State),
    StateAfterDuty = update_duty(SeatId, ?DUTY_DAOZEI, Duty, StateDaoZeiSeat),
    clear_last_op(StateAfterDuty).

do_qiubite_op(State) ->
    LastOpData = get_last_op(State),
    [{SeatId, [Seat1, Seat2]}] = maps:to_list(LastOpData),
    StateAfterLover = maps:put(lover, [Seat1, Seat2], State),
    notice_lover(Seat1, Seat2, SeatId, State),
    clear_last_op(StateAfterLover).

do_shouwei_op(State) ->
    LastOpData = get_last_op(State),
    [{OpSeatId, [SeatId]}] = maps:to_list(LastOpData),
    StateAfterShouWei = maps:put(shouwei, SeatId, State),
    %%todo:通知守护目标
    Send = #m__fight__shouwei_op__s2l{seat_id = SeatId},
    send_to_seat(Send, OpSeatId, StateAfterShouWei),
    clear_last_op(StateAfterShouWei).

do_hunxuer_op(State) ->
    LastOpData = get_last_op(State),
    [{SeatId, [SelectSeatId]}] = maps:to_list(LastOpData),
    % SelectDuty = lib_fight:get_duty_by_seat(SelectSeatId, State),
    % HunxueerOp =
    %     case SelectDuty of
    %         ?DUTY_LANGREN ->
    %             1;
    %         _ ->
    %             0
    %     end,                
    StateAfterHunxueer = maps:put(hunxuer, SelectSeatId, State),

    Send = #m__fight__notice_hunxuer__s2l{select_seat = SelectSeatId},
    send_to_seat(Send, SeatId, State),

    clear_last_op(StateAfterHunxueer).

do_nvwu_op(State) ->
    LastOpData = get_last_op(State),
    [{_, [SelectSeatId, UseYao]}] = maps:to_list(LastOpData),
    StateAfterNvwu = maps:put(nvwu, {SelectSeatId, UseYao}, State),
    StateAfterDelete = maps:put(nvwu_left, maps:get(nvwu_left, State) -- [UseYao], StateAfterNvwu),
    StateAfterUpdateDie = do_set_die_list(StateAfterDelete),
    StateAfterNvKill = 
    case maps:get(nvwu, State) of
        {NvWuKill, ?NVWU_DUYAO} ->
            maps:put(nv_kill, NvWuKill, StateAfterUpdateDie);
        _ ->
            StateAfterUpdateDie
    end,
    clear_last_op(StateAfterNvKill).        

do_langren_op(State) ->
    LastOpData = get_last_op(State),
    KillSeat = 
        case maps:to_list(LastOpData) of
            [] ->
                0;
            _ ->
                rand_target_in_op(filter_last_op(LastOpData))
        end,
    StateAfterLangren = maps:put(langren, KillSeat, State),
    StateAfterUpdateDie = do_set_die_list(StateAfterLangren),

    %%白痴翻牌的情况下是不是被杀
    clear_last_op(StateAfterUpdateDie). 

do_yuyanjia_op(State) ->
    LastOpData = get_last_op(State),
    case maps:to_list(LastOpData) of
        [] ->
            clear_last_op(State);
        [{SeatId, [SelectSeatId]}]  ->
            NewState = 
                case SelectSeatId == 0 of
                    true ->
                        State;
                    false ->    
                        SelectDuty = lib_fight:get_duty_by_seat(SelectSeatId, State),
            
                        Send = #m__fight__notice_yuyanjia_result__s2l{seat_id = SelectSeatId,
                                                                  duty = SelectDuty},
                        send_to_seat(Send, SeatId, State),
                        NewYuyanjia = maps:get(yuyanjia_op, State) ++ [{SelectSeatId, SelectDuty}],
                        maps:put(yuyanjia_op, NewYuyanjia, State)
                end,
            clear_last_op(NewState)
    end.

do_part_jingzhang_op(State) ->
    LastOpData = get_last_op(State),
    PartList = maps:keys(filter_last_op(LastOpData)),
    StateAfterFayan = maps:put(fayan_turn, PartList, State),
    clear_last_op(maps:put(part_jingzhang, PartList, StateAfterFayan)).

do_xuanju_jingzhang_op(State) ->
    LastOpData = get_last_op(State),
    {IsDraw, ResultList, MaxSeatList} = count_xuanju_result(LastOpData),
    DrawCnt = maps:get(xuanju_draw_cnt, State),
    {DrawResult, NewState} = 
        case IsDraw of
            false ->
                {false, State#{xuanju_draw_cnt := 0,
                               jingzhang := hd(MaxSeatList)}};
            true ->
                case DrawCnt > 0 of
                    true ->
                        {false, State#{xuanju_draw_cnt := 0,
                                       jingzhang := 0}};
                    false ->
                        {true , State#{xuanju_draw_cnt := 1,
                                       jingzhang := 0}}
                end
        end,

    {DrawResult, ResultList, MaxSeatList, clear_last_op(NewState)}.

do_jingzhang_op(State) ->
    LastOpData = get_last_op(State),
    [{SeatId, [First, Turn]}] = 
        case maps:to_list(LastOpData) of
            [] ->
                [{0, [0, ?TURN_DOWN]}];
            OpList ->
                OpList
        end,
    StateAfterJingzhang = maps:put(jingzhang_op, {First, Turn}, State),
    FayanTurn = generate_fayan_turn(SeatId, First, Turn, State),
    StateAfterFayanTurn = maps:put(fayan_turn, FayanTurn, StateAfterJingzhang),
    clear_last_op(StateAfterFayanTurn).

do_no_jingzhang_op(State) ->
    FayanTurn = generate_fayan_turn(0, 0, ?TURN_DOWN, State),
    StateAfterFayanTurn = maps:put(fayan_turn, FayanTurn, State),
    clear_last_op(StateAfterFayanTurn).

do_fayan_op(State) ->
    FanyanTurn = maps:get(fayan_turn, State),
    NewFanyanTurn = 
    case FanyanTurn of
        []->
            FanyanTurn;
        _->
            tl(FanyanTurn)
    end,
    NewState = maps:put(fayan_turn, NewFanyanTurn, State),
    NewState.
    
do_send_fayan(PlayerId, Chat, State) ->
    Player = lib_player:get_player(PlayerId),
    Send = #m__fight__speak__s2l{chat = mod_chat:get_p_chat(Chat, Player)},
    send_to_all_player(Send, State, [PlayerId]).

do_send_langren_team_fayan(PlayerId, Chat, SeatList, State) ->
    Player = lib_player:get_player(PlayerId),
    Send = #m__fight__langren_team_speak__s2l{chat = mod_chat:get_p_chat(Chat, Player)},
    [send_to_seat(Send, SeatId, State) || SeatId<--SeatList].

do_guipiao_op(State) ->
    LastOpData = get_last_op(State),
    GuiPiaoList = 
        case maps:to_list(LastOpData) of
            [] ->
                [];
            [{_, OpList}] ->
                OpList
        end,
    Send = #m__fight__guipiao__s2l{guipiao_list = GuiPiaoList},
    send_to_all_player(Send, State),
    clear_last_op(State).

do_toupiao_op(State) ->
    LastOpData = get_last_op(State),
    {IsDraw, ResultList, MaxSeatList} = count_xuanju_result(LastOpData),
    DrawCnt = maps:get(xuanju_draw_cnt, State),
    {DrawResult, NewState} = 
        case IsDraw of
            false ->
                {false, State#{xuanju_draw_cnt := 0,
                               quzhu := hd(MaxSeatList)}};
            true ->
                case DrawCnt > 0 of
                    true ->
                        {false, State#{xuanju_draw_cnt := 0,
                                       quzhu := 0}};
                    false ->
                        {true , State#{xuanju_draw_cnt := 1,
                                       quzhu := 0}}
                end
        end,
    {DrawResult, ResultList, MaxSeatList, NewState}.

do_toupiao_mvp_op(State) ->
    LastOpData = get_last_op(State),
    {IsDraw, ResultList, MaxSeatList} = count_xuanju_result(LastOpData),
    DrawCnt = maps:get(mvp_draw_cnt, State),
    {DrawResult, NewState} = 
        case IsDraw of
            false ->
                {false, State#{mvp_draw_cnt := 0,
                               mvp := hd(MaxSeatList)}};
            true ->
                case DrawCnt > 0 of
                    true ->
                        {false, State#{mvp_draw_cnt := 0,
                                       mvp := 0}};
                    false ->
                        {true , State#{mvp_draw_cnt := 1,
                                       mvp := 0}}
                end
        end,
    {DrawResult, ResultList, MaxSeatList, NewState}.


do_toupiao_carry_op(State) ->
    LastOpData = get_last_op(State),
    {IsDraw, ResultList, MaxSeatList} = count_xuanju_result(LastOpData),
    DrawCnt = maps:get(carry_draw_cnt, State),
    {DrawResult, NewState} = 
        case IsDraw of
            false ->
                {false, State#{carry_draw_cnt := 0,
                               carry := hd(MaxSeatList)}};
            true ->
                case DrawCnt > 0 of
                    true ->
                        {false, State#{carry_draw_cnt := 0,
                                       carry := 0}};
                    false ->
                        {true , State#{carry_draw_cnt := 1,
                                       carry := 0}}
                end
        end,
    {DrawResult, ResultList, MaxSeatList, NewState}.        

%%设置白痴死亡状态
check_set_baichi_die(DieSeat, State)->
    case (DieSeat =/= 0) andalso (maps:get(baichi, State) == DieSeat) of
        true->
            maps:put(baichi, 0, State);
        false->
            State
    end.

%%情侣一起死亡判定
lover_die_judge(SeatId, State)->
    case maps:get(lover, State) of
        [] ->
            State;
        [Lover1, Lover2] ->
            case SeatId == Lover1 of
                true->
                    do_skill(get_player_id_by_seat(Lover2, State), ?OP_SKILL_LOVER_DIE, [0], State);
                false->
                    State
            end,
            case SeatId == Lover2 of
                true->
                    do_skill(get_player_id_by_seat(Lover1, State), ?OP_SKILL_LOVER_DIE, [0], State);
                false->
                    State
            end
    end.

do_skill(PlayerId, Op, OpList, State) ->
    SeatId = get_seat_id_by_player_id(PlayerId, State),
    Send = #m__fight__notice_skill__s2l{seat_id = SeatId,
                                        op = Op,
                                        op_list = OpList},
    send_to_all_player(Send, State),
    do_skill_inner(SeatId, Op, OpList, State).
    
do_skill_inner(SeatId, ?OP_SKILL_BAICHI, _, State) ->
    SeatIdAfterBaichi = 
    case maps:get(baichi, State) =/= 0 of
        true->
            0;
        false->
            SeatId
    end,
    StateAfterFlop = 
    case SeatIdAfterBaichi =/= 0 of
        true->
            maps:put(flop_list, maps:get(flop_list, State) ++ [{SeatId, ?OP_SKILL_BAICHI}], State);
        false->
            lover_die_judge(SeatId, State)
    end,
    maps:put(baichi, SeatIdAfterBaichi, StateAfterFlop);

do_skill_inner(SeatId, ?OP_SKILL_LOVER_DIE, _, State) ->
    StateAfterDie = maps:put(die, maps:get(die, State) ++ [SeatId], State),
    StateAfterLover = 
    case SeatId == 0 of
        true->
            StateAfterDie;
        false->
            SkillDieListPre = maps:get(skill_die_list, State),
            StateAfterDieList = maps:put(skill_die_list, SkillDieListPre ++ [{?DIE_TYPE_LOVER, SeatId}] , StateAfterDie),
            maps:put(lover_kill, SeatId, StateAfterDieList)
    end,
    check_set_baichi_die(SeatId, StateAfterLover);

do_skill_inner(SeatId, ?OP_SKILL_LIEREN, [SelectSeat], State) ->
    StateAfterDie = maps:put(die, maps:get(die, State) ++ [SelectSeat], State),
    StateAfterLieRen = maps:put(lieren_kill, SelectSeat, StateAfterDie),
    StateAfterFlopLieRen = 
    case SelectSeat == 0 of
        true->
            StateAfterLieRen;
        false->
            SkillDieListPre = maps:get(skill_die_list, State),
            StateAfterSetFlop = maps:put(flop_lieren, 1, StateAfterLieRen),
            StateAfterDieList = maps:put(skill_die_list, SkillDieListPre ++ [{?DIE_TYPE_LIEREN, SelectSeat}] , StateAfterSetFlop),
            StateAfterSetFlopList = maps:put(flop_list, maps:get(flop_list, StateAfterDieList) ++ [{SeatId, ?OP_SKILL_LIEREN}], StateAfterDieList),
            lover_die_judge(SelectSeat, StateAfterSetFlopList)
    end,
    check_set_baichi_die(SelectSeat, StateAfterFlopLieRen);

do_skill_inner(SeatId, ?OP_SKILL_BAILANG, [SelectId], State) ->
    DieList = [SeatId, SelectId],
    DieListPre = maps:get(die, State),
    SkillDieListPre = maps:get(skill_die_list, State),
    NewState = 
    case lists:member(SelectId, DieListPre) of
        true ->
            State;
        false ->
            case SelectId =/= 0 of
                true->
                    StateAfterDieList = maps:put(skill_die_list,  SkillDieListPre ++ [{?DIE_TYPE_BAILANG, SelectId}], State),
                    lover_die_judge(SelectId, StateAfterDieList);
                false->
                    State
            end
    end,
    StateAfterBoom = 
    case is_seat_alive(SeatId, NewState) of
        true->
            StateAfterBoomDieList = maps:put(skill_die_list,  [{?DIE_TYPE_BOOM, SeatId}] ++ SkillDieListPre , NewState),
            StateAfterSetFlopList = maps:put(flop_list, maps:get(flop_list, StateAfterBoomDieList) ++ [{SeatId, ?OP_SKILL_BAILANG}], StateAfterBoomDieList),
            lover_die_judge(SeatId, StateAfterSetFlopList);
        false->
            NewState
    end,
    StateAfterDie = maps:put(die, maps:get(die, StateAfterBoom) ++ DieList, StateAfterBoom),
    StateAfterLangRenBoom = maps:put(langren_boom, 1, StateAfterDie),
    StateAtferBaiLangBoom = maps:put(bailang, SelectId, StateAfterLangRenBoom),
    check_set_baichi_die(SelectId, StateAtferBaiLangBoom);

do_skill_inner(SeatId, ?OP_SKILL_LANGREN, _, State) ->
    StateAfterDie = maps:put(die, maps:get(die, State) ++ [SeatId], State),
    StateAfterBoom = maps:put(langren_boom, 1, StateAfterDie),
    StateAfterSetFlopList = maps:put(flop_list, maps:get(flop_list, StateAfterBoom) ++ [{SeatId, ?OP_SKILL_LANGREN}], StateAfterBoom),
    lover_die_judge(SeatId, StateAfterSetFlopList);

do_skill_inner(_SeatId, ?OP_SKILL_CHANGE_JINGZHANG, [SelectId], State) ->
    maps:put(jingzhang, SelectId, State);

do_skill_inner(SeatId, ?OP_SKILL_EIXT_PART_JINGZHANG, [_SelectId], State) ->
    NewState = maps:put(exit_jingzhang, maps:get(exit_jingzhang, State) ++ [SeatId], State),
    StateAfterJingZhang = maps:put(part_jingzhang, maps:get(part_jingzhang, State) -- [SeatId], NewState),
    StateAfterFayanTurn = maps:put(fayan_turn, maps:get(fayan_turn, State) -- [SeatId], StateAfterJingZhang),
    StateAfterFayanTurn.

rand_in_alive_seat(State) ->
    util:rand_in_list(get_alive_seat_list(State)).


set_skill_die_list(StateName, State) ->
    SkillDieList =
        case StateName of
            state_night_result ->
                DieList = maps:get(die, State),
                case maps:get(nvwu, State) of
                    {NvWuKill, ?NVWU_DUYAO} ->
                        [{?DIE_TYPE_LANGRNE, SeatId} || SeatId <- (DieList -- [NvWuKill])];
                    _ ->
                        [{?DIE_TYPE_LANGRNE, SeatId} || SeatId <- DieList]
                end;
            state_toupiao ->
                case maps:get(quzhu, State) of
                    0 ->
                        [];
                    Quzhu ->
                        [{?DIE_TYPE_QUZHU, Quzhu}]
                end
        end,
    State#{pre_state_name => StateName,
           skill_die_list => SkillDieList}.

%%是否需要做默认技能延时(猎人未翻牌的情况下，避免猎人被发现)
%%平安夜或者猎人翻牌不做延时直接跳过
is_need_someone_die_default_delay(State)->
    LieRenExist = is_duty_exist(?DUTY_LIEREN, State),
    FlopLieRen = maps:get(flop_lieren, State),
    SafeNight = maps:get(safe_night, State),
    QuzhuOp = maps:get(quzhu_op, State),
    Quzhu = maps:get(quzhu, State),
    BaiLang = maps:get(bailang, State),
    SkillDDelay = maps:get(skill_d_delay, State),
    LieRenExist andalso (FlopLieRen == 0) andalso (SkillDDelay == 0) andalso (BaiLang == 0) andalso 
                (((QuzhuOp == 0) andalso (SafeNight =/= 1)) orelse ((QuzhuOp == 1) andalso (Quzhu =/= 0))).



get_someone_die_op(State)->
    SkillDieList = maps:get(skill_die_list, State),
    StateAfterDelay = 
    case SkillDieList of
        []->
            State;
        _->
            maps:put(skill_d_delay, 0, State)
    end,
    try
        case SkillDieList of
            [] ->
                %%如果有人死并且没有发动技能并且猎人没有翻牌做默认延时
                case is_need_someone_die_default_delay(StateAfterDelay) of
                    true->
                        throw(d_delay);
                    false->
                        throw(skip)
                end;
            _ ->
                ok
        end,
        {DieType, Die} = hd(SkillDieList),
        %%白狼自爆发动技能
        DoBaiLang = (DieType == ?DIE_TYPE_BOOM),
        case DoBaiLang of
            true->
                throw(?OP_SKILL_BAILANG);
            false->
                ignore
        end,
        
        JingZhang = maps:get(jingzhang, StateAfterDelay),
        case (JingZhang =/= 0) andalso (not is_seat_alive(JingZhang, StateAfterDelay)) of
            true ->
                throw(?OP_SKILL_CHANGE_JINGZHANG);
            false ->
                ignore
        end,
        case Die =/= 0 of
            true->
                Duty = lib_fight:get_duty_by_seat(Die, StateAfterDelay),
                DoLieren = (Duty == ?DUTY_LIEREN andalso DieType =/= ?DIE_TYPE_NVWU),
                case DoLieren of
                    true ->
                        throw(?OP_SKILL_LIEREN);
                    false ->
                        ignore
                end;
            false->
                ignore
        end,
        %%猎人已经出局直接跳过
        FlopLieRen = maps:get(flop_lieren, StateAfterDelay),
        case FlopLieRen == 1 of
            true->
                throw(skip);
            false->
                ignore
        end,

        throw(ignore)

    catch
        throw:ignore ->
            % send_event_inner(op_over),
            %  {next_state, state_someone_die, StateAfterDelay};
            {op_over, ?OP_SKILL_D_DELAY, StateAfterDelay};
        throw:d_delay ->
            {d_delay, ?OP_SKILL_D_DELAY,StateAfterDelay};
        throw:skip ->
            {skip, ?OP_SKILL_D_DELAY, StateAfterDelay};
        throw:Op ->
            % start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(Op)),
            % {_DieType, OpSeat} = hd(SkillDieList),
            % notice_player_op(Op, [OpSeat], StateAfterDelay),
            % {next_state, state_someone_die, maps:put(cur_skill, Op, StateAfterDelay)}
            {do_op, Op, StateAfterDelay}
    end.

%%%====================================================================
%%% Internal functions
%%%====================================================================

init_seat(PlayerList, State) ->
    FunInitSeat = 
        fun(PlayerId, {CurIndex, CurSeatMap, CurPlayerMap}) ->
                {CurIndex + 1, maps:put(CurIndex, PlayerId, CurSeatMap), 
                               maps:put(PlayerId, CurIndex, CurPlayerMap)}
        end,
    {_, SeatPlayerMap, PlayerSeatMap} = lists:foldl(FunInitSeat, {1, #{}, #{}}, PlayerList),
    State#{seat_player_map := SeatPlayerMap,
           player_seat_map := PlayerSeatMap}.

init_duty(PlayerList, DutyList, State) ->
    PlayerNum = length(PlayerList),
    RandSeatList = util:rand_list(lists:seq(1, PlayerNum)),
    
    {BDutyList, DaozeiList} = get_duty_list_with_daozei(DutyList),
    SeatDutyList = lists:zip(RandSeatList, BDutyList),

    FunInitDuty =
        fun({SeatId, DutyId}, {CurDutySeatMap, CurSeatDutyMap}) ->
            NewDutySeatList = maps:get(DutyId, CurDutySeatMap, []) ++ [SeatId],
            {maps:put(DutyId, NewDutySeatList, CurDutySeatMap),
             maps:put(SeatId, DutyId, CurSeatDutyMap)}
        end,
    {DutySeatMap, SeatDutyMap} = lists:foldl(FunInitDuty, {#{}, #{}}, SeatDutyList),
    State#{seat_duty_map := SeatDutyMap,
           duty_seat_map := DutySeatMap,
           daozei := DaozeiList}.

get_duty_list_with_daozei(DutyList) ->
    case lists:member(?DUTY_DAOZEI, DutyList) of
        true ->
            generate_daozei_duty_list(DutyList ++ [?DUTY_PINGMIN,?DUTY_PINGMIN]);
        false ->
            {DutyList, []}
    end.

generate_daozei_duty_list(DutyIdList) ->
    generate_daozei_duty_list(DutyIdList, []).

generate_daozei_duty_list(DutyIdList, []) ->
    generate_daozei_duty_list(DutyIdList, util:rand_in_list(DutyIdList, 2));

generate_daozei_duty_list(DutyIdList, [?DUTY_LANGREN, ?DUTY_LANGREN]) ->
    generate_daozei_duty_list(DutyIdList, util:rand_in_list(DutyIdList, 2));    

generate_daozei_duty_list(DutyIdList, [?DUTY_BAILANG, ?DUTY_LANGREN]) ->
    generate_daozei_duty_list(DutyIdList, util:rand_in_list(DutyIdList, 2)); 

generate_daozei_duty_list(DutyIdList, [?DUTY_LANGREN, ?DUTY_BAILANG]) ->
    generate_daozei_duty_list(DutyIdList, util:rand_in_list(DutyIdList, 2)); 

generate_daozei_duty_list(DutyIdList, RandList) ->
    % FunCheckSpecial = 
    %     fun(Duty) ->
    %         lists:member(Duty, ?DUTY_LIST_SPECIAL)
    %     end,
    % case lists:any(FunCheckSpecial, RandList) of
    case lists:member(?DUTY_DAOZEI, RandList) of
        true ->
            generate_daozei_duty_list(DutyIdList, util:rand_in_list(DutyIdList, 2));
        false ->
            {DutyIdList -- RandList, RandList}
    end.
     
get_last_op(State) ->
    maps:get(last_op_data, State).

filter_last_op(OpMap) ->
    FunRemove = 
        fun(Key, CurMap) ->
            case maps:get(Key, CurMap) of
                [0] ->
                    maps:remove(Key, CurMap);
                _ ->
                    CurMap
            end
        end,
    lists:foldl(FunRemove, OpMap, maps:keys(OpMap)).

clear_last_op(State) ->
    maps:put(last_op_data, #{}, State).

rand_target_in_op(OpData) ->
    FunCout = 
        fun({_, [SeatId]}, CurList) ->
            case lists:keyfind(SeatId, 1, CurList) of
                {_, SelectNum} ->
                    lists:keyreplace(SeatId, 1, CurList, {SeatId, SelectNum + 1});
                false ->
                    [{SeatId, 1}] ++ CurList
            end
        end,
    CountSelectList = lists:foldl(FunCout, [], maps:to_list(OpData)),
    SeatListAfterKeysort = lists:keysort(2, CountSelectList),
    case SeatListAfterKeysort of
        []->
            0;
        _->
            {_, MaxSelectNum} = lists:last(SeatListAfterKeysort),
            RandSeatList = [CurSeatId || {CurSeatId, CurSelectNum} <- CountSelectList, CurSelectNum == MaxSelectNum],
            case RandSeatList of
                [] ->
                    0;
                _ ->
                    util:rand_in_list(RandSeatList)
            end
    end.

notice_lover(Seat1, Seat2, QiubiteSeat, State) ->
    Send = #m__fight__notice_lover__s2l{lover_list = [Seat1, Seat2]},
    send_to_seat(Send, Seat1, State),    
    send_to_seat(Send, Seat2, State),
    send_to_seat(Send, QiubiteSeat, State).
    
count_xuanju_result(OpData) ->
    FunCout = 
        fun({SelectSeat, [SeatId]}, CurList) ->
            case lists:keyfind(SeatId, 1, CurList) of
                {_, CurSelectSeat, SelectNum} ->
                    lists:keyreplace(SeatId, 1, CurList, {SeatId, CurSelectSeat ++ [SelectSeat], SelectNum + 1});
                false ->
                    [{SeatId, [SelectSeat], 1}] ++ CurList
            end
        end,
    CountSelectList = lists:foldl(FunCout, [], maps:to_list(filter_last_op(OpData))),
    case CountSelectList of
        [] ->
            {false, [], [0]};
        _ ->
            {_, _, MaxSelectNum} = lists:last(lists:keysort(3, CountSelectList)),
            MaxSeatList = [CurSeatId || {CurSeatId, _, CurSelectNum} <- CountSelectList, CurSelectNum == MaxSelectNum],
            IsDraw = length(MaxSeatList) > 1,
            {IsDraw, [{CurSeatId, CurSelectSeat} || {CurSeatId, CurSelectSeat, _} <- CountSelectList], MaxSeatList}
    end.

%%根据魅力值高低选择一个目标(魅力值一样者随机)
get_max_luck_seat(SeatList, State)->
    case SeatList of
        [] ->
            undefined;
        _ ->
            PlayerIdList = [get_player_id_by_seat(SeatId, State) || SeatId <- SeatList],
            PlayerLuckList = [{PlayerId, mod_resource:get_num(?RESOURCE_LUCK, PlayerId)} || PlayerId <- PlayerIdList],
            MaxLuck = lists:reverse(lists:keysort(2, PlayerLuckList)),
            MaxLuckPlayerList = [PlayerId || {PlayerId, Luck} <- PlayerLuckList, Luck == MaxLuck],
            util:rand_in_list(MaxLuckPlayerList)
    end.

generate_fayan_turn(SeatId, _First, Turn, State) ->
    AllSeat = get_all_seat(State),
    Part = 
        case maps:get(die, State) of
            [] ->
                SeatId;
            [Die] ->
                Die;
            _ ->
                SeatId
        end,
    InitTurnList = 
        case Turn of
            ?TURN_DOWN ->
                lists:sort(AllSeat);
            _ ->
                lists:reverse(lists:sort(AllSeat))
        end,
    {PreList, TailList} = util:part_list(Part, InitTurnList),
    TurnList = ([Part] ++ TailList ++ PreList) -- [Part],
    ((TurnList -- maps:get(die, State)) -- maps:get(out_seat_list, State)) -- [0].

do_set_die_list(State) ->
    {NvwuSelect, NvwuOp} = maps:get(nvwu, State),
    LangrenKill = maps:get(langren, State),
    ShowWeiDef = maps:get(shouwei, State),
    KillList = 
        case NvwuOp of
            ?NVWU_DUYAO ->
                [LangrenKill, NvwuSelect];
            _ ->
                [LangrenKill]
        end,
    SaveList = 
        case NvwuOp of
            ?NVWU_JIEYAO ->
                [ShowWeiDef, NvwuSelect];
            ?NVWU_DUYAO ->
                case NvwuSelect == ShowWeiDef of
                    true ->
                        [];
                    false ->
                        [ShowWeiDef]
                end;
            _ ->
                [ShowWeiDef]
        end,
    DieList = [Die || Die <- (KillList -- SaveList), Die =/= 0],

    DieAfterLover = 
        case maps:get(lover, State) of
            [] ->
                DieList;
            [Lover1, Lover2] ->
                case lists:member(Lover1, DieList) orelse lists:member(Lover2, DieList) of
                    true ->
                        DieList ++ maps:get(lover, State);
                    false ->
                        DieList
                end
        end,
    StateAfterSafeDay = 
    case length(DieAfterLover) > 0 of
        true->
            maps:put(safe_night, 0, State);
        false->
            State
    end,
    BaiChi = maps:get(baichi, StateAfterSafeDay),
    StateAfterBaichi = 
    case BaiChi =/= 0 andalso lists:member(BaiChi,DieAfterLover) of
        true->
            maps:put(baichi, StateAfterSafeDay);
        false->
            StateAfterSafeDay
    end,
    maps:put(die, lists:usort(DieAfterLover), StateAfterBaichi).

