%% @author zhangkl
%% @doc mod_chat.
%% 2016

-module(mod_chat).
-export([]).

-include("game_pb.hrl").
-include("chat.hrl").

%% ====================================================================
%% API functions
%% ====================================================================

public_speak(#m__chat__public_speak__l2s{
                        chat_type = ChatType,
                        voice = Voice,
                        content = Content}, Player) ->
    ok.

%%%====================================================================
%%% Internal functions
%%%====================================================================