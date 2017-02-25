% @Author: anchen
% @Date:   2017-02-20 15:31:26
% @Last Modified by:   anchen
% @Last Modified time: 2017-02-20 15:32:02


-module(b_gift_effects).
-export([get/1]).
get(1)->
    {0, 10};
get(2) ->
    {0, 100};
get(3) ->
    {1, 10};
get(4) ->
    {1, 100};
get(5) ->
    {0, 100};
get(6) ->
    {1, 1000};
get(7) ->
    {1, 100};
get(8) ->
    {1, 1000};
get(_) ->
    {0, 0}.