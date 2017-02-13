-ifndef(FUNCTION_HRL).
-define(FUNCTION_HRL, true).

-define(IF(C, A, B), (case (C) of
                        true ->
                            (A);
                        false ->
                            (B)
                       end)).

-endif.
