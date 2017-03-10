-ifndef(MATCH_HRL).
-define(MATCH_HRL, true).

-define(MATCH_DATA, #{
                      last_match_time => 0,
                      wait_list => #{}, %%WaitId = {}
                      player_info => #{}, %%PlayerId = {MatchPlayerId, WaitId}
                      match_list => [] %%[{MatchPlayerId, PlayerList, Rank, IsWait},.....]
                      }).

-define(MATCH_NEED_PLAYER_NUM, 3).
-define(MATCH_MIN_DIFF_RANK, 400).
-define(MATCH_TIMETICK, 500).
-define(MATCH_TIMEOUT, 10000).

-endif.