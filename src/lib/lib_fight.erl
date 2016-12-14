%% @author zhangkl
%% @doc lib_fight.
%% 2016

-module(lib_fight).
-export([init/3,
         init_special_night/1,
         send_to_all_player/2,
         send_to_seat/3,
         get_player_id_by_seat/2,
         get_seat_id_by_player_id/2,
         get_duty_by_seat/2,
         update_duty/4,
         get_duty_seat/2,
         do_daozei_op/1,
         do_qiubite_op/1,
         do_hunxuer_op/1,
         do_shouwei_op/1,
         do_langren_op/1,
         do_nvwu_op/1,
         do_yuyanjia_op/1]).

-include("fight.hrl").

% -define(MFIGHT, #{room_id => 0,
%                   seat_player_map => #{},%% #{seat_id, player_id}
%                   offline_list => [],   %% seat_id
%                   out_player_list => [],%% 出局列表 seat_id
%                   seat_duty_map => #{}, %% #{seat_id, 职责}
%                   duty_seat_map => #{}, %% #{duty_id, [seat_id]}
%                   left_op_list => [],   %% 剩余操作seat_id 按照顺序排好
%                   op => 0,              %% 当前进行的操作
%                   game_state =>  0,     %% 第几天晚上
%                   game_round =>  1,     %% 第几轮
%                   last_op_data => #{}   %% 上一轮操作的数据, 杀了几号, 投了几号等等
%                   }).

%% ====================================================================
%% API functions
%% ====================================================================

init(RoomId, PlayerList, State) ->
    State1 = State#{room_id := RoomId},
    State2 = init_seat(PlayerList, State1),
    State3 = init_duty(PlayerList, State2),
    State3.

init_special_night(State) ->
    %%TODO sort by pre
    LeftOpList = [SeatId || {SeatId, DutyId} <- maps:to_list(maps:get(seat_duty_map, State)),
                    lists:member(DutyId, ?DUTY_LIST_SPECIAL)],
    maps:put(left_op_list, LeftOpList, State).


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

get_duty_seat(Duty, State) ->
    DutySeatMap = maps:get(duty_seat_map, State),
    maps:get(Duty, DutySeatMap, []).

update_duty(SeatId, PreDuty, Duty, State) ->
    NewSeatDutyMap = maps:put(SeatId, Duty, maps:get(seat_duty_map, State)),
    DutySeatMap = maps:get(duty_seat_map, State),
    NewPreDutySeatList = maps:get(PreDuty, DutySeatMap) -- [SeatId],
    NewNewDutySeatList = maps:get(Duty, DutySeatMap, []) ++ [SeatId],
    NewDutySeatMap = DutySeatMap#{PreDuty := NewPreDutySeatList,
                                  Duty := NewNewDutySeatList},
    State#{duty_seat_map := NewDutySeatMap,
           seat_duty_map := NewSeatDutyMap}.                                  

do_daozei_op(State) ->
    LastOpData = get_last_op(State),
    [{SeatId, [Duty]}] = maps:to_list(LastOpData),
    StateAfterDuty = update_duty(SeatId, ?DUTY_DAOZEI, Duty, State),
    clear_last_op(StateAfterDuty).

do_qiubite_op(State) ->
    LastOpData = get_last_op(State),
    [{SeatId, [Seat1, Seat2]}] = maps:to_list(LastOpData),
    StateAfterLover = maps:put(lover, [Seat1, Seat2], State),
    Duty1 = lib_fight:get_duty_by_seat(Seat1, State),
    Duty2 = lib_fight:get_duty_by_seat(Seat2, State),
    NewDuty = 
        case Duty1 == Duty2 of
            true ->
                Duty1;
            false ->
                ?DUTY_NONE
        end,
    StateAfterDuty = update_duty(SeatId, ?DUTY_QIUBITE, NewDuty, StateAfterLover),
    clear_last_op(StateAfterDuty).

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
    %%TODO notice hunxuer result
    clear_last_op(StateAfterHunxueer).

do_nvwu_op(State) ->
    LastOpData = get_last_op(State),
    [{_, [SelectSeatId, IsUseDuYao]}] = maps:to_list(LastOpData),
    StateAfterNvwu = 
        case SelectSeatId of
            0 ->
                State;
            _ ->
                maps:put(nvwu, {SelectSeatId, IsUseDuYao}, State)
        end,
    clear_last_op(StateAfterNvwu).        

do_langren_op(State) ->
    LastOpData = get_last_op(State),
    KillSeat = rand_target_in_op(LastOpData),
    StateAfterLangren = maps:put(langren, KillSeat, State),
    clear_last_op(StateAfterLangren). 

do_yuyanjia_op(State) ->
    LastOpData = get_last_op(State),
    [{_SeatId, [SelectSeatId]}] = maps:to_list(LastOpData),
    _SelectDuty = lib_fight:get_duty_by_seat(SelectSeatId, State),
    %%notice player select duty
    clear_last_op(State).

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
