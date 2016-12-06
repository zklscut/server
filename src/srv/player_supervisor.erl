%% @author zhangkl@lilith
%% @doc player_supervisor.
%% 2016

-module(player_supervisor).
-behaviour(supervisor).
-export([init/1]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/0]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ====================================================================
%% Behavioural functions
%% ====================================================================

init([]) ->
    Element = {player_srv, {player_srv, start_link, []},
               transient, brutal_kill, worker, [tcp_accepter]},
    {ok, {{simple_one_for_one, 10, 10}, [Element]}}. 

%% ====================================================================
%% Internal functions
%% ====================================================================


