-module(proto_make).

-define(PROTO_PATH, "./").
-define(OUTPUT_INCLUDE_DIR, "../server/include/protobuf").
-define(OUTPUT_EBIN_DIR, "../server/ebin").

-define(OUTPUT_SRC_DIR, "../server/src/protobuf/proto_src").

-export([gen/0, gen_ebin/0, gen_src/0]).

gen() ->
    gen_ebin(),
    gen_src().

gen_ebin() ->
    file:make_dir(?OUTPUT_INCLUDE_DIR),
    case file:list_dir(?PROTO_PATH) of
    {ok, FileNameList} ->
        F = fun(ProtoFile) ->
                case is_proto_file(ProtoFile) of
                true ->
                    ProtoFilePath = ?PROTO_PATH ++ ProtoFile,
                    protobuffs_compile:scan_file(ProtoFilePath,
                                                 [{output_include_dir, ?OUTPUT_INCLUDE_DIR},
                                                  {output_ebin_dir, ?OUTPUT_EBIN_DIR}]);
                _ ->
                    skip
                end
            end,
        [F(X) || X <- FileNameList];
    {error, Reason} ->
        io:format("Cannot list_dir ~s ~p~n", [?PROTO_PATH, Reason])
     end.

gen_src() ->
    file:make_dir(?OUTPUT_INCLUDE_DIR),
    file:make_dir(?OUTPUT_SRC_DIR),
    case file:list_dir(?PROTO_PATH) of
    {ok, FileNameList} ->
        F = fun(ProtoFile) ->
                case is_proto_file(ProtoFile) of
                true ->
                    ProtoFilePath = ?PROTO_PATH ++ ProtoFile,
                    protobuffs_compile:generate_source(ProtoFilePath,
                                                 [{output_include_dir, ?OUTPUT_INCLUDE_DIR},
                                                  {output_src_dir, ?OUTPUT_SRC_DIR}]);
                _ ->
                    skip
                end
            end,
        [F(X) || X <- FileNameList],
        erlang:halt();
    {error, Reason} ->
        io:format("Cannot list_dir ~s ~p~n", [?PROTO_PATH, Reason])
     end.

is_proto_file(FileName) ->
    case filename:extension(FileName) of
    ".proto" ->
        true;
    _ ->
        false
    end.
