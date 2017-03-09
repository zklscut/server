-ifndef(MATCH_HRL).
-define(MATCH_HRL, true).

-define(MATCH_DATA, #{match_num => 0,
                      last_match_time => 0,
                      wait_list => [],
                      player_info => [], %%[{PlayerId, MatchPlayerId, WaitId},.....]
                      match_list => [] %%[{MatchPlayerId, PlayerList, Rank, IsWait},.....]
                      }).

-define(MATCH_NEED_PLAYER_NUM, 12).
-define(MATCH_MIN_DIFF_RANK, 400).

-define(MATCH_TIMEOUT, 20000).

-endif.