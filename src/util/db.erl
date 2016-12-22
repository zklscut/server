%%%-----------------------------------------------------------------------------
%%% @author zhangkl
%%% @copyright 2014 4399
%%% @doc
%%%
%%% @end
%%%-----------------------------------------------------------------------------

-module(db).
-export([execute/1,
         execute/2,
         execute_log/1,
         get_one/1,
         get_one_in_log_db/1,
         get_row/1,
         get_row_in_log_db/1,
         get_all/1,
         make_insert_sql/3,
         make_batch_insert_sql/3,
         make_delete_sql/3, 
         make_replace_sql/3,
         make_batch_replace_sql/3,
         make_update_sql/5,
         make_select_sql/4,
         make_select_sql/5,
         make_in_sql/1,
         make_insert_sql_from_array/2,
         make_update_sql_from_array/3,
         make_select_sql_from_array/3
        ]).

-include("db.hrl").

%%define a timeout for gen server call
-define(TIMEOUT, 60*1000).


%%--------------------------------------------------------------------
%% @doc 执行一条sql语句，Connection是数据库类型(?DB_READ或?DB_WRITE)，默认?DB_READ
%% @spec execute(Connection, Sql) -> {ok, Result} | error
%% @end
%%-------------------------------------------------------------------- 
execute(Sql) ->
    execute(?DB_WRITE, Sql).

execute(_Connection, "") ->
    ignore;

execute(Connection, Sql) ->
    case emysql:execute(Connection, Sql) of
        {result_packet, _, _RowInfo, Data, <<>>} ->
            {ok, Data};
        {ok_packet, _, RowEffect, _Warning, _, _, _Msg} ->
            {ok, RowEffect};
        {error_packet, _, _, _, What} ->
            lager:error("[Database Error]: ~nQuery:~s~n, Error:~s", [Sql, What]),
            {err, What}
    end.

execute_log(Sql) ->
    spawn(fun() ->
                  emysql:execute(?DB_LOG, Sql)
          end).

%% 进能查询一行的一个字段，e.g. "select nickname from tuser where AccountName = 'xxx';"
%% 未找到时返回null
get_one(Sql) ->
    case execute(?DB_READ, Sql) of
        {ok, []} -> null;
        {ok, [[R]]} -> R;
        {err, What} -> mysql_halt([Sql, What])
    end.

%% return undefined if select sum() from empty tuple 
get_one_in_log_db(Sql) ->
    case execute(?DB_LOG, Sql) of
        {ok, []} -> null;
        {ok, [[undefined]]} -> null;
        {ok, [[R]]} -> R;
        {err, What} -> mysql_halt([Sql, What])
    end.

%% 取出查询结果中的第一行
%% 例子：
%% Sql = "SELECT id, AccountName, nickname, family_name, EXP,LEVEL FROM tuser WHERE AccountName = \'" ++ Accname ++ "\'",
%% Row = db:get_row(Sql),
%%   -->Row: [16271,<<"ymc">>,<<"ymc">>,<<>>,230,2] | []

get_row(Sql) ->
    case execute(?DB_READ, Sql) of
        {ok, []} -> [];
        {ok, R} -> hd(R);
        {err, What} -> mysql_halt([Sql, What])
    end.

get_row_in_log_db(Sql) ->
    case execute(?DB_LOG, Sql) of
        {ok, []} -> [];
        {ok, R} -> hd(R);
        {err, What} -> mysql_halt([Sql, What])
    end.

%% 取出查询结果中的所有行
get_all(Sql) ->
    case execute(?DB_READ, Sql) of
        {ok, Data} -> Data;
        {err, What} -> mysql_halt([Sql, What])
    end.

%% @doc 显示人可以看得懂的错误信息
mysql_halt([Sql, Reason]) ->
    erlang:error({db_error, [Sql, Reason]}).

%%组合mysql select语句
%%使用方式:
%% make_select_sql("select col1, col2 from", table_test, ["row","r"], ["测试",123]) 相当于 
%% "select col1, col2 from test where `row` = '测试' and `r` = '123'"
%%Table:表名
%%Field:字段名list
%%Data:数据list
make_select_sql(SelectFrom, Table, Field, Data) ->
    L = make_and_sql(Field, Data, []),
    lists:concat([SelectFrom, " ", Table, " where ", L]).

%%组合mysql select语句
%%使用方式:
%% make_delete_sql(table_test, ["row","r"], ["测试",123]) 相当于 
%% "delete from test where `row` = '测试' and `r` = '123'"
%%Table:表名
%%Field:字段名list
%%Data:数据list
make_delete_sql(Table, Field, Data) ->
    L = make_and_sql(Field, Data, []),
    lists:concat( ["DELETE FROM ", Table, " WHERE ", L] ).


