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
         offline_match/1,
         enter_match/2]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

start_match(PlayerList, Rank) ->
    gen_server:cast(?MODULE, {start_match, PlayerList, Rank}).

cancle_match(PlayerId) ->
    gen_server:cast(?MODULE, {cancle_match, PlayerId}).

enter_match(PlayerId, WaitId) ->
    gen_server:cast(?MODULE, {enter_match, PlayerId, WaitId}).    

offline_match(PlayerId) ->
    gen_server:cast(?MODULE, {cancle_match, PlayerId}).

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
    erlang:send_after(?MATCH_TIMETICK, self(), wait_timeout),
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
    lib_match:do_start_match(PlayerList, Rank, MatchData),
    % #{
    %   match_list := MatchList,
    %   player_info:= PlayerInfo
    %   } = MatchData,
    % MatchPlayerId = hd(PlayerList),
    % NewMatchList = MatchList ++ [{MatchPlayerId, PlayerList, Rank, length(PlayerList)}],
    % NewPlayerInfo = do_init_player_info(PlayerInfo, PlayerList),
    % NewMatchData = MatchData#{
    %                           match_list := NewMatchList,
    %                           player_info := NewPlayerInfo
    %                           },
    % update_match_data(NewMatchData),
    % do_start_fight(NewMatchData),                                     
    {noreply, State};


handle_cast_inner({cancle_match, PlayerId}, State) ->
    MatchData = get_match_data(),
    % update_match_data(do_cancel_match(PlayerId, MatchData)),
    lib_match:do_cancel_match(PlayerId, MatchData),
    {noreply, State};    

handle_cast_inner({enter_match, PlayerId, _WaitId}, State) ->
    lager:info("enter_match1"),
    MatchData = get_match_data(),
    lib_match:do_enter_match(PlayerId, MatchData),
    % #{
    %     player_info := PlayerInfo,
    %     wait_list := WaitList,
    %     match_list := MatchList
    % } =  MatchData,
    % WaitId = 
    %     case maps:get(PlayerId, PlayerInfo, undefined) of
    %         undefined->
    %             undefined;
    %         {_,CurWaitId}->
    %             CurWaitId
    %     end,

    % case maps:get(WaitId, WaitList, undefined) of
    %     undefined ->
    %         lager:info("enter_match2"),
    %         ignore;
    %     WaitMatch ->
    %         lager:info("enter_match3"),
    %          #{
    %             wait_player_list := WaitPlayerList,
    %             player_list := StartPlayerList} = WaitMatch,
    %          NewWaitPlayerList = WaitPlayerList -- [PlayerId],
    %         ReadyPlayerList =  StartPlayerList -- NewWaitPlayerList,
    %         Send = #m__match__enter_match_list__s2l{
    %                 wait_id = WaitId,
    %                 ready_list = [lib_player:get_player_show_base(ReadyPlayerId)||ReadyPlayerId<-ReadyPlayerList],
    %                 wait_list = [lib_player:get_player_show_base(WaitPlayerId)||WaitPlayerId<-NewWaitPlayerList]
    %             },
    %          mod_match:send_to_player_list(Send, StartPlayerList),   
    %          case NewWaitPlayerList of
    %             [] ->
    %                 %%战斗开始从队列中移除
                    
    %                 NewPlayerInfo = do_remove_player_info(PlayerInfo, StartPlayerList),
    %                 NewWaitList = maps:remove(WaitId, WaitList),
    %                 NewMatchList = 
    %                             lists:foldl(
    %                             fun(CurPlayerId, CurMatchList) ->
    %                                 lists:keydelete(CurPlayerId, 1, CurMatchList)
    %                             end, 
    %                             MatchList, 
    %                             StartPlayerList
    %                             ),
    %                 update_match_data(MatchData#{player_info := NewPlayerInfo,
    %                                                 wait_list := NewWaitList,
    %                                                 match_list := NewMatchList}),
    %                 fight_srv:start_link(0, StartPlayerList, b_duty:get(?MATCH_NEED_PLAYER_NUM), "abc");
    %             _ ->
    %                 NewWaitMatch = WaitMatch#{wait_player_list := NewWaitPlayerList},
    %                 NewWaitList = maps:put(WaitId, NewWaitMatch, WaitList),
    %                 NewMatchData = maps:put(wait_list, NewWaitList, MatchData),
    %                 update_match_data(NewMatchData)
    %         end
    % end,
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
    erlang:send_after(?MATCH_TIMETICK, self(), wait_timeout),
    MatchData = get_match_data(),
    lib_match:do_time_tick(MatchData),
    % #{
    %     wait_list := WaitList,
    %     match_list := MatchList,
    %     player_info := PlayerInfo
    %   } = MatchData,
    % Now = util:get_micro_time(),
    % FunTimeOut = 
    %     fun(WaitId, {CurWaitList, CurMatchList, CurPlayerInfo}) ->
    %         #{id := WaitId,
    %           fit_list := FitList,
    %           wait_player_list := WaitPlayerList,
    %           start_wait_time := StartWaitTime} = maps:get(WaitId, WaitList), 
    %         case Now - StartWaitTime > ?MATCH_TIMEOUT of
    %             true ->
    %                 lager:info("do_time_out"),
    %                 do_time_out(maps:remove(WaitId, CurWaitList), 
    %                         CurMatchList, CurPlayerInfo, WaitPlayerList, FitList);
    %             false ->
    %                 {CurWaitList, CurMatchList, CurPlayerInfo}
    %         end
    %     end,

    % {NewWaitList, NewMatchList, NewPlayerInfo} = 
    %     lists:foldl(FunTimeOut, {WaitList, MatchList, PlayerInfo}, maps:keys(WaitList)),
    % % lager:info("do_time_out ~p", [{NewWaitList, NewMatchList, NewPlayerInfo}]),
    % NewMatchData = MatchData#{wait_list := NewWaitList,
    %                           match_list := NewMatchList,
    %                           player_info := NewPlayerInfo},
    % update_match_data(NewMatchData),
    % do_start_fight(NewMatchData),
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
            ?MATCH_DATA#{match_type => 0};
        MatchData ->
            MatchData
    end.
