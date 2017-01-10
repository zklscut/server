%% @author zhangkl
%% @doc util.
%% 2016

-module(util).
-export([rand/2,
         rand_list/1,
         rand_in_list/1,
         rand_in_list/2,
         index_of_list/2,
         part_list/2,
         conver_bool_to_int/1]).


%% ====================================================================
%% API functions
%% ====================================================================

%%产生一个From 到To之间的一个随机数
rand(From, To)->
    InitSeed = erlang:timestamp(),
    {SeedA,SeedB,SeedC} = InitSeed,
    NewSeed = {SeedA * SeedA ,SeedB * SeedB, SeedC * SeedC},
    random:seed(NewSeed),
    M = From - 1,
    random:uniform(To - M) + M.

rand_list(List) ->
    rand_in_list(List, length(List)).    

rand_in_list(List) ->
    Length = length(List),
    case Length of
        0 ->
            null;
        _ ->
            Nth = util:rand(1, Length),
            lists:nth(Nth, List)
    end.

%% 从列表中随机取几个不一样的值出来， 若GetAccount的长度大于或等于List的长度则起的作用就是随机打乱List的值
%% (List, GetAccount) -> List
rand_in_list(List, GetAccount) ->
    Fun = fun(_Item, RL) ->  
              [OldResult, OldList] = RL,
              if 
                  length(OldResult) >= GetAccount ->
                      throw(OldResult);
                  true ->
                      Ran = util:rand(1, length(OldList)),                       
                      RanItem = lists:nth(Ran, OldList),
                      NewResult = [RanItem | OldResult],
                      NewList = lists:delete(RanItem, OldList),
                      [NewResult, NewList]
              end
          end,       
    try
        Acc1 = lists:foldl(Fun, [[], List], List),
        hd(Acc1)
    catch
        throw:Data ->
            Data
    end.

index_of_list(Elem, List) ->
    Pred = fun(A, CurNth) ->
                   case A of
                       Elem ->
                           throw(CurNth);
                       _ ->
                           CurNth + 1
                   end
           end,
    try
        lists:foldl(Pred, 1, List),
        undefined
    catch
        throw:Nth ->
            Nth;
        _:_ ->
            undefined
    end.

part_list(Elem, List) ->
    Index = index_of_list(Elem, List),
    case Index of
        undefined ->
            {List, []};
        _ ->
            lists:split(Index, List)
    end.

conver_bool_to_int(Bool) ->
    case Bool of
        true ->
            1;
        false ->
            0
    end.


%%%====================================================================
%%% Internal functions
%%%====================================================================