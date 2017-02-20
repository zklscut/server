%% @author zhangkl
%% @doc mod_account.
%% 2016

-module(mod_account).
-export([login/2, handle_send_login_result/1]).

-include("game_pb.hrl").
-include("ets.hrl").
-include("player.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

login(#m__account__login__l2s{account_name = AccountName}, 
    #{socket := Socket} = Player) ->
    {_IsCreate, NewPlayer} = create_or_get_player(AccountName, Player),
    PlayerId = lib_player:get_player_id(NewPlayer),
    case lib_player:get_player_pid(PlayerId) of
        undefined ->
            handle_send_login_result(NewPlayer);
        Pid ->
            player_srv:login_change_socket(Pid, Socket),
            player_srv:stop_force(self())
    end,
    
    {save, NewPlayer}.

handle_send_login_result(Player) ->
    handle_send_login_result(1, Player).

handle_send_login_result(Result, Player) ->
    Return = #m__account__login__s2l{result = Result},
    net_send:send(Return, Player).

%%%====================================================================
%%% Internal functions
%%%====================================================================

create_or_get_player(AccountName, #{socket := Socket}) ->
    {IsCreate, Player} = 
        case lib_ets:get(?ETS_ACCOUNT_PLAYER, AccountName) of
            undefined ->
                {1, create_player(AccountName)};
            PlayerId ->
                {0, lib_player:get_player(PlayerId)}
        end,
    {IsCreate, Player#{socket => Socket}}.

create_player(AccountName) ->
    PlayerId = global_id_srv:generate_player_id(),
    lib_ets:update(?ETS_ACCOUNT_PLAYER, AccountName, PlayerId),
    CreatePlayer = #{id => PlayerId,
                     account_name => AccountName,
                     nick_name => PlayerId,
                     data => ?PLAYER_DATA},
    lib_player:update_player(CreatePlayer),
    CreatePlayer.
