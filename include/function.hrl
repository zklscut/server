-ifndef(FUNCTION_HRL).
-define(FUNCTION_HRL, true).

-define(IF(C, A, B), (case (C) of
                        true ->
                            (A);
                        false ->
                            (B)
                       end)).

-define(ASSERT(C, E), (case (C) of
                        true ->
                            ok;
                        false ->
                            throw(E)
                       end)).

-endif.
