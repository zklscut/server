%% @author zhangkl
%% @doc lib_fight.
%% 2016

-module(lib_fight).
-export([init/4,
         send_to_all_player/2,
         send_to_seat/3,
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
         do_guipiao_op/1,
         do_toupiao_op/1,
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
         do_part_jingzhang_op_twice/1,
         do_exit_part/3,
         do_bailang_boom/3,
         do_bailang_kill_op/1,
         do_change_jingzhang_op/1,
         do_skill/4]).

-include("fight.hrl").
-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

init(RoomId, PlayerList, DutyList, State) ->
    State1 = State#{room_id := RoomId},
    State2 = init_seat(PlayerList, State1),
    State3 = init_duty(PlayerList, DutyList, State2),
    State3#{player_num := length(DutyList)}.

send_to_all_player(Send, State) ->
    [net_send:send(Send, PlayerId) || PlayerId <- maps:keys(maps:get(player_seat_map, State))].

send_to_seat(Send, SeatId, State) ->
    net_send:send(Send, get_player_id_by_seat(SeatId, State)).

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
            Alivelist = get_alive_seat_list(State),
            lists:member(SeatId, Alivelist)
    end.

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
    lager:info("is_third_part_win1 "),
    case enable_third_part_qiubite(State) of
        true->
            case ThirdPartListLen == 3 of
                true ->
                    case Alivelen =< 3 of
                        true ->
                            lager:info("is_third_part_win2 "),
                            lists:all(fun(SeatId)-> lists:member(SeatId, ThirdPartList) end, Alivelist);
                        false ->
                            lager:info("is_third_part_win3 "),
                            false
                    end;
                false ->
                    lager:info("is_third_part_win4 "),
                    false
            end;
        false->
            lager:info("is_third_part_win5 "),
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
    LangRenList = [?DUTY_LANGREN, ?DUTY_BAILANG],
    HunxuerDuty = get_duty_by_seat(Hunxuer, State),
    case lists:member(HunxuerDuty, LangRenList) of
        true->
            [Hunxuer];
        false->
            []
    end.

get_haoren_hunxuer_seat(State)->
    Hunxuer = maps:get(hunxuer, State),
    LangRenList = [?DUTY_LANGREN, ?DUTY_BAILANG],
    HunxuerDuty = get_duty_by_seat(Hunxuer, State),
    case lists:member(HunxuerDuty, LangRenList) of
        true->
            [];
        false->
            [Hunxuer]
    end.

%是否可作为第三方丘比特
enable_third_part_qiubite(State)->
    lager:info("enable_third_part_qiubite1 "),
    case is_duty_exist(?DUTY_QIUBITE, State) of
        true->
            lager:info("enable_third_part_qiubite2 "),
            LangRenList = [?DUTY_LANGREN, ?DUTY_BAILANG],
            [Lover1, Lover2] = maps:get(lover, State),
            LoverDuty1 = get_duty_by_seat(Lover1, State),
            LoverDuty2 = get_duty_by_seat(Lover2, State),
            case lists:member(LoverDuty1, LangRenList) andalso lists:member(LoverDuty2, LangRenList) of
                true->
                    lager:info("enable_third_part_qiubite3 "),
                    false;
                false->
                    case lists:member(LoverDuty1, LangRenList) orelse lists:member(LoverDuty2, LangRenList) of
                        true->
                            lager:info("enable_third_part_qiubite4 "),
                            true;
                        false->
                            lager:info("enable_third_part_qiubite5 "),
                            false
                    end
            end;
        false->
            lager:info("enable_third_part_qiubite6 "),
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
    [{_, [SeatId]}] = maps:to_list(LastOpData),
    StateAfterShouWei = maps:put(shouwei, SeatId, State),
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
    clear_last_op(StateAfterUpdateDie).        

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
    clear_last_op(StateAfterUpdateDie). 

do_bailang_kill_op(State)->
    [BaiLang] = fight_lib:get_duty_seat(?DUTY_BAILANG, State),
    LastOpData = get_last_op(State),
    KillSeat = 
        case maps:to_list(LastOpData) of
            [] ->
                0;
            _ ->
                rand_target_in_op(filter_last_op(LastOpData))
        end,  
    Send = #m__fight__notice_skill__s2l{seat_id = BaiLang,
                                op = ?OP_BAILANG_KILL,
                                op_list = [KillSeat]},
    send_to_all_player(Send, State),
    NewState = maps:put(bailang, KillSeat, State),
    NewState1 = do_set_die_list(NewState),
    clear_last_op(NewState1).

do_change_jingzhang_op(State)
    LastOpData = get_last_op(State),
    PreJingZhang = maps:get(jingzhang, State),
    SeatId = 
        case maps:to_list(LastOpData) of
            [] ->
                0;
            _ ->
                rand_target_in_op(filter_last_op(LastOpData))
        end,
    NewState = maps:put(jingzhang, SeatId, State),
    Send = #m__fight__notice_skill__s2l{seat_id = PreJingZhang,
                                        op = ?OP_CHANGE_JINGZHANG,
                                        op_list = [SeatId]},
    send_to_all_player(Send, State),
    clear_last_op(NewState).

