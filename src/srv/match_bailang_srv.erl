%% @author zhangkl
%% @doc match_srv.
%% 2016

-module(match_bailang_srv).
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
         cancel_match/1,
         offline_match/1,
         enter_match/2]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

start_match(PlayerList, Rank) ->
    gen_server:cast(?MODULE, {start_match, PlayerList, Rank}).

cancel_match(PlayerId) ->
    gen_server:cast(?MODULE, {cancel_match, PlayerId}).

enter_match(PlayerId, WaitId) ->
    gen_server:cast(?MODULE, {enter_match, PlayerId, WaitId}).    

offline_match(PlayerId) ->
    gen_server:cast(?MODULE, {cancel_match, PlayerId}).

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
    {noreply, State};


handle_cast_inner({cancel_match, PlayerId}, State) ->
    MatchData = get_match_data(),
    % update_match_data(do_cancel_match(PlayerId, MatchData)),
    lib_match:do_cancel_match(PlayerId, MatchData),
    {noreply, State};    

handle_cast_inner({enter_match, PlayerId, _WaitId}, State) ->
    lager:info("enter_match1"),
    MatchData = get_match_data(),
    lib_match:do_enter_match(PlayerId, MatchData),
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
    case lib_ets:get(?ETS_MATCH, 1) of
        undefined ->
            ?MATCH_DATA#{match_type => 1,
                         duty_template => 1
                        };
        MatchData ->
            MatchData
    end.
