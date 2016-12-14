%% @author zhangkl
%% @doc room_srv.
%% 2016

-module(room_srv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([enter_room/2, create_room/3, leave_room/1]).

-include("room.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

enter_room(RoomId, Player) ->
    gen_server:cast(?MODULE, {enter_room, RoomId, lib_player:get_player_id(Player)}).

create_room(MaxPlayerNum, RoomName, Player) ->
    gen_server:cast(?MODULE, {create_room, MaxPlayerNum, RoomName, Player}).

leave_room(Player) ->
    RoomId = maps:get(room_id, Player, 0),
    gen_server:cast(?MODULE, {leave_room, RoomId, lib_player:get_player_id(Player)}).    

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
            lager:error("room srv error what ~p, Error ~p, stack", 
                    [What, Error, erlang:get_stacktrace()]),
        {noreply, State}        
    end.

handle_cast_inner({enter_room, RoomId, PlayerId}, State) ->
    lib_room:assert_room_exist(RoomId),
    Room = lib_room:get_room(RoomId),
    lib_room:assert_room_not_full(Room),

    #{player_list := PlayerList} = Room,
    NewRoom = Room#{player_list := PlayerList ++ [PlayerId]},
    lib_room:update_room(RoomId, NewRoom),

    global_op_srv:player_op(PlayerId, {mod_room, handle_enter_room, [NewRoom]}),
    {noreply, State};

handle_cast_inner({create_room, MaxPlayerNum, RoomName, Player}, State) ->
    PlayerId = lib_player:get_player_id(Player),
    RoomId = global_id_srv:generate_room_id(),
    Room = ?MROOM#{room_id => RoomId,
                   owner => lib_player:get_player_show_base(Player),
                   player_list => [PlayerId],
                   max_player_num => MaxPlayerNum,
                   room_name => RoomName,
                   room_status => "0"},
    lib_room:update_room(RoomId, Room),
    global_op_srv:player_op(PlayerId, {mod_room, handle_create_room, [Room]}),
    {noreply, State};        

handle_cast_inner({leave_room, RoomId, PlayerId}, State) ->
    lib_room:assert_room_exist(RoomId),
    Room = lib_room:get_room(RoomId),

    PlayerList = maps:get(player_list, Room),
    case PlayerList -- [PlayerId] of
        [] ->
            lib_room:delete_room(RoomId);
        NewPlayerList ->
            Owner = 
                case lib_room:is_room_owner(PlayerId, Room) of
                    true ->
                        lib_player:get_player_show_base(hd(NewPlayerList));
                    false ->
                        maps:get(owner, Room)
                end,
            NewRoom = Room#{player_list := NewPlayerList,
                            owner := Owner},
            lib_room:update_room(RoomId, NewRoom)
    end,
    global_op_srv:player_op(PlayerId, {mod_room, handle_leave_room, []}),
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


