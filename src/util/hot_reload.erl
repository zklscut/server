%% Author: zhangkl
%% Created: Nov 27, 2013

-module(hot_reload).

-export([l/1,reload_all/0]).

%% ====================================================================
%% Include files
%% ====================================================================

-include("logger.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
%% @doc reload file or files list
l(Module) when is_atom(Module) -> l_a(Module);
l(Module) when is_list(Module) -> l_l(Module);
l(_) -> ?ERR(load, "error cmd", []).

l_a(Module) ->
	code:soft_purge(Module) andalso code:load_file(Module).
l_l(Modules) ->
	[l_a(Module) || Module <- Modules].


%% @doc reload all files
reload_all() ->
    ModuleList = code:all_loaded(),
    
    FunReload = fun({Module, ModulePath},{CurSucessList, CurFailList}) ->
            try
                case ModulePath of
                    preloaded ->
                        throw(ignore);
                    _ ->
                        ok
                end,

                case code:soft_purge(Module) of
                    true -> 
                        case code:is_sticky(Module) of
                            false ->
                                code:load_file(Module);
                            true ->
                                ignore
                        end,
                        {[Module] ++ CurSucessList, CurFailList};
                    false ->
                        {CurSucessList, [Module] ++ CurFailList}
                end
            catch
                throw:ignore ->
                    {CurSucessList, CurFailList};
                T:R ->
                    ?DEBUG(reload_all, "Type:~p, Reason:~p", [T, R])
            end
    end,

    ReloadResult = lists:foldl(FunReload, {[],[]}, ModuleList),
    crontab:reload(),
    spawn(fun() ->
                  lib_clean_cache:clean_cache_in_list()
          end),
    ReloadResult.

%% ====================================================================
%% Internal functions
%% ====================================================================


