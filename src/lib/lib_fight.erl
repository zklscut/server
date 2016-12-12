%% @author zhangkl
%% @doc lib_fight.
%% 2016

-module(lib_fight).
-export([init/3]).

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
    FunInitDutyConfig = 
        fun({CurDuty, Num}, CurList) ->
                lists:duplicate(Num, CurDuty) ++ CurList
        end,
    BDutyList = lists:foldl(FunInitDutyConfig, [], b_duty:get(PlayerNum)),
    SeatDutyList = lists:zip(RandSeatList, BDutyList),

    FunInitDuty =
        fun({SeatId, DutyId}, {CurDutySeatMap, CurSeatDutyMap}) ->
            NewDutySeatList = maps:get(DutyId, CurDutySeatMap, []) ++ [SeatId],
            {maps:put(DutyId, NewDutySeatList, CurDutySeatMap),
             maps:put(SeatId, DutyId, CurSeatDutyMap)}
        end,
    {DutySeatMap, SeatDutyMap} = lists:foldl(FunInitDuty, {#{}, #{}}, SeatDutyList),
    State#{seat_duty_map := SeatDutyMap,
           duty_seat_map := DutySeatMap}.