%%组合mysql insert语句
%%使用方式make_insert_sql(test,["row","r"],["测试",123]) 相当 insert into test set `row` = '测试', `r` = '123'
%%Table:表名
%%Field:字段名list
%%Data:数据list
make_insert_sql(Table, Field, Data) ->
    L = make_conn_sql(Field, Data, []),
    lists:concat(["insert into ", Table, " set ", L]).

make_batch_insert_sql(_Table, _Field, Data) when Data =:= [] ->
    "";
make_batch_insert_sql(Table, Field, Data) ->
    FileSql = conver_to_sql_format(Field, false),
    BatchValue = make_batch_values(Data),
    lists:concat(["insert into ", Table, " ",FileSql, " values ", BatchValue]).

%%组合mysql replace语句
%%使用方式make_replace_sql(test,["row","r"],["测试",123]) 相当 replace into test (`row`,`r`) values('测试','123')
%%Table:表名
%%Field:字段名list
%%Data:数据list
make_replace_sql(Table, Field, Data) ->
    L = make_conn_sql(Field, Data, []),
    lists:concat(["replace into ", Table, " set ", L]).

make_batch_replace_sql(_Table, _Field, Data) when Data =:= [] ->
    "";

make_batch_replace_sql(_Table, _Field, [[]]) ->
    "";

make_batch_replace_sql(Table, Field, Data) ->
    FileSql = conver_to_sql_format(Field, false),
    BatchValue = make_batch_values(Data),
    lists:concat(["replace into ", Table, " ",FileSql, " values ", BatchValue]).

make_batch_values([]) ->
    "";

make_batch_values(DataList) ->
    make_batch_values(DataList, "").

make_batch_values([Data | []], CurSql) ->
    lists:concat([CurSql, conver_to_sql_format(Data, true)]);

make_batch_values([Data | T], CurSql) ->
    NewSql = lists:concat([CurSql, conver_to_sql_format(Data, true), ","]),
    make_batch_values(T, NewSql).

%%组合mysql update语句
%%使用方式make_update_sql(test,["row","r"],["测试",123],["id", "name"],[1, "pp"]) 相当 update test set `row`='测试', `r` = '123' where `id` = '1' and `name` = 'pp'
%%Table:表名
%%Field:字段
%%Data:数据
%%Key:键
%%Data:值
make_update_sql(Table, Field, Data, Key, Value) ->
    L = make_conn_sql(Field, Data, []),
    W = make_and_sql(Key, Value, []),
    lists:concat(["update ", Table, " set ", L, " where ", W]).

%%--------------------------------------------------------------------
%% @doc 组合mysql select 语句 
%%   eg.: make_select_sql_from_array("select * from", tuser, [{"nickname", "mingchaoyoan"}, {"level", 9}])
%%    等价于： select * from tuser where nickname = 'mingchao' and level = 9
%% @spec make_select_sql_from_array(SelectFrom::string(), Table::atom(), FileDataList::TupleList()) -> Sql::string()
%% @end
%%--------------------------------------------------------------------
make_select_sql_from_array(SelectFrom, Table, FieldDataList) ->
    {FieldList, DataList} = lists:unzip(FieldDataList),
    make_select_sql(SelectFrom, Table, FieldList, DataList).

%%表名，选择出来的列名，条件列名，条件，条件变量
%%  
%%      make_select_sql(tuser,
%%                  [id,p,a,"sum(b)"],
%%                  [id,p,a,"sum(b)"],
%%                  [">","<","=","="],
%%                  [1,2,3,4]).
%%       相当于
%%       "select id,p,a,sum(b) 
%%        from tuser 
%%        where 1=1 and id>1 and p<2 and a=3"
%%        
%%        输入条件有 "in"时 只能使用 "in"不能带空格
make_select_sql(TableName,RowName,SRowName,Condition,Variable)
        ->
    NS = length(SRowName) ,
    NC = length(Condition),
    NV = length(Variable) ,
    case NS =:= NC andalso NS =:= NV of
        true -> make_select_sql("select ",TableName,RowName,SRowName,Condition,Variable);
        false -> {error,contionLength}
    end.


make_select_sql(CurSql,[],[],[],[],[])
        ->CurSql;

make_select_sql(CurSql,[],[],[SRowName|RT],[Condition|CT],[Variable|VT])
        -> 
    AddSql=
            case erlang:is_number(Variable) of 
        true  -> lists:concat([" and ",SRowName,Condition,Variable]);
        false ->
            case Condition =:= "in" of
                true -> lists:concat([" and ",SRowName," in ",Variable]);
                false -> lists:concat([" and ",SRowName,Condition,"'",Variable,"'"])
            end
    end,

    Sql = lists:concat([CurSql,AddSql]),
    make_select_sql(Sql,[],[],RT,CT,VT);


make_select_sql(CurSql,TableName,[],SRowName,Condition,Variable)
        -> AddSql = lists:concat(["from ",TableName," where 1=1"]) ,
    Sql = lists:concat([CurSql,AddSql]),
    make_select_sql(Sql,[],[],SRowName,Condition,Variable);


