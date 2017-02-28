%% @author zhangkl
%% @doc mod_player.
%% 2016

-module(mod_player).
-export([info/2,
         other_info/2,
         add_coin/2,
         add_diamond/2,
         handle_fight_result/5,
         handle_fight_result_local/5,
         handle_consume_gift/2,
         handle_consume_gift_local/2,
         handle_receive_gift/2,
         handle_receive_gift_local/2,
         change_name/2,
         get_extra_coin/4,
         get_fight_coin/3,
         get_extra_exp/4,
         get_fight_exp/3
         ]).

-include("game_pb.hrl").
-include("resource.hrl").
-include("fight.hrl").
-include("log.hrl").
-include("errcode.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

info(#m__player__info__l2s{}, Player) ->
    Send = get_send_player_info(Player, 0),
    net_send:send(Send, Player),
    NewPlayer = lib_player:handle_after_login(Player),
    {save, NewPlayer}.

other_info(#m__player__other_info__l2s{player_id = PlayerId}, Player) ->
    Send = get_send_player_info(lib_player:get_player(PlayerId), 1),
    net_send:send(Send, Player),
    {ok, Player}.

add_coin(#m__player__add_coin__l2s{}, Player) ->
  NewPlayer = mod_resource:increase(?RESOURCE_COIN, 500000, ?LOG_ACTION_FIGHT, Player),
  {save, NewPlayer}.

add_diamond(#m__player__add_diamond__l2s{}, Player) ->
  NewPlayer = mod_resource:increase(?RESOURCE_DIAMOND, 500000, ?LOG_ACTION_FIGHT, Player),
  {save, NewPlayer}.

handle_fight_result(DutyId, IsWin, CoinAdd, ExpAdd, PlayerId) ->
    global_op_srv:player_op(PlayerId, {?MODULE, handle_fight_result_local, [DutyId, IsWin, CoinAdd, ExpAdd]}).

handle_fight_result_local(DutyId, IsWin, CoinAdd, ExpAdd, Player) ->
    PlayerAfterCoin = increase_fight_coin(CoinAdd, Player),
    PlayerAfterExp = increase_fight_exp(ExpAdd, PlayerAfterCoin),
    PlayerAfterWinRate = do_fight_rate(DutyId, IsWin, PlayerAfterExp),
    {save, PlayerAfterWinRate}.

handle_consume_gift(GiftId, PlayerId) ->
  global_op_srv:player_op(PlayerId, {?MODULE, handle_consume_gift_local, [GiftId]}).

handle_consume_gift_local(GiftId, Player) ->
  {Coin, Diamond} = b_gift_consume:get(GiftId),
  PlayerAfterCoin = mod_resource:decrease(?RESOURCE_COIN, Coin, ?LOG_ACTION_FIGHT, Player),
  PlayerAfterCoinDiamond = mod_resource:decrease(?RESOURCE_DIAMOND, Diamond, ?LOG_ACTION_FIGHT, PlayerAfterCoin),
  {save, PlayerAfterCoinDiamond}.

handle_receive_gift(GiftId, PlayerId)->
  global_op_srv:player_op(PlayerId, {?MODULE, handle_receive_gift_local, [GiftId]}).

handle_receive_gift_local(GiftId, Player) ->
  {Op, LuckNum}= b_gift_effects:get(GiftId),
  PlayerAfterLuck = 
  case Op == 0 of 
      true->
          mod_resource:increase(?RESOURCE_LUCK, LuckNum, ?LOG_ACTION_FIGHT, Player);
      _-> 
          mod_resource:decrease(?RESOURCE_LUCK, LuckNum, ?LOG_ACTION_FIGHT, Player)
  end,
  {save, PlayerAfterLuck}.

change_name(#m__player__change_name__l2s{name = Name}, Player) ->
  ChangeNameCnt = maps:get(change_name_cnt, maps:get(data, Player), 0),
  case is_change_name_legal(Name) andalso ChangeNameCnt == 0 of
      true ->
          NewData = maps:put(change_name_cnt, ChangeNameCnt + 1, maps:get(data, Player)),
          Send = #m__player__change_name__s2l{name = Name, result=0},
          NewPlayer = maps:put(nick_name, Name, Player),
          net_send:send(Send, NewPlayer),
          {save, maps:put(data, NewData, NewPlayer)};
      false ->
          SendFail = #m__player__change_name__s2l{name = Name, result=1},
          net_send:send(SendFail, Player),
          {ok, Player}
  end.
              
%%%====================================================================
%%% Internal functions
%%%====================================================================

increase_fight_coin(CoinAdd, Player) ->
    mod_resource:increase(?RESOURCE_COIN, CoinAdd, ?LOG_ACTION_FIGHT, Player).



%%iswin, mvp, carry, third(是否胜利，是否mvp，是否carry，是否第三方)
get_extra_coin(1, 1, _IsCarry, _IsThird)->
    100;
 
get_extra_coin(0, _IsMvp, 1, _IsThird)->
    100;  

get_extra_coin(1, _IsMvp, _IsCarry, true)->
    200; 

get_extra_coin(_IsWin, _IsMvp, _IsCarry, _IsThird)->
    0.

%%duty, iswin, third(职责，是否胜利，是否第三方)
get_fight_coin(_DutyId, 0, false) ->
    80;

get_fight_coin(?DUTY_BAILANG, 1, false) ->
    150;

get_fight_coin(?DUTY_LANGREN, 1, false) ->
    150;

get_fight_coin(_DutyId, 1, false) ->
    100;

get_fight_coin(_DutyId, _IsWin, _Third) ->
    0.

increase_fight_exp(ExpAdd, Player) ->
    mod_resource:increase(?RESOURCE_EXP, ExpAdd, ?LOG_ACTION_FIGHT, Player).

%%iswin, mvp, carry, third(是否胜利，是否mvp，是否carry，是否第三方)
get_extra_exp(1, 1, _IsCarry, _IsThird)->
    100;
 
get_extra_exp(0, _IsMvp, 1, _IsThird)->
    100;  

get_extra_exp(1, _IsMvp, _IsCarry, true)->
    200; 

get_extra_exp(_IsWin, _IsMvp, _IsCarry, _IsThird)->
    0. 

%%duty, iswin, third(职责，是否胜利，是否第三方)
get_fight_exp(_DutyId, 0, _Third) ->
    80;

get_fight_exp(?DUTY_BAILANG, 1, false) ->
    150;

get_fight_exp(?DUTY_LANGREN, 1, false) ->
    150;

get_fight_exp(_DutyId, 1, false) ->
    100;

get_fight_exp(_DutyId, _IsWin, _Third) ->
    0.

do_fight_rate(DutyId, IsWin, Player) ->
    WinRateList = maps:get(win_rate_list, maps:get(data, Player), #{}),
    {AllDutyWinCnt, AllDutyCnt} = maps:get(0, WinRateList, {0, 0}),
    {DutyWinCnt, DutyCnt} = maps:get(DutyId, WinRateList, {0, 0}),
    NewWinList = WinRateList#{0 => {AllDutyWinCnt + IsWin, AllDutyCnt + 1},
                              DutyId => {DutyWinCnt + IsWin, DutyCnt + 1}},
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

get_send_player_info(Player, OtherPlayer) ->
    #m__player__info__s2l{player_id = lib_player:get_player_id(Player),
                          nick_name = maps:get(nick_name, Player),
                          grade = 0,
                          month_vip = 0,
                          equip = 0,
                          other_player = OtherPlayer,
                          resource_list = mod_resource:get_p_resource_list(Player),
                          win_rate_list = get_p_fight_rate_list(Player)}.
    
is_change_name_legal(Name) ->
    Sql = db:make_select_sql(player, ["count(*)"], ["nick_name"], ["="], [Name]),
    db:get_one(Sql) == 0.