%% @author zhangkl
%% @doc room_srv.
%% 2016

-module(room_srv).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([
            enter_room/2, 
            create_room/4, 
            leave_room/1, 
            want_chat/1, 
            end_chat/1,
            kick_player/2]).

-include("room.hrl").
-include("chat.hrl").
-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

enter_room(RoomId, Player) ->
    gen_server:cast(?MODULE, {enter_room, RoomId, lib_player:get_player_id(Player)}).

create_room(MaxPlayerNum, RoomName, DutyList, Player) ->
    gen_server:cast(?MODULE, {create_room, MaxPlayerNum, RoomName, DutyList, Player}).

leave_room(Player) ->
    RoomId = maps:get(room_id, Player, 0),
    gen_server:cast(?MODULE, {leave_room, RoomId, lib_player:get_player_id(Player)}).    

want_chat(Player) ->
    RoomId = maps:get(room_id, Player, 0),
    gen_server:cast(?MODULE, {want_chat, RoomId, lib_player:get_player_id(Player)}).        

end_chat(Player) ->
    RoomId = maps:get(room_id, Player, 0),
    gen_server:cast(?MODULE, {end_chat, RoomId, lib_player:get_player_id(Player)}).            

kick_player(Player, OpPlayer)->
    RoomId = maps:get(room_id, Player, 0),
    OpName = lib_player:get_name(OpPlayer),
    gen_server:cast(?MODULE, {kick_player, RoomId, OpName, lib_player:get_player_id(Player)}).        

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
            global_op_srv:player_op(PlayerId, {mod_player, send_errcode, ErrCode}),
            {noreply, State};
        throw:ErrCode ->
            lager:info("room srv errcode ~p", [ErrCode]),
            {noreply, State};
        What:Error ->
            lager:error("room srv error what ~p, Error ~p, stack", 
                    [What, Error, erlang:get_stacktrace()]),
            {noreply, State}        
    end.

handle_cast_inner({enter_room, RoomId, PlayerId}, State) ->
    lager:info("enter_room1"),
    lib_room:assert_room_exist(RoomId),
    lager:info("enter_room2"),
    Room = lib_room:get_room(RoomId),
    lager:info("enter_room3"),
    lib_room:assert_room_not_full(Room),
    lager:info("enter_room4"),
    #{player_list := PlayerList} = Room,
    NewRoom = Room#{player_list := PlayerList ++ [PlayerId]},
    lib_room:update_room(RoomId, NewRoom),
    lager:info("enter_room5"),
    global_op_srv:player_op(PlayerId, {mod_room, handle_enter_room, [NewRoom]}),
    mod_room:notice_team_change(NewRoom),
    lager:info("enter_room6"),
    mod_chat:send_system_room_chat(?SYSTEM_CHAT_ROOM_ENTER, lib_player:get_name(PlayerId), RoomId),

    %%通知正在发言的人
    notice_chat_info(PlayerId, NewRoom),
    lager:info("enter_room7"),
    {noreply, State};

handle_cast_inner({create_room, MaxPlayerNum, RoomName, DutyList, Player}, State) ->
    PlayerId = lib_player:get_player_id(Player),
    RoomId = global_id_srv:generate_room_id(),
    Room = ?MROOM#{room_id => RoomId,
                   owner => lib_player:get_player_show_base(Player),
                   player_list => [PlayerId],
                   max_player_num => MaxPlayerNum,
                   room_name => RoomName,
                   room_status => "0",
                   duty_list => DutyList},
    lib_room:update_room(RoomId, Room),
    global_op_srv:player_op(PlayerId, {mod_room, handle_create_room, [Room]}),
    {noreply, State};        

handle_cast_inner({leave_room, RoomId, PlayerId}, State) ->
    do_player_exit_room(RoomId, PlayerId),
    global_op_srv:player_op(PlayerId, {mod_room, handle_leave_room, []}),
    do_exit_chat(PlayerId, RoomId),
    {noreply, State};

handle_cast_inner({want_chat, RoomId, PlayerId}, State) ->
    case lib_room:is_in_fight(RoomId) of
        false->
            want_chat_local(RoomId, PlayerId);
        _->
            ignore
    end,
    {noreply, State};

