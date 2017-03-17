%% @author zhangkl
%% @doc lib_fight.
%% 2016

-module(lib_match).
-export([
         do_start_match/3,
         do_enter_match/2,
         do_time_tick/1,
         do_cancel_match/2,
         offline_match/1,
         cancel_match/2,
         start_match/2,
         enter_match/2
        ]).

-include("ets.hrl").
-include("match.hrl").
-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

offline_match(PlayerId)->
    match_srv:offline_match(PlayerId).

cancel_match(PlayerId, MatchMode)->
    MatchSrv = get_mode_match_srv(MatchMode),
    MatchSrv:cancel_match(PlayerId, 0).

start_match(PlayerList, Rank, MatchMode)->
    MatchSrv = get_mode_match_srv(MatchMode),
    MatchSrv:start_match(PlayerList, Rank).

enter_match(PlayerId, WaitId, MatchMode)->
    MatchSrv = get_mode_match_srv(MatchMode),
    MatchSrv:enter_match(PlayerId, WaitId).


%% ====================================================================
%% INNER functions
%% ====================================================================

get_mode_match_srv(MatchMode)->
    case MatchMode of
        0->
            match_srv;
        _->
            match_srv
    end.

do_start_match(PlayerList, Rank, MatchData)->
    #{
      match_list := MatchList,
      player_info:= PlayerInfo
      } = MatchData,
    MatchPlayerId = hd(PlayerList),
    NewMatchList = MatchList ++ [{MatchPlayerId, PlayerList, Rank, length(PlayerList)}],
    NewPlayerInfo = do_init_player_info(PlayerInfo, PlayerList),
    NewMatchData = MatchData#{
                              match_list := NewMatchList,
                              player_info := NewPlayerInfo
                              },
    update_match_data(NewMatchData),
    do_start_fight(NewMatchData).

do_enter_match(PlayerId, MatchData)->
    #{
        player_info := PlayerInfo,
        wait_list := WaitList,
        match_list := MatchList
    } =  MatchData,
    WaitId = 
        case maps:get(PlayerId, PlayerInfo, undefined) of
            undefined->
                undefined;
            {_,CurWaitId}->
                CurWaitId
        end,
    case maps:get(WaitId, WaitList, undefined) of
        undefined ->
            lager:info("enter_match2"),
            ignore;
        WaitMatch ->
            lager:info("enter_match3"),
             #{
                wait_player_list := WaitPlayerList,
                player_list := StartPlayerList} = WaitMatch,
             NewWaitPlayerList = WaitPlayerList -- [PlayerId],
             ReadyPlayerList =  StartPlayerList -- NewWaitPlayerList,
             Send = #m__match__enter_match_list__s2l{
                    wait_id = WaitId,
                    ready_list = [lib_player:get_player_show_base(ReadyPlayerId)||ReadyPlayerId<-ReadyPlayerList],
                    wait_list = [lib_player:get_player_show_base(WaitPlayerId)||WaitPlayerId<-NewWaitPlayerList]
                },
             mod_match:send_to_player_list(Send, StartPlayerList),   
             case NewWaitPlayerList of
                [] ->
                    %%战斗开始从队列中移除
                    
                    NewPlayerInfo = do_remove_player_info(PlayerInfo, StartPlayerList),
                    NewWaitList = maps:remove(WaitId, WaitList),
                    NewMatchList = 
                                lists:foldl(
                                fun(CurPlayerId, CurMatchList) ->
                                    lists:keydelete(CurPlayerId, 1, CurMatchList)
                                end, 
                                MatchList, 
                                StartPlayerList
                                ),
                    update_match_data(MatchData#{player_info := NewPlayerInfo,
                                                    wait_list := NewWaitList,
                                                    match_list := NewMatchList}),
                    fight_srv:start_link(0, StartPlayerList, b_duty:get(maps:get(duty_template, MatchData)), "abc");
                _ ->
                    NewWaitMatch = WaitMatch#{wait_player_list := NewWaitPlayerList},
                    NewWaitList = maps:put(WaitId, NewWaitMatch, WaitList),
                    NewMatchData = maps:put(wait_list, NewWaitList, MatchData),
                    update_match_data(NewMatchData)
            end
    end.

