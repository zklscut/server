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
    #{match_num := MatchNum,
      match_list := MatchList} = MatchData,
    NewMatchNum = MatchNum + length(PlayerList),
    NewMatchList = MatchList ++ [{hd(PlayerList), PlayerList, Rank}],
    NewMatchData = MatchData#{match_num := NewMatchNum,
                              match_list := NewMatchList},
    update_match_data(NewMatchData),
    do_start_fight(NewMatchData),                                     
    {noreply, State};

handle_cast_inner({cancle_match, PlayerId}, State) ->
    MatchData = get_match_data(),
    #{match_num := MatchNum,
      match_list := MatchList} = MatchData,
    case lists:keyfind(PlayerId, 1, MatchList) of
        false ->
            ignore;
        {_, PlayerList, _} ->
            NewMatchNum = MatchNum - length(PlayerList),
            NewMatchList = lists:keydelete(PlayerId, 1, MatchList),
            NewMatchData = MatchData#{match_num := NewMatchNum,
                                      match_list := NewMatchList},
            update_match_data(NewMatchData)
    end,

    {noreply, State};    

handle_cast_inner({enter_match, PlayerId, WaitId}, State) ->
    MatchData = get_match_data(),
    #{wait_list := WaitList} =  MatchData,
    case maps:get(WaitId, WaitList, undefined) of
        undefined ->
            ignore;
        WaitMatch ->
             #{wait_player_list := WaitPlayerList,
               player_list := StartPlayerList} = WaitMatch,
             NewWaitPlayerList = WaitPlayerList -- [PlayerId],
             case NewWaitPlayerList of
                [] ->
                    fight_srv:start_link(0, StartPlayerList, b_duty:get(?MATCH_NEED_PLAYER_NUM)),
                    NewWaitList = maps:remove(WaitId, WaitList),
                    NewMatchData = maps:put(wait_list, NewWaitList, MatchData),
                    update_match_data(NewMatchData);
                _ ->
                    NewWaitMatch = WaitMatch#{wait_player_list := NewWaitPlayerList},
                    NewWaitList = maps:put(WaitId, NewWaitMatch, WaitList),
                    NewMatchData = maps:put(wait_list, NewWaitList, MatchData),
                    update_match_data(NewMatchData)
            end
    end;

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
    #{wait_list := WaitList,
      match_list := MatchList} = MatchData,
    Now = util:get_micro_time(),
    FunTimeOut = 
        fun(#{id := WaitId,
              fit_list := FitList,
              wait_player_list := WaitPlayerList,
              start_wait_time := StartWaitTime}, {CurWaitList, CurMatchList}) ->
            case Now - StartWaitTime > ?MATCH_TIMEOUT of
                true ->
                    {maps:remove(WaitId, CurWaitList),
                     CurMatchList ++ [{CurPlayerId, CurPlayerList, CurRank} || {CurPlayerId, CurPlayerList, CurRank} <- FitList,
                                      not util:is_any_element_same(WaitPlayerList, CurPlayerList)]};
                    }
                false ->
                    {CurWaitList, CurMatchList}
            end
        end,
    {NewWaitList, NewMatchList} = lists:foldl(FunTimeOut, {WaitList, MatchList}, WaitList),
    NewMatchData = MatchData#{wait_list := NewWaitList,
                              match_list := NewMatchList},
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

do_start_fight(MatchData) ->
    #{match_num := MatchNum,
      match_list := MatchList} = MatchData,
    case MatchNum >= ?MATCH_NEED_PLAYER_NUM of
        true ->
            {_, _, Rank} = hd(MatchList),
            FunGetFit = 
                fun({CurPlayerId, CurPlayerList, CurRank}, {CurFitNum, CurFitList}) ->
                    %%TODO 按照时间拿差值 时间在 last_match_time
                    case abs(CurRank - Rank) =< ?MATCH_MIN_DIFF_RANK of
                        true ->
                            CurNum = length(CurPlayerList),
                            case CurFitNum + CurNum > ?MATCH_NEED_PLAYER_NUM of
                                true ->
                                    {CurFitNum, CurFitList};
                                false ->
                                    case CurFitNum + CurNum == ?MATCH_NEED_PLAYER_NUM of
                                        true ->
                                            throw({start_fight, CurFitList ++ [{CurPlayerId, CurPlayerList, CurRank}]});
                                        false ->
                                            {CurFitNum + CurNum, CurFitList ++ [{CurPlayerId, CurPlayerList, CurRank}]}
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
                    FunStartFight = 
                        fun({CurPlayerId, CurPlayerList, _CurRank}, {CurMatchList, CurStartPlayerList}) ->
                            {lists:keydelete(CurPlayerId, 1, CurMatchList),
                             CurStartPlayerList ++ CurPlayerList}
                        end,
                    {NewMatchList, StartPlayerList} = lists:foldl(FunStartFight, {MatchList, []}, FitList),
                    {WaitId, WaitMatch} = generate_wait_match(StartPlayerList, FitList)
                    NewMatchData = MatchData#{match_num := MatchNum - ?MATCH_NEED_PLAYER_NUM,
                                              match_list := NewMatchList,
                                              wait_list := maps:put(WaitId, WaitMatch, maps:get(wait_list, MatchData)),
                                              last_match_time := util:get_micro_time()},
                    update_match_data(NewMatchData),
                    Send = #m__match__notice_enter_match__s2l{wait_id = WaitId},
                    [net_send:send(Send, CurPlayerId) || CurPlayerId <- StartPlayerList]
            end;
        false ->
            ignore
    end.

generate_wait_match(PlayerIdList, FitList) ->
    Id = global_id_srv:gemerate_match_wait_id(),
    {Id, #{id => Id,
           fit_list => FitList,
           player_list => PlayerIdList,
           wait_player_list => PlayerIdList,
           start_wait_time => util:get_micro_time()}}.