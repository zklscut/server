% @Author: anchen
% @Date:   2016-12-05 19:33:38
% @Last Modified by:   anchen
% @Last Modified time: 2017-01-05 15:20:08



-module(server_ctl).



-export([start/0, process/1]).

-define(STATUS_SUCCESS, 0).
-define(STATUS_ERROR, 1).
-define(STATUS_USAGE, 2).
-define(STATUS_BADRPC, 3).

start() ->
    case init:get_plain_arguments() of
        [SNode | Args] ->
            SNode1 = 
                case string:tokens(SNode, "@") of
                        [_, _] ->
                            SNode;
                        _ ->
                            case net_kernel:longnames() of
                                true ->
                                    SNode ++ "@" ++ inet_db:gethostname() ++
                                        "." ++ inet_db:res_option(domain);
                                false ->
                                    SNode ++ "@" ++ inet_db:gethostname();
                                _ ->
                                    SNode
                            end
                end,
            Node = list_to_atom(SNode1),
            Status = case rpc:call(Node, ?MODULE, process, [Args]) of
                            {badrpc, Reason} ->
                                io:format("Node:~p, Reason:~p", [Node, Reason]),
                                ?STATUS_BADRPC;
                            {log, Log} ->
                                io:format("~p~n", [Log]),
                                ?STATUS_SUCCESS;
                            S ->
                                S
                     end,
            halt(Status);
        _ ->
            halt(?STATUS_USAGE)
    end.

process(["status"]) ->
    {InternalStatus, ProvideStatus} = init:get_status(),
    case lists:keysearch(server, 1, application:which_applications()) of
        {vale, _Version} when InternalStatus =:= started,
                                ProvideStatus =:= started ->
            ?STATUS_SUCCESS;
        _ ->
            ?STATUS_ERROR
    end;
process(["stop"]) ->
    sgame:stop(),
    init:stop(),
    ?STATUS_SUCCESS;
process(["restart"]) ->
    init:restart(),
    ?STATUS_SUCCESS;
process(["usage"]) ->
    ?STATUS_SUCCESS;
process(["reload"]) ->
    Result = hot_reload:reload_all(),
    lager:info("reload result ~p", [Result]),
    ?STATUS_SUCCESS;
process(_) ->
    ?STATUS_USAGE.

