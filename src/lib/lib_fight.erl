%% @author zhangkl
%% @doc lib_fight.
%% 2016

-module(lib_fight).
-export([init/3,
         send_to_all_player/2,
         send_to_seat/3,
         get_player_id_by_seat/2,
         get_seat_id_by_player_id/2,
         get_duty_by_seat/2,
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
         do_fayan_op/1,
         do_toupiao_op/1]).

-include("fight.hrl").
-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

init(RoomId, PlayerList, State) ->
    State1 = State#{room_id := RoomId},
    State2 = init_seat(PlayerList, State1),
    State3 = init_duty(PlayerList, State2),
    State3.

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
    StateAfterDuty = update_duty(SeatId, ?DUTY_DAOZEI, Duty, State),
    clear_last_op(StateAfterDuty).

do_qiubite_op(State) ->
    LastOpData = get_last_op(State),
    [{_SeatId, [Seat1, Seat2]}] = maps:to_list(LastOpData),
    StateAfterLover = maps:put(lover, [Seat1, Seat2], State),
    notice_lover(Seat1, Seat2, State),
    clear_last_op(StateAfterLover).

do_shouwei_op(State) ->
    LastOpData = get_last_op(State),
    [{_, [SeatId]}] = maps:to_list(LastOpData),
    StateAfterShouWei = maps:put(shouwei, SeatId, State),
    clear_last_op(StateAfterShouWei).

do_hunxuer_op(State) ->
    LastOpData = get_last_op(State),
    [{_, [SelectSeatId]}] = maps:to_list(LastOpData),
    SelectDuty = lib_fight:get_duty_by_seat(SelectSeatId, State),
    HunxueerOp =
        case SelectDuty of
            ?DUTY_LANGREN ->
                1;
            _ ->
                0
        end,                
    StateAfterHunxueer = maps:put(hunxuer, HunxueerOp, State),
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
    KillSeat = rand_target_in_op(LastOpData),
    StateAfterLangren = maps:put(langren, KillSeat, State),

    clear_last_op(StateAfterLangren). 

do_yuyanjia_op(State) ->
    LastOpData = get_last_op(State),
    [{SeatId, [SelectSeatId]}] = maps:to_list(LastOpData),
    SelectDuty = lib_fight:get_duty_by_seat(SelectSeatId, State),
    
    Send = #m__fight__notice_yuyanjia_result__s2l{seat_id = SelectSeatId,
                                                  duty = SelectDuty},
    send_to_seat(Send, SeatId, State),
    clear_last_op(State).

do_part_jingzhang_op(State) ->
    LastOpData = get_last_op(State),
    PartList = maps:keys(LastOpData),
    clear_last_op(maps:put(part_jingzhang, PartList, State)).

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
                        {fasle, State#{xuanju_draw_cnt := 0,
                                       jingzhang := 0}};
                    false ->
                        {true , State#{xuanju_draw_cnt := 1,
                                       jingzhang := 0}}
                end
        end,

    {DrawResult, ResultList, clear_last_op(NewState)}.

do_jingzhang_op(State) ->
    LastOpData = get_last_op(State),
    [{SeatId, [IsFirst, Turn]}] = maps:to_list(LastOpData),
    StateAfterJingzhang = maps:put(jingzhang_op, {IsFirst, Turn}, State),
    FayanTrun = generate_fayan_turn(SeatId, IsFirst, Turn, State),
    StateAfterFayanTurn = maps:put(fayan_turn, FayanTrun, StateAfterJingzhang),
    clear_last_op(StateAfterFayanTurn).

do_fayan_op(State) ->
    FanyanTurn = maps:get(fayan_turn, State),
    NewFanyanTurn = tl(FanyanTurn),
    NewState = maps:put(fayan_turn, NewFanyanTurn, State),
    clear_last_op(NewState).

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
                        {fasle, State#{xuanju_draw_cnt := 0,
                                       quzhu := 0}};
                    false ->
                        {true , State#{xuanju_draw_cnt := 1,
                                       quzhu := 0}}
                end
        end,
    {DrawResult, ResultList, MaxSeatList, NewState}.

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