do_time_tick(MatchData)->
    #{
        wait_list := WaitList,
        match_list := MatchList,
        player_info := PlayerInfo
      } = MatchData,
    Now = util:get_micro_time(),
    FunTimeOut = 
        fun(WaitId, {CurWaitList, CurMatchList, CurPlayerInfo}) ->
            #{id := WaitId,
              fit_list := FitList,
              wait_player_list := WaitPlayerList,
              start_wait_time := StartWaitTime} = maps:get(WaitId, WaitList), 
            case Now - StartWaitTime > ?MATCH_TIMEOUT of
                true ->
                    lager:info("do_time_out"),
                    do_time_out(maps:remove(WaitId, CurWaitList), 
                            CurMatchList, CurPlayerInfo, WaitPlayerList, FitList);
                false ->
                    {CurWaitList, CurMatchList, CurPlayerInfo}
            end
        end,

    {NewWaitList, NewMatchList, NewPlayerInfo} = 
        lists:foldl(FunTimeOut, {WaitList, MatchList, PlayerInfo}, maps:keys(WaitList)),
    NewMatchData = MatchData#{wait_list := NewWaitList,
                              match_list := NewMatchList,
                              player_info := NewPlayerInfo},
    update_match_data(NewMatchData),
    do_start_fight(NewMatchData).

update_match_data(MatchData) ->
    lib_ets:update(?ETS_MATCH, maps:get(match_type, MatchData), MatchData).

cal_match_num(MatchData)->
    #{
      player_info := PlayerInfo,
      match_list := MatchList} = MatchData,
    FunCalNum = 
        fun({CurPlayerId, _CurPlayerList, _CurRank, CurNum}, CurMatchNum)->
                case maps:get(CurPlayerId, PlayerInfo, undefined) of
                    undefined->
                        CurMatchNum;
                    {_, IsWait}->
                        case IsWait of
                            0->
                                CurMatchNum + CurNum;
                            _->
                                CurMatchNum
                        end
                end
        end,
    lists:foldl(FunCalNum, 0, MatchList).

do_start_fight(MatchData) ->
    #{
      player_info := PlayerInfo,  
      match_list := MatchList
      } = MatchData,
    MatchNum = cal_match_num(MatchData),
    case MatchNum >= ?MATCH_NEED_PLAYER_NUM of
        true ->
            {_, _, Rank, _} = hd(MatchList),
            FunGetFit = 
                fun({CurPlayerId, CurPlayerList, CurRank, CurNum}, {CurFitNum, CurFitList}) ->
                    %%TODO 按照时间拿差值 时间在 last_match_time
                    {_, IsWait} = maps:get(CurPlayerId, PlayerInfo),
                    case (0 == IsWait) andalso (abs(CurRank - Rank) =< ?MATCH_MIN_DIFF_RANK) of
                        true ->
                            case CurFitNum + CurNum > ?MATCH_NEED_PLAYER_NUM of
                                true ->
                                    {CurFitNum, CurFitList};
                                false ->
                                    case CurFitNum + CurNum == ?MATCH_NEED_PLAYER_NUM of
                                        true ->
                                            throw({start_fight, CurFitList ++ [{CurPlayerId, CurPlayerList, CurRank, CurNum}]});
                                        false ->
                                            {CurFitNum + CurNum, CurFitList ++ [{CurPlayerId, CurPlayerList, CurRank, CurNum}]}
                                    end
                            end;
                        false ->
                            {CurFitNum, CurFitList}
                    end
                end,
            try
                lists:foldl(FunGetFit, {0, []}, MatchList)
            catch
                throw:{start_fight, FitList} ->
                    WaitId = global_id_srv:gemerate_match_wait_id(),
                    FunStartFight = 
                        fun({_, CurPlayerList, _, _}, {CurPlayerInfo, CurStartPlayerList}) ->
                            {   
                                do_set_player_info_wait(CurPlayerInfo, CurPlayerList, WaitId),
                                CurStartPlayerList ++ CurPlayerList
                            }
                        end,
                    {NewPlayerInfo, StartPlayerList} = lists:foldl(FunStartFight, {PlayerInfo, []}, FitList),
                    WaitMatch = generate_wait_match(WaitId, StartPlayerList, FitList),
                    NewMatchData = MatchData#{
                                                  player_info := NewPlayerInfo,      
                                                  wait_list := maps:put(WaitId, WaitMatch, maps:get(wait_list, MatchData)),
                                                  last_match_time := util:get_micro_time()
                                              },
                    update_match_data(NewMatchData),
                    Send = #m__match__notice_enter_match__s2l{
                                                                wait_id = WaitId,
                                                                wait_list = [lib_player:get_player_show_base(WaitPlayerId)||WaitPlayerId<-StartPlayerList]
                                                            },
                    mod_match:send_to_player_list(Send, StartPlayerList)
            end;
        false ->
            ignore % lager:info("do_start_fight: num no enough")
    end.


generate_wait_match(WaitId, PlayerIdList, FitList) ->
    #{id => WaitId,
           fit_list => FitList,
           player_list => PlayerIdList,
           wait_player_list => PlayerIdList,
           start_wait_time => util:get_micro_time()}.

