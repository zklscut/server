%% Author: zkl
%% Created: 2013-10-9

-module(lib_ets).

%% ====================================================================
%% External exports
%% ====================================================================

-export([get/2,
         update/3,
         delete/2,
         delete_all/1,
         fetch/2,
         store/4,
         get_all_ets_key/1
         ]).

%% ====================================================================
%% Include files
%% ====================================================================


%% ====================================================================
%% API functions
%% ====================================================================

get(EtsName, Key) ->
    case ets:lookup(EtsName, Key) of
        []->
            undefined;
        [{Key, Value}]->
            Value
    end.


update(EtsName,Key,Value) ->
    ets:insert(EtsName, {Key, Value}).
    
%% (EtsName, Key) -> true | undefined
delete(EtsName, Key) ->
    EtsTable = ets:info(EtsName),
    if
        EtsTable =:= undefined ->
            undefined;
        true ->
            ets:delete(EtsName, Key)
    end.

delete_all(EtsName) ->
    ets:delete_all_objects(EtsName).

fetch(EtsName, Key) ->
    case get(EtsName, Key) of
        undefined -> 
            undefined;
        {Value, ToTime} ->
            case ToTime > utils:unixtime() of   
                true  -> 
                    Value;
                false -> 
                    case ToTime of
                        -1 -> 
                            Value;    
                        _  -> 
                            delete(EtsName, Key), 
                            undefined
                    end
            end
    end.

store(EtsName, Key, Value, TTL) ->
    ToTime = 
        case TTL >= 0 of
            true  -> TTL;
            false -> -1 
        end,
    update(EtsName, Key, {Value, ToTime}).

get_all_ets_key(EtsName) ->
    lists:flatten(ets:match(EtsName, {'$1', '_'})).

%% ====================================================================
%% Behavioural functions
%% ====================================================================