init_duty(PlayerList, State) ->
    PlayerNum = length(PlayerList),
    RandSeatList = util:rand_list(lists:seq(1, PlayerNum)),
    
    {BDutyList, DaozeiList} = get_duty_list_with_daozei(PlayerNum),
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

get_duty_list_with_daozei(PlayerNum) ->
    BDutyList = b_duty:get(PlayerNum),
    FunInitDutyConfig = 
        fun({CurDuty, Num}, CurList) ->
                lists:duplicate(Num, CurDuty) ++ CurList
        end,
    DutyIdList = lists:foldl(FunInitDutyConfig, [], BDutyList),
    case lists:member(?DUTY_DAOZEI, DutyIdList) of
        true ->
            generate_daozei_duty_list(DutyIdList);
        false ->
            {DutyIdList, []}
    end.

generate_daozei_duty_list(DutyIdList) ->
    generate_daozei_duty_list(DutyIdList, []).

generate_daozei_duty_list(DutyIdList, []) ->
    generate_daozei_duty_list(DutyIdList, util:rand_in_list(DutyIdList, 2));

generate_daozei_duty_list(DutyIdList, [?DUTY_LANGREN, ?DUTY_LANGREN]) ->
    generate_daozei_duty_list(DutyIdList, util:rand_in_list(DutyIdList, 2));    

generate_daozei_duty_list(DutyIdList, RandList) ->
    FunCheckSpecial = 
        fun(Duty) ->
            lists:member(Duty, ?DUTY_LIST_SPECIAL)
        end,
    case lists:any(FunCheckSpecial, RandList) of
        true ->
            generate_daozei_duty_list(DutyIdList, util:rand_in_list(DutyIdList, 2));
        false ->
            {DutyIdList -- RandList, RandList}
    end.
     
get_last_op(State) ->
    maps:get(last_op_data, State).

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
    util:rand_in_list(RandSeatList).

notice_lover(Seat1, Seat2, State) ->
    Send = #m__fight__notice_lover__s2l{lover_list = [Seat1, Seat2]},
    send_to_seat(Send, Seat1, State),    
    send_to_seat(Send, Seat2, State).
    
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
    CountSelectList = lists:foldl(FunCout, [], maps:to_list(OpData)),
    case CountSelectList of
        [] ->
            {false, [], [0]};
        _ ->
            {_, _, MaxSelectNum} = lists:last(lists:keysort(3, CountSelectList)),
            MaxSeatList = [CurSeatId || {CurSeatId, _, CurSelectNum} <- CountSelectList, CurSelectNum == MaxSelectNum],
            IsDraw = length(MaxSeatList) > 1,
            {IsDraw, [{CurSeatId, CurSelectSeat} || {CurSeatId, CurSelectSeat, _} <- CountSelectList], MaxSeatList}
    end.

generate_fayan_turn(SeatId, IsFirst, Turn, State) ->
    AliveList = get_alive_seat_list(State),
    Die = 
        case maps:get(die, State) of
            [] ->
                maps:get(langren, State);
            DieList ->
                hd(DieList)
        end,
    InitTrunList = 
        case Turn of
            ?TURN_DOWN ->
                lists:sort(AliveList);
            _ ->
                list:reverse(lits:sort(AliveList))
        end,
    {PreList, TailList} = util:part_list(Die, InitTrunList),
    TurnList = TailList ++ PreList,
    case IsFirst of
        true ->
            [SeatId] ++ (TurnList -- [SeatId]);
        false ->
            TurnList
    end.

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
            _ ->
                [ShowWeiDef]
        end,
    DieList = KillList -- SaveList,
    maps:put(die, DieList, State).




