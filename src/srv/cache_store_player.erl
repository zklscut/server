%% @author zhangkl
%% @doc cache_store_player.
%% 2016

-module(cache_store_player).

-include("db.hrl").
-include("ets.hrl").

-export([init/0,
         sync_db/1]).

%% ====================================================================
%% API functions
%% ====================================================================

init() ->
    Sql = db:make_select_sql(player, ["id", "account_name", "nick_name", "data"], [], [], []),
    PlayerList = db:get_all(Sql),
    FunInit = 
        fun([Id, AccountNameB, NickName, Data]) ->
            AccountName = binary_to_list(AccountNameB),
            Player = #{id => Id,
                       account_name => AccountName,
                       nick_name => binary_to_list(NickName),
                       data => binary_to_term(Data)},
            lib_ets:update(ets_cache_store_player, Id, Player),
            lib_ets:update(?ETS_ACCOUNT_PLAYER, AccountName, Id)
        end,
    lists:foreach(FunInit, PlayerList).

sync_db(DirtyKeyList) ->
    FunGet = 
        fun(Key) ->
            Player = lib_ets:get(ets_cache_store_player, Key),
            case maps:get(id, Player, 0) of
                0 ->
                  [0, "", "", term_to_binary(#{})];
                _ ->
                  #{id := Id,
                    account_name := AccountName,
                    nick_name := NickName,
                    data := Data} = Player,
                  [Id, AccountName, NickName, term_to_binary(Data)]
            end
        end,
    ReplaceData = lists:map(FunGet, DirtyKeyList),
    ReplaceSql = db:make_batch_replace_sql(player, ["id", "account_name", "nick_name", "data"], ReplaceData),
    db:execute(ReplaceSql),
    ok.

%%%====================================================================
%%% Internal functions
%%%====================================================================