handle_cast_inner({end_chat, RoomId, PlayerId}, State) ->
    do_end_chat(RoomId, PlayerId),
    {noreply, State};

handle_cast_inner({kick_player, RoomId, OpName, PlayerId}, State) ->
    do_player_exit_room(RoomId, PlayerId),
    global_op_srv:player_op(PlayerId, {mod_room, handle_kick_player, [OpName]}),
    do_exit_chat(PlayerId, RoomId),
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

handle_info({chat_timeout, PlayerId, RoomId}, State) ->
    do_end_chat(RoomId, PlayerId),
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

do_player_exit_room(RoomId, PlayerId)->
    try
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
                mod_room:notice_team_change(NewRoom),
                % mod_chat:send_system_room_chat(?SYSTEM_CHAT_ROOM_KICK, lib_player:get_name(PlayerId), RoomId),
                lib_room:update_room(RoomId, NewRoom)
        end
    catch
        _:_ ->
            ignore
    end.
want_chat_local(RoomId, PlayerId)->
    try
        lib_room:assert_room_exist(RoomId),
        Room = lib_room:get_room(RoomId),
        WantChatList = maps:get(want_chat_list, Room),
        NewWantChatList = util:add_element_single(PlayerId, WantChatList),
        NewRoom = maps:put(want_chat_list, NewWantChatList, Room),
        lib_room:update_room(RoomId, NewRoom),
        case WantChatList of
            [] ->
                do_start_chat(PlayerId, NewRoom, RoomId);
            _ ->
                ignore
        end
    catch
        _:_ ->
            ignore
    end.

notice_chat_info(PlayerId, Room)->
    WantChatList = maps:get(want_chat_list, Room),
    case WantChatList of
        []->
            ignore;
        _->
            ChatStartTime = maps:get(chat_start_time, Room),
            CurTime = util:get_micro_time(),
            Send = #m__room__notice_chat_info__s2l{
                                            player_id = hd(WantChatList),
                                            wait_time = CurTime + 60000 - ChatStartTime
                                        },
            mod_room:send_to_player(Send, PlayerId)
    end.
    

do_start_chat(PlayerId, Room, RoomId) ->
    WantChatList = maps:get(want_chat_list, Room),
    Send = #m__room__notice_start_chat__s2l{start_id = PlayerId,
                                            wait_list = WantChatList},
    mod_room:send_to_room(Send, Room),
    lib_room:update_room(RoomId, maps:put(chat_start_time, util:get_micro_time(), Room)),
    erlang:send_after(60000, self(), {chat_timeout, PlayerId}).

do_exit_chat(PlayerId, RoomId)->
    try
        lib_room:assert_room_exist(RoomId),
        Room = lib_room:get_room(RoomId),
        WantChatList = maps:get(want_chat_list, Room),
        case WantChatList =/= [] andalso hd(WantChatList) == PlayerId of
            true ->
                do_end_chat(RoomId, PlayerId);
            false ->
                NewRoom = maps:put(want_chat_list, WantChatList -- [PlayerId], Room),
                lib_room:update_room(RoomId, NewRoom)
        end
    catch
        _:_ ->
            ignore
    end.

do_end_chat(RoomId, PlayerId) ->
    try 
        lib_room:assert_room_exist(RoomId),
        Room = lib_room:get_room(RoomId),

        WantChatList = maps:get(want_chat_list, Room),
        case WantChatList =/= [] andalso hd(WantChatList) == PlayerId of
            true ->
                ok;
            false ->
                Send = #m__room__notice_start_chat__s2l{start_id = 0,wait_list=[]},
                mod_room:send_to_room(Send, Room),
                throw(ignore)
        end,

        NewWantChatList = tl(WantChatList),
        NewRoom = maps:put(want_chat_list, NewWantChatList, Room),
        lib_room:update_room(RoomId, NewRoom),
        case NewWantChatList of
            [] ->
                SendEmpty = #m__room__notice_start_chat__s2l{start_id = 0,wait_list=[]},
                mod_room:send_to_room(SendEmpty, Room);
            _ ->
                do_start_chat(hd(NewWantChatList), NewRoom, RoomId)
        end
    catch
        _:_ ->
            ignore
    end.
