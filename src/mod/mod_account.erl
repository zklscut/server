%% @author zhangkl
%% @doc mod_account.
%% 2016

-module(mod_account).
-export([login/2, handle_send_login_result/1]).

-include("game_pb.hrl").
-include("ets.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

login(#m__account__login__l2s{account_name = AccountName}, 
    #{socket := Socket} = Player) ->
    {_IsCreate, NewPlayer} = create_or_get_player(AccountName, Player),

    PlayerId = lib_player:get_player_id(NewPlayer),
    case lib_player:get_player_pid(PlayerId) of
        undefined ->
            lager:info("login1"),
            handle_send_login_result(NewPlayer);
        Pid ->
            lager:info("login2"),
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
    lager:info("create_or_get_player1"),
    {IsCreate, Player} = 
        case lib_ets:get(?ETS_ACCOUNT_PLAYER, AccountName) of
            undefined ->
                lager:info("create_or_get_player2"),
                {1, create_player(AccountName)};
            PlayerId ->
                lager:info("create_or_get_player3"),
                {0, lib_player:get_player(PlayerId)}
        end,
    {IsCreate, Player#{socket => Socket}}.

create_player(AccountName) ->
    lager:info("create_or_get_player4"),
    PlayerId = global_id_srv:generate_player_id(),
    lib_ets:update(?ETS_ACCOUNT_PLAYER, AccountName, PlayerId),
    CreatePlayer = #{id => PlayerId,
                     account_name => AccountName,
                     nick_name => PlayerId,
                     data => #{}},
    lib_player:update_player(CreatePlayer),
    CreatePlayer.