do_yuyanjia_op(State) ->
    LastOpData = get_last_op(State),
    case maps:to_list(LastOpData) of
        [] ->
            clear_last_op(State);
        [{SeatId, [SelectSeatId]}]  ->
            case SelectSeatId == 0 of
                true ->
                    ignore;
                false ->    
                    SelectDuty = lib_fight:get_duty_by_seat(SelectSeatId, State),
            
                    Send = #m__fight__notice_yuyanjia_result__s2l{seat_id = SelectSeatId,
                                                                  duty = SelectDuty},
                    send_to_seat(Send, SeatId, State)
            end,
            clear_last_op(State)
    end.

do_part_jingzhang_op(State) ->
    LastOpData = get_last_op(State),
    PartList = maps:keys(filter_last_op(LastOpData)),
    StateAfterFayan = maps:put(fayan_turn, PartList, State),
    Send = #m__fight__notice_part_jingzhang__s2l{seat_list = PartList},
    send_to_all_player(Send, State),
    clear_last_op(maps:put(part_jingzhang, PartList, StateAfterFayan)).

do_part_jingzhang_op_twice(State) ->
    PartJingZhang = maps:get(part_jingzhang, State),
    StateNew = maps:put(fayan_turn, PartJingZhang, State),
    Send = #m__fight__notice_part_jingzhang__s2l{seat_list = PartJingZhang},
    send_to_all_player(Send, State),
    clear_last_op(StateNew).

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
    NewFanyanTurn = tl(FanyanTurn),
    NewState = maps:put(fayan_turn, NewFanyanTurn, State),
    clear_last_op(NewState).
    
do_send_fayan(PlayerId, Chat, State) ->
    Player = lib_player:get_player(PlayerId),
    Send = #m__fight__speak__s2l{chat = mod_chat:get_p_chat(Chat, Player)},
    send_to_all_player(Send, State).

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

do_exit_part(PlayerId, OpList, State)->
    SeatId = get_seat_id_by_player_id(PlayerId, State),
    Send = #m__fight__notice_skill__s2l{seat_id = SeatId,
                                        op = ?OP_EXIT_PART_JINGZHANG,
                                        op_list = OpList},
    send_to_all_player(Send, State).


do_skill(PlayerId, Op, OpList, State) ->
    SeatId = get_seat_id_by_player_id(PlayerId, State),
    Send = #m__fight__notice_skill__s2l{seat_id = SeatId,
                                        op = Op,
                                        op_list = OpList},
    send_to_all_player(Send, State),
    do_skill_inner(SeatId, Op, OpList, State).
    
do_skill_inner(SeatId, ?DUTY_BAICHI, _, State) ->
    maps:put(baichi, SeatId, State);

do_skill_inner(_SeatId, ?DUTY_LIEREN, [SelectSeat], State) ->
    StateAfterDie = maps:put(die, maps:get(die, State) ++ [SelectSeat], State),
    StateAfterLieRen = maps:put(lieren_kill, SelectSeat, StateAfterDie),
    StateAfterLieRen;

do_skill_inner(SeatId, ?DUTY_BAILANG, [SelectSeat], State) ->
    DieList = [SeatId],
    maps:put(die, maps:get(die, State) ++ DieList, State);

do_skill_inner(SeatId, ?DUTY_LANGREN, _, State) ->
    maps:put(die, maps:get(die, State) ++ [SeatId], State);

do_skill_inner(_SeatId, ?OP_CHANGE_JINGZHANG, [SelectId], State) ->
    maps:put(jingzhang, SelectId, State).

do_bailang_boom(PlayerId, ?DUTY_BAILANG, State) ->
    SeatId = get_seat_id_by_player_id(PlayerId, State),
    NewState = maps:put(die, maps:get(die, State) ++ [SeatId], State),
    maps:put(bailang, SeatId, NewState).

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
    {_, MaxSelectNum} = lists:last(lists:keysort(2, CountSelectList)),
    RandSeatList = [CurSeatId || {CurSeatId, CurSelectNum} <- CountSelectList, CurSelectNum == MaxSelectNum],
    case RandSeatList of
        [] ->
            0;
        _ ->
            util:rand_in_list(RandSeatList)
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
    %情侣需要一起阵亡
    Lover = maps:get(lover, State),
    LoverLen = length(Lover),
    DieList2 = 
        case LoverLen == 2 of
            true ->
                [Lover1,Lover2] = Lover,
                case lists:member(Lover1, DieList) orelse lists:member(Lover2, DieList) of
                    true ->
                        DieList1 = 
                        case lists:member(Lover1, DieList) of
                            true ->
                                DieList;
                            false ->
                                DieList ++ [Lover1]
                        end,
                        case lists:member(Lover2, DieList1) of
                            true ->
                                DieList1;
                            false ->
                                DieList1 ++ [Lover2]
                        end;
                    false ->
                        DieList
                end;
            false ->
                DieList
        end,
    BaiLangKill = [maps:get(bailang, State)],
    DieList3 = BaiLangKill ++ DieList2,
    DieList4 = [DieList3 || DieList3 <- (KillList -- SaveList), DieList3 =/= 0],
    %%todo:去重
    maps:put(die, DieList2, State).
