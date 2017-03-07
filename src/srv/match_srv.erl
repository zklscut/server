%% @author zhangkl
%% @doc match_srv.
%% 2016

-module(match_srv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("ets.hrl").
-include("match.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

start_match(PlayerList, Rank) ->
    gen_server:cast(?MODULE, {start_match, PlayerList, Rank}).

cancle_match(PlayerId) ->
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
                    case abs(CurRank - Rank) =< ?MATCH_MIN_DIFF_RANK of
                        true ->
                            CurNum = length(CurPlayerList),
                            case CurFitNum + CurNum > ?MATCH_NEED_PLAYER_NUM of
                                true ->
                                    {CurFitNum, CurFitList};
                                false ->
                                    case CurFitNum + CurNum == ?MATCH_NEED_PLAYER_NUM of
                                        true ->
                                            throw({start_fight, CurFitList ++ CurPlayerList});
                                        false ->
                                            {CurFitNum + CurNum, CurFitList ++ CurPlayerList}
                                    end
                            end;
                        false ->
                            {CurFitNum, CurFitList}
                    end
                end,
            try
                lists:foldl(FunGetFit, {0, []}, MatchList)
            catch
                throw:{start_fight, StartPlayerIdList} ->
                    start_link(0, StartPlayerIdList, b_duty:get(?MATCH_NEED_PLAYER_NUM))
            end;
        false ->
            ignore
    end.