do_remove_player_info(PlayerInfo, PlayerList)->
    RomoveFun = 
        fun(PlayerId, CurPlayerInfo)->
            %%通知玩家退出排队
            Send = #m__match__end_match__s2l{},
            mod_match:send_to_player(Send, PlayerId),
            maps:remove(PlayerId, CurPlayerInfo)
        end,
    lists:foldl(RomoveFun, PlayerInfo, PlayerList).

do_init_player_info(PlayerInfo, PlayerList)->
    MatchPlayerId = hd(PlayerList),
    SetFun = 
        fun(PlayerId, CurPlayerInfo)->
            %%通知玩家排队中
            Send = #m__match__again_match__s2l{is_again = 0},
            mod_match:send_to_player(Send, PlayerId),
            maps:put(PlayerId, {MatchPlayerId, 0}, CurPlayerInfo)
        end,
    lists:foldl(SetFun, PlayerInfo, PlayerList).

do_reset_player_info(PlayerInfo, PlayerList)->
    ResetFun = 
        fun(PlayerId, CurPlayerInfo)->
            case maps:get(PlayerId, CurPlayerInfo, undefined) of
                undefined->
                    CurPlayerInfo;
                {WaitMatchPlayerId, _}->
                    %%通知玩家重新排队中
                    Send = #m__match__again_match__s2l{is_again=1},
                    mod_match:send_to_player(Send, PlayerId),
                    maps:put(PlayerId, {WaitMatchPlayerId, 0}, CurPlayerInfo)
            end
        end,
    lists:foldl(ResetFun, PlayerInfo, PlayerList).

do_set_player_info_wait(PlayerInfo, PlayerList, WaitId)->
    MatchPlayerId = hd(PlayerList),
    SetFun = 
        fun(PlayerId, CurPlayerInfo)->
            maps:put(PlayerId, {MatchPlayerId, WaitId}, CurPlayerInfo)
        end,
    lists:foldl(SetFun, PlayerInfo, PlayerList).

do_time_out(WaitList, MatchList, PlayerInfo, WaitPlayerList, FitList)->
    lager:info("do_time_out---~p", [{WaitList,MatchList,PlayerInfo,WaitPlayerList,FitList}]),
    TmpFun = 
        fun({_CurPlayerId, CurPlayerList, _CurRank, _CurNum}, {CurWaitList, CurMatchList, CurPlayerInfo})->
            case util:is_any_element_same(WaitPlayerList, CurPlayerList) of
                true->
                    %%有等待的玩家没有准备，移除队列
                    {
                        CurWaitList,
                        lists:keydelete(hd(CurPlayerList), 1, CurMatchList),
                                do_remove_player_info(CurPlayerInfo, CurPlayerList)};
                false->
                    %%其他玩家没有准备则退回队列，继续准备
                    {CurWaitList, CurMatchList, do_reset_player_info(CurPlayerInfo, CurPlayerList)}
            end           
        end,
    lists:foldl(TmpFun, {WaitList, MatchList, PlayerInfo}, FitList).

do_cancel_match(PlayerId, MatchData)->
    #{
      match_list := MatchList,
      wait_list := WaitList,
      player_info := PlayerInfo
      } = MatchData,
    lager:info("do_cancel_match ~p", [MatchList]),
    NewMatchData = 
    case maps:get(PlayerId, PlayerInfo, undefined) of
        undefined ->
            MatchData;
        {MatchPlayerId, WaitId} ->
            {NewMatchList, NewPlayerInfo} = 
            case lists:keyfind(MatchPlayerId, 1, MatchList) of
                false ->
                    {MatchList, PlayerInfo};
                {_,PlayerList,_,_} ->
                    {lists:keydelete(MatchPlayerId, 1, MatchList),
                            do_remove_player_info(PlayerInfo, PlayerList)}
            end,
            WaitMatch = maps:get(WaitId, WaitList, undefined),
            %%通知玩家组队取消
            PlayerInfoAtferWait = 
            case WaitMatch of
                undefined->
                    NewPlayerInfo;
                _->
                    WaitPlayerList = maps:get(player_list, WaitMatch),
                    %%通知玩家状态更新，设置非组队等待的标志
                    do_reset_player_info(NewPlayerInfo, WaitPlayerList)
            end,    

            %%如果玩家已经在等待中，删除等待    
            NewWaitList = maps:remove(WaitId, WaitList),
            MatchData#{
                  match_list := NewMatchList,
                  wait_list := NewWaitList,
                  player_info := PlayerInfoAtferWait
                        }
    end,
    update_match_data(NewMatchData).