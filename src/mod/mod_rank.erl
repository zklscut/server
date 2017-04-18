%% @author zhangkl
%% @doc mod_rank.
%% 2016

-module(mod_rank).
-export([get_rank/2]).

-include("game_pb.hrl").
-include("rank.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

get_rank(#m__rank__get_rank__l2s{rank_type = RankType,
                                 start_rank = StartRank,
                                 end_rank = EndRank}, Player) ->
    
    RankModule = 
        case RankType of
            ?RANK_TYPE_LANGREN ->
                langren_rank_srv;
            ?RANK_TYPE_NVWU->
                nvwu_rank_srv;
            ?RANK_TYPE_YUYANJIA->
                yuyanjia_rank_srv;
            ?RANK_TYPE_LIEREN->
                lieren_rank_srv;
            ?RANK_TYPE_PINMING->
                pinming_rank_srv;
            ?RANK_TYPE_DAOZEI->
                daozei_rank_srv;
            ?RANK_TYPE_QIUBITE->
                qiubite_rank_srv;
            ?RANK_TYPE_SHOUWEI->
                shouwei_rank_srv;
            ?RANK_TYPE_BAICHI->
                baichi_rank_srv;
            ?RANK_TYPE_BAILANG->
                bailang_rank_srv;
            ?RANK_TYPE_HUNXUEER->
                hunxueer_rank_srv;
            ?RANK_TYPE_RANK->
                rank_rank_srv;
            ?RANK_TYPE_LUCK->
                luck_rank_srv;
            ?RANK_TYPE_MVP->
                mvp_rank_srv;
            ?RANK_TYPE_FIGHTING->
                fighting_rank_srv;
            _ ->
                langren_rank_srv
        end,
    lager:info("get_rank ~p", [{RankType, StartRank, EndRank, RankModule}]),
    RankList = [{Rank, rank_behaviour:get_player_show_by_rank(Rank, RankModule)} ||
                 Rank <- lists:seq(StartRank, EndRank)],
    FunConver = 
        fun({Rank, {CurPlayerId, CurValue}}) ->
                #p_rank{player_show_base = lib_player:get_player_show_base(CurPlayerId),
                        rank = Rank,
                        value = CurValue}
        end,
    FilterList = [{Rank, RankData} || {Rank, RankData} <- RankList, RankData =/= false],
    Send = #m__rank__get_rank__s2l{rank_type = RankType,
                                   start_rank = StartRank,
                                   end_rank = EndRank,
                                   rank_list = lists:map(FunConver, FilterList)},
    net_send:send(Send, Player),
    {ok, Player}.

%%%====================================================================
%%% Internal functions
%%%====================================================================
