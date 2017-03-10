%% @author zhangkl
%% @doc match_srv.
%% 2016

-module(match_srv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("ets.hrl").
-include("match.hrl").
-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/0,
         start_match/2,
         cancle_match/1,
         enter_match/2]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

start_match(PlayerList, Rank) ->
    gen_server:cast(?MODULE, {start_match, PlayerList, Rank}).

cancle_match(PlayerId) ->
    gen_server:cast(?MODULE, {cancle_match, PlayerId}).

enter_match(PlayerId, WaitId) ->
    gen_server:cast(?MODULE, {enter_match, PlayerId, WaitId}).    

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {}).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
-spec init(Args :: term()) -> Result when
    Result :: {ok, State}
            | {ok, State, Timeout}
            | {ok, State, hibernate}
            | {stop, Reason :: term()}
            | ignore,
    State :: term(),
    Timeout :: non_neg_integer() | infinity.
%% ====================================================================
init([]) ->
    erlang:send_after(?MATCH_TIMEOUT, self(), wait_timeout),
    {ok, #state{}}.


%% handle_call/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
    Result :: {reply, Reply, NewState}
            | {reply, Reply, NewState, Timeout}
            | {reply, Reply, NewState, hibernate}
            | {noreply, NewState}
            | {noreply, NewState, Timeout}
            | {noreply, NewState, hibernate}
            | {stop, Reason, Reply, NewState}
            | {stop, Reason, NewState},
    Reply :: term(),
    NewState :: term(),
    Timeout :: non_neg_integer() | infinity,
    Reason :: term().
%% ====================================================================
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
-spec handle_cast(Request :: term(), State :: term()) -> Result when
    Result :: {noreply, NewState}
            | {noreply, NewState, Timeout}
            | {noreply, NewState, hibernate}
            | {stop, Reason :: term(), NewState},
    NewState :: term(),
    Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_cast(Cast, State) ->
    try
        handle_cast_inner(Cast, State)
    catch
        throw:{ErrCode, PlayerId} ->
            global_op_srv:player_op(PlayerId, {mod_player, send_errcode, ErrCode});
        What:Error ->
            lager:error("error what ~p, Error ~p, stack", 
                [What, Error, erlang:get_stacktrace()]),
        {noreply, State}        
    end.


handle_cast_inner({start_match, PlayerList, Rank}, State) ->
    MatchData = get_match_data(),
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
    do_start_fight(NewMatchData),                                     
    {noreply, State};


handle_cast_inner({cancle_match, PlayerId}, State) ->
    MatchData = get_match_data(),
    update_match_data(do_cancel_match(PlayerId, MatchData)),
    {noreply, State};    

handle_cast_inner({enter_match, PlayerId, WaitId}, State) ->
    MatchData = get_match_data(),
    #{
        player_info := PlayerInfo,
        wait_list := WaitList,
        match_list := MatchList
    } =  MatchData,
    case maps:get(WaitId, WaitList, undefined) of
        undefined ->
            ignore;
        WaitMatch ->
             #{
                wait_player_list := WaitPlayerList,
                player_list := StartPlayerList} = WaitMatch,
             NewWaitPlayerList = WaitPlayerList -- [PlayerId],
             case NewWaitPlayerList of
                [] ->
                    %%战斗开始从队列中移除

                    lager:info("start fight ++++++++++++++++++++"),
                    %%fight_srv:start_link(0, StartPlayerList, b_duty:get(?MATCH_NEED_PLAYER_NUM)),
                    NewPlayerInfo = do_remove_player_info(PlayerInfo, StartPlayerList),
                    NewWaitList = maps:remove(WaitId, WaitList),
                    NewMatchList = 
                                lists:foldl(
                                fun(CurPlayerId, CurMatchList) ->
                                    maps:remove(CurPlayerId, CurMatchList)
                                end, 
                                MatchList, 
                                StartPlayerList
                                ),
                    update_match_data(MatchData#{player_info := NewPlayerInfo,
                                                    wait_list := NewWaitList,
                                                    match_list := NewMatchList});
                _ ->
                    NewWaitMatch = WaitMatch#{wait_player_list := NewWaitPlayerList},
                    NewWaitList = maps:put(WaitId, NewWaitMatch, WaitList),
                    NewMatchData = maps:put(wait_list, NewWaitList, MatchData),
                    update_match_data(NewMatchData)
            end
    end,
    {noreply, State};

handle_cast_inner(_Cast, State) ->
    {noreply, State}.

%% handle_info/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
-spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
    Result :: {noreply, NewState}
            | {noreply, NewState, Timeout}
            | {noreply, NewState, hibernate}
            | {stop, Reason :: term(), NewState},
    NewState :: term(),
    Timeout :: non_neg_integer() | infinity.
%% ====================================================================



