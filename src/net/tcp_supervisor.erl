%% @author zhangkl@lilith
%% @doc tcp_listener.
%% 2016

-module(tcp_supervisor).
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
    Element = {tcp_listener, {tcp_listener, start_listener_process, []},
               transient, brutal_kill, worker, [tcp_accepter]},
    {ok, {{simple_one_for_one, 10, 10}, [Element]}}. 

%% ====================================================================
%% Internal functions
%% ====================================================================


