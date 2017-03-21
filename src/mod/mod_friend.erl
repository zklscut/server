%% @author zhangkl
%% @doc mod_friend.
%% 2016

-module(mod_friend).
-export([get_friend/2,
         add_friend/2,
         remove_friend/2,
         private_chat/2,
         notice_private_chat/3,
         get_chat_list/2]).

-include("game_pb.hrl").
-include("friend.hrl").
-include("function.hrl").
-include("errcode.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

get_friend(#m__friend__get_friend__l2s{}, Player) ->
    FriendData = get_friend_data(Player),
    FunConver = 
        fun(FriendId) ->
                get_friend_info(FriendId, FriendData)
        end,
    PFriendList = lists:map(FunConver, maps:keys(FriendData)),
    Send = #m__friend__get_friend__s2l{friend_list = PFriendList},
    net_send:send(Send, Player),
    {ok, Player}.

add_friend(#m__friend__add_friend__l2s{add_friend = AddFriend}, Player) ->
    FriendData = get_friend_data(Player),
    ?ASSERT(length(maps:keys(FriendData)) < ?MAX_FRIEND, ?FRIEND_TOO_MUCH),
    NewFriendData = maps:put(AddFriend, #{chat_list => []}, FriendData),
    net_send:send(#m__friend__add_friend__s2l{friend = 
                get_friend_info(AddFriend, NewFriendData)}, Player),
    {save, update_friend_data(NewFriendData, Player)}.

remove_friend(#m__friend__remove_friend__l2s{remove_friend = RemoveFriend}, Player) ->
    FriendData = get_friend_data(Player),
    NewFriendData = maps:remove(RemoveFriend, FriendData),
    net_send:send(#m__friend__remove_friend__s2l{remove_friend = RemoveFriend}, Player),
    {save, update_friend_data(NewFriendData, Player)}.

private_chat(#m__friend__private_chat__l2s{chat = InitPChat,
                                         target_id = TargetId}, Player) ->
    FriendData = get_friend_data(Player),
    OneFriend = maps:get(TargetId, FriendData),
    PChat = mod_chat:get_p_chat(InitPChat, Player),
    ChatList = maps:get(chat_list, OneFriend),
    NewChatList = 
        case length(ChatList) > ?MAX_FRIEND_CHAT of
            true ->
                tl(ChatList) ++ [PChat];
            false ->
                ChatList ++ [PChat]
        end,
    NewOneFriend = maps:put(chat_list, NewChatList, OneFriend),
    NewFriendData = maps:put(TargetId, NewOneFriend, FriendData),

    Send = #m__friend__private_chat__s2l{                
                    target_info = lib_player:get_player_show_base(TargetId),
                    chat = PChat},
    net_send:send(Send, Player),
    net_send:send(Send, TargetId),

    % global_op_srv:player_op(TargetId, {?MODULE, notice_private_chat, 
    %     [lib_player:get_player_id(Player), PChat]}),
    {save, update_friend_data(NewFriendData, Player)}.

notice_private_chat(SpeakId, PChat, Player) ->
    FriendData = get_friend_data(Player),
    OneFriend = maps:get(SpeakId, FriendData),
    ChatList = maps:get(chat_list, OneFriend),
    NewChatList = 
        case length(ChatList) > ?MAX_FRIEND_CHAT of
            true ->
                tl(ChatList) ++ [PChat];
            false ->
                ChatList ++ [PChat]
        end,
    NewOneFriend = maps:put(chat_list, NewChatList, OneFriend),
    NewFriendData = maps:put(SpeakId, NewOneFriend, FriendData),

    % Send = #m__friend__private_chat__s2l{chat = PChat},
    % net_send:send(Send, Player),
    {save, update_friend_data(NewFriendData, Player)}.

get_chat_list(#m__friend__get_chat_list__l2s{friend_id = FriendId}, Player) ->
    FriendData = get_friend_data(Player),
    OneFriend = maps:get(FriendId, FriendData),
    ChatList = maps:get(chat_list, OneFriend),

    Send = #m__friend__get_chat_list__s2l{chat_list = ChatList},
    net_send:send(Send, Player),
    {ok, Player}.

%%%====================================================================
%%% Internal functions
%%%====================================================================

get_friend_data(Player) ->
    maps:get(friend, maps:get(data, Player), #{}).

update_friend_data(FriendData, Player) ->
    Data = maps:get(data, Player),
    NewData = maps:put(friend, FriendData, Data),
    maps:put(data, NewData, Player).

get_friend_info(FriendId, FriendData)->
    OneFriend = maps:get(FriendId, FriendData),
    FriendPlayer = lib_player:get_player(FriendId),
    RoomId = lib_room:get_player_room_id(FriendPlayer),
    Status = 
        case lib_player:is_online(FriendId) of
            true ->
                case RoomId of
                    0 ->
                        ?FRIEND_STATUS_ONLINE;
                    _ ->
                        ?FRIEND_STATUS_INROOM
                end;
            false ->
                ?FRIEND_STATUS_OFFLINE
        end,
    #{chat_list := _ChatList} = OneFriend,
    #p_friend{player_show_base = lib_player:get_player_show_base(FriendPlayer),
              room_id = RoomId,
              status = Status
            }.
              % last_chat = ChatList}.