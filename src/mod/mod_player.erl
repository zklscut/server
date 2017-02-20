%% @author zhangkl
%% @doc mod_player.
%% 2016

-module(mod_player).
-export([info/2,
         handle_fight_result/3,
         handle_fight_result_local/3]).

-include("game_pb.hrl").
-include("resource.hrl").
-include("log.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

info(#m__player__info__l2s{}, Player) ->
    Return = #m__player__info__s2l{player_id = lib_player:get_player_id(Player),
                                   nick_name = maps:get(nick_name, Player),
                                   grade = 0,
                                   month_vip = 0,
                                   equip = 0,
                                   resource_list = mod_resource:get_p_resource_list(Player),
                                   win_rate_list = get_p_resource_list(Player)},
    net_send:send(Return, Player),

    NewPlayer = lib_player:handle_after_login(Player),
    {save, NewPlayer}.

handle_fight_result(DutyId, IsWin, PlayerId) ->
    global_op_srv:player_op(PlayerId, {?MODULE, handle_fight_result_local, [DutyId, IsWin]}).

handle_fight_result_local(DutyId, IsWin, Player) ->
    PlayerAfterCoin = increase_fight_coin(DutyId, IsWin, Player),
    PlayerAfterExp = increase_fight_exp(DutyId, IsWin, PlayerAfterCoin),
    PlayerAfterWinRate = do_fight_rate(DutyId, IsWin, PlayerAfterExp),
    {save, PlayerAfterWinRate}.

%%%====================================================================
%%% Internal functions
%%%====================================================================

increase_fight_coin(DutyId, IsWin, Player) ->
    Coin = get_fight_coin(DutyId, IsWin),
    mod_resource:increase(?RESOURCE_COIN, Coin, ?LOG_ACTION_FIGHT, Player).

get_fight_coin(_DutyId, _IsWin) ->
    100.

increase_fight_exp(DutyId, IsWin, Player) ->
    Exp = get_fight_exp(DutyId, IsWin),
    mod_resource:increase(?RESOURCE_EXP, Exp, ?LOG_ACTION_FIGHT, Player).

get_fight_exp(_DutyId, _IsWin) ->
    100.    

do_fight_rate(DutyId, IsWin, Player) ->
    WinRateList = maps:get(win_rate_list, maps:get(data, Player), #{}),
    {AllDutyWinCnt, AllDutyCnt} = maps:get(0, WinRateList, {0, 0}),
    {DutyWinCnt, DutyCnt} = maps:get(DutyId, WinRateList, {0, 0}),
    NewWinList = WinRateList#{0 => {AllDutyWinCnt + IsWin, AllDutyCnt + 1},
                              DutyId => {DutyWinCnt + 1, DutyCnt + 1}},
    NewData = maps:put(win_rate_list, NewWinList, maps:get(data, Player)),
    maps:put(data, NewData, Player).

get_p_fight_rate_list(Player) ->
    WinRateList = maps:get(win_rate_list, maps:get(data, Player), #{}),
    FunConver = 
        fun(DutyId) ->
            {WinCnt, AllCnt} = maps:get(DutyId, WinRateList),
            #p_win_rate{duty_id = DutyId,
                        win_cnt = WinCnt,
                        all_cnt = AllCnt}
        end,
    lists:map(FunConver, maps:keys(WinRateList)).
