%% @author zhangkl
%% @doc lib_fight.
%% 2016

-module(lib_fight).
-export([]).

-include("fight.hrl").

% -define(MFIGHT, #{room_id => 0,
%                   seat_player_map => [],    %% #{seat_id, player_id}
%                   offline_list => [],   %% seat_id
%                   out_player_list => [],%% 出局列表 seat_id
%                   duty_list => [],      %% #{seat_id, 职责}
%                   left_op_list => [],   %% 剩余操作seat_id 按照顺序排好
%                   op => 0,              %% 当前进行的操作
%                   last_op_data => #{}   %% 上一轮操作的数据, 杀了几号, 投了几号等等
%                   }).

%% ====================================================================
%% API functions
%% ====================================================================

init(RoomId, PlayerList, State) ->
    State1 = State#{room_id := RoomId},
    State2 = init_seat(PlayerList, State1),
    ok.

init_seat(PlayerList, State) ->
    FunInitSeat = 
        fun(PlayerId, {CurIndex, CurSeatMap}) ->
                {CurIndex + 1, maps:put(CurIndex, PlayerId, CurSeatMap)}
        end,
    {_, SeatPlayerMap} = lists:foldl(FunInitSeat, {0, #{}}, PlayerList),
    maps:put(seat_player_map, SeatPlayerMap, State).

init_duty(State) ->
    ok.

generate_turn(State) ->
    ok.

%%%====================================================================
%%% Internal functions
%%%====================================================================