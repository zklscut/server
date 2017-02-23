% @Author: anchen
% @Date:   2017-02-20 14:35:57
% @Last Modified by:   anchen
% @Last Modified time: 2017-02-21 17:48:14

-module(mod_resource).

-include("resource.hrl").
-include("game_pb.hrl").

-export([increase/4,
         increase_list/3,
         decrease/4,
         is_enough/3,
         get_num/2,
         get_p_resource_list/1]).

%% ====================================================================
%% API functions
%% ====================================================================

increase(ResourceId, Num, LogAction, PlayerId) when is_integer(PlayerId) ->
    increase(ResourceId, Num, LogAction, lib_player:get_player(PlayerId));

increase(_, 0, _, Player) ->
    Player;

increase(ResourceId, Num, LogAction, Player) ->
    PreNum = get_num(ResourceId, Player),
    NewNum = PreNum + Num,
    PlayerAfterIncrease = set_num(ResourceId, NewNum, LogAction, Player),
    PlayerAfterHandler = handle_after_increase(ResourceId, PreNum, NewNum, LogAction, PlayerAfterIncrease),
    add_resource_log(ResourceId, PreNum, NewNum, PlayerAfterHandler),
    PlayerAfterHandler.

increase_list(ResourceList, LogAction, Player) ->
    FunIncrease = 
        fun({ResourceId, Num}, CurPlayer) ->
                increase(ResourceId, Num, LogAction, CurPlayer)
        end,
    lists:foldl(FunIncrease, Player, ResourceList).

decrease(ResourceId, Num, LogAction, PlayerId) when is_integer(PlayerId) ->
    decrease(ResourceId, Num, LogAction, lib_player:get_player(PlayerId));

decrease(_, 0, _, Player) ->
    Player;

decrease(ResourceId, Num, LogAction, Player) ->
    PreNum = get_num(ResourceId, Player),
    NewNum = 
        case PreNum >= Num of
            true ->
                NewNum = PreNum - Num;
            false ->
                0
        end,
    PlayerAfterDecrease = set_num(ResourceId, NewNum, LogAction, Player),   
    PlayerAfterHandler = handle_after_decrease(ResourceId, PreNum, NewNum, LogAction, PlayerAfterDecrease), 
    add_resource_log(ResourceId, PreNum, NewNum, PlayerAfterHandler),
    PlayerAfterHandler.

is_enough(ResourceId, Num, Player) ->
    get_num(ResourceId, Player) >= Num.

get_num(ResourceId, PlayerId) when is_integer(PlayerId) ->
    get_num(ResourceId, lib_player:get_player(PlayerId));

get_num(ResourceId, Player) ->
    ResourceList = get_resource_list(Player),
    maps:get(ResourceId, ResourceList, get_init_num(ResourceId)).

get_p_resource_list(Player) ->
    ResourceList = get_resource_list(Player),
    FunConver = 
        fun(ResourceId) ->
            #p_resource{resource_id = ResourceId,
                        num = get_num(ResourceId, Player)}
        end,
    lists:map(FunConver, maps:keys(ResourceList)).

%%%====================================================================
%%% Internal functions
%%%====================================================================

get_init_num(_) ->
    0.

set_num(ResourceId, Num, LogAction, Player) ->
    Send = #m__resource__push__s2l{resource_id = ResourceId,
                                   num = Num,
                                   action_id = LogAction},
    net_send:send(Send, Player),
    NewResourceList = maps:put(ResourceId, Num, get_resource_list(Player)),
    update_resource_list(NewResourceList, Player).

get_resource_list(Player) ->
    maps:get(resource, maps:get(data, Player), #{}).

update_resource_list(Resource, Player) ->
    NewData = maps:put(resource, Resource, maps:get(data, Player)),
    maps:put(data, NewData, Player).

handle_after_increase(?RESOURCE_EXP, _PreNum, NewNum, LogAction, Player) ->
    CurLv = get_num(?RESOURCE_LV, Player),
    case NewNum > b_exp:get(CurLv) of
        true ->
            set_num(?RESOURCE_LV, CurLv + 1, LogAction, Player);
        false ->
            Player
    end;
handle_after_increase(_, _, _, _, Player) ->
    Player.

handle_after_decrease(_, _, _, _, Player) ->
    Player.

add_resource_log(_, _, _, _) ->
    ignore.