make_select_sql(CurSql,TableName,[H|T],SRowName,Condition,Variable)
        ->
    AddSql =
             case T =:= [] of 
        true  -> lists:concat([H," "]);
        false -> lists:concat([H,","])
    end,
    Sql = lists:concat([CurSql,AddSql]),
    make_select_sql(Sql,TableName,T,SRowName,Condition,Variable).

make_in_sql(Data) ->
    conver_to_sql_format(Data, true).

conver_to_sql_format([], _IsConverString) ->
    "()";
conver_to_sql_format(ConditionList, IsConverString) ->
    conver_to_sql_format("(", ConditionList, IsConverString).
conver_to_sql_format(InitSql, [Condition | T], IsConverString) when T =:= [] ->
    lists:concat([InitSql, conver_sql_string(Condition, IsConverString), ")"]);

%% conver_to_sql_format(InitSql, [[] | T], IsConverString) ->
%%     conver_to_sql_format(InitSql, T, IsConverString);

conver_to_sql_format(InitSql, [Condition | T], IsConverString) ->
    conver_to_sql_format(lists:concat([InitSql, conver_sql_string(Condition, IsConverString), ","]), T, IsConverString).
    
conver_sql_string(Sql, IsConverString) ->
    case IsConverString of
        false ->
            Sql;
        true ->
            case is_number(Sql)of
                true ->
                    Sql;
                false ->
                    case is_binary(Sql) of
                        true ->
                            lists:concat(["\'", binary_to_list(Sql), "\'"]);
                        false ->
                            lists:concat(["\'", sql_format(Sql), "\'"])
                    end
            end
    end.

%%组合mysql insert语句
%%使用方式make_insert_sql_from_array(test,[{"row", "测试"},{"r", 123}] 相当 insert into test set `row` = '测试', `r` = '123'
%%Table:表名
%%FieldDataList:[ {字段，数据}， ...... ]
make_insert_sql_from_array(Table, FieldDataList) ->
    {FieldList, DataList} = lists:unzip(FieldDataList),
    make_insert_sql(Table, FieldList, DataList).

%%组合mysql update语句
%%使用方式make_update_sql_from_array(test,[{"row", "测试"},{"r", 123},{"id", zhou}], "id") 相当 update test set `row` = '测试', `r` = '123' where `id` = zhou
%%Table:表名
%%FieldDataList:[ {字段，数据}， ...... ]
make_update_sql_from_array(Table, FieldDataList, Key) -> 
    %% 把匹配条件取出来
    {_, {Key, KeyVal}, RealFieldDataList} = lists:keytake(Key, 1, FieldDataList),

    {FieldList, DataList} = lists:unzip(RealFieldDataList),

    make_update_sql(Table, FieldList, DataList, [Key], [KeyVal]).

make_and_sql([], _, L) ->
    L ;
make_and_sql(_, [], L) ->
    L ;
make_and_sql([F | T1], [D | T2], []) ->
    L  = ["`", F,"` = '", sql_format(D), "'"],
    make_and_sql(T1, T2, L);
make_and_sql([F | T1], [D | T2], L) ->
    L1  = L ++ [" and `", F,"` = '", sql_format(D), "'"],
    make_and_sql(T1, T2, L1).

make_conn_sql([], _, L ) ->
    L ;
make_conn_sql(_, [], L ) ->
    L ;
make_conn_sql([F | T1], [D | T2], []) ->
    L  = ["`", F,"` = '",sql_format(D),"'"],
    make_conn_sql(T1, T2, L);
make_conn_sql([F | T1], [D | T2], L) ->
    L1  = L ++ [",`", F,"` = '",sql_format(D),"'"],
    make_conn_sql(T1, T2, L1).

sql_format(S) when is_integer(S)->
    integer_to_list(S);
sql_format(S) when is_float(S)->
    float_to_list(S);
sql_format(S) when is_list(S) ->
    sql_str_escape(S, "");
sql_format(S) ->
    S.

sql_str_escape([], Acc) ->
    lists:reverse(Acc);
sql_str_escape([H | T], Acc) ->
    NewAcc = 
             case H of
        $"  -> [H, $\\ | Acc];
        $'  -> [H, $\\ | Acc];
        $\\ -> [H, $\\ | Acc];
        _   -> [H | Acc]
    end,
    sql_str_escape(T, NewAcc);

sql_str_escape(<<>>, Acc) ->
    Acc;
sql_str_escape(<<H:8, T/binary>>, Acc) ->
    NewAcc = 
             case H of
        $"  -> <<Acc/binary, $\\:8, H:8>>;
        $'  -> <<Acc/binary, $\\:8, H:8>>;
        $\\ -> <<Acc/binary, $\\:8, H:8>>;
        _   -> <<Acc/binary, H:8>>
    end,
    sql_str_escape(T, NewAcc).