handle_info(wait_timeout, State) ->
    erlang:send_after(?MATCH_TIMEOUT, self(), wait_timeout),
    MatchData = get_match_data(),
    #{
        wait_list := WaitList,
        match_list := MatchList,
        player_info := PlayerInfo
      } = MatchData,
    Now = util:get_micro_time(),
    FunTimeOut = 
        fun(#{id := WaitId,
              fit_list := FitList,
              wait_player_list := WaitPlayerList,
              start_wait_time := StartWaitTime}, 
              {CurWaitList, CurMatchList, CurPlayerInfo}) ->
            case Now - StartWaitTime > ?MATCH_TIMEOUT of
                true ->
                    {maps:remove(WaitId, CurWaitList),
                     do_time_out(CurMatchList, CurPlayerInfo, WaitPlayerList, FitList),
                     CurPlayerInfo};
                false ->
                    {CurWaitList, CurMatchList, CurPlayerInfo}
            end
        end,
    {NewWaitList, NewMatchList, NewPlayerInfo} = lists:foldl(FunTimeOut, {WaitList, MatchList, PlayerInfo}, WaitList),
    NewMatchData = MatchData#{wait_list := NewWaitList,
                              match_list := NewMatchList,
                              player_info := NewPlayerInfo},
    update_match_data(NewMatchData),
    do_start_fight(NewMatchData),
    {noreply, State};


handle_info(_Info, State) ->
    {noreply, State}.


%% terminate/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
-spec terminate(Reason, State :: term()) -> Any :: term() when
    Reason :: normal
            | shutdown
            | {shutdown, term()}
            | term().
%% ====================================================================
terminate(_Reason, _State) ->
    ok.


%% code_change/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
-spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
    Result :: {ok, NewState :: term()} | {error, Reason :: term()},
    OldVsn :: Vsn | {down, Vsn},
    Vsn :: term().
%% ====================================================================
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================

get_match_data() ->
    case lib_ets:get(?ETS_MATCH, 0) of
        undefined ->
            ?MATCH_DATA;
        MatchData ->
            MatchData
    end.

update_match_data(MatchData) ->
    lib_ets:update_match_data(?ETS_MATCH, 0, MatchData).

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
                                                  player_list := NewPlayerInfo,      
                                                  wait_list := maps:put(WaitId, WaitMatch, maps:get(wait_list, MatchData)),
                                                  last_match_time := util:get_micro_time()
                                              },
                    update_match_data(NewMatchData),
                    Send = #m__match__notice_enter_match__s2l{wait_id = WaitId},
                    [net_send:send(Send, CurPlayerId) || CurPlayerId <- StartPlayerList]
            end;
        false ->
            lager:info("do_start_fight: num no enough")
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
            maps:remove(PlayerId, CurPlayerInfo)
            %%通知玩家退出排队
        end,
    lists:foldl(RomoveFun, PlayerInfo, PlayerList).

do_init_player_info(PlayerInfo, PlayerList)->
    MatchPlayerId = hd(PlayerList),
    SetFun = 
        fun(PlayerId, CurPlayerInfo)->
            maps:put(PlayerId, {MatchPlayerId, 0}, CurPlayerInfo)
            %%通知玩家排队中
        end,
    lists:foldl(SetFun, PlayerInfo, PlayerList).

do_reset_player_info(PlayerInfo, PlayerList)->
    ResetFun = 
        fun(PlayerId, CurPlayerInfo)->
            case maps:get(PlayerId, CurPlayerInfo, undefined) of
                undefined->
                    CurPlayerInfo;
                {WaitMatchPlayerId, _}->
                    maps:put(PlayerId, {WaitMatchPlayerId, 0}, CurPlayerInfo)
                    %%通知玩家重新排队中
            end
        end,
    lists:foldl(ResetFun, PlayerInfo, PlayerList).

do_set_player_info_wait(PlayerInfo, PlayerList, WaitId)->
    MatchPlayerId = hd(PlayerList),
    SetFun = 
        fun(PlayerId, CurPlayerInfo)->
            maps:put(PlayerId, {MatchPlayerId, WaitId}, CurPlayerInfo)
            %%通知玩家进入准备
        end,
    lists:foldl(SetFun, PlayerInfo, PlayerList).
 

do_time_out(MatchList, PlayerInfo, WaitPlayerList, FitList)->
    TmpFun = 
        fun({_CurPlayerId, CurPlayerList, _CurRank, _CurNum}, {CurMatchList, CurPlayerInfo})->
            case util:is_any_element_same(WaitPlayerList, CurPlayerList) of
                true->
                    %%有等待的玩家没有准备，移除队列
                    {maps:remove(hd(CurPlayerList), CurMatchList), 
                                do_remove_player_info(CurPlayerInfo, CurPlayerList)};
                false->
                    %%其他玩家没有准备则退回队列，继续准备
                    {CurMatchList, do_reset_player_info(CurPlayerInfo, CurPlayerList)}
            end           
        end,
    lists:foldl(TmpFun, {MatchList, PlayerInfo}, FitList).

do_cancel_match(PlayerId, MatchData)->
    #{
      match_list := MatchList,
      wait_list := WaitList,
      player_info := PlayerInfo
      } = MatchData,
    case maps:get(PlayerId, PlayerInfo, undefined) of
        undefined ->
            MatchData;
        {MatchPlayerId, WaitId} ->
            {NewMatchList, NewPlayerInfo} = 
            case lists:keyfind(MatchPlayerId, 1, MatchList) of
                false ->
                    {MatchList, PlayerInfo, []};
                {_,PlayerList,_} ->
                    {lists:keydelete(MatchPlayerId, 1, MatchList),
                            do_remove_player_info(PlayerInfo, PlayerList)}
                    %%通知PlayerList 退出组队
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
    end.