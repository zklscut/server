-module(b_fight_op_wait).
-export([get/1]).
get(1)->
	{20000, 20000};
get(2)->
	{20000, 20000};
get(3)->
	{20000, 20000};
get(4)->
	{20000, 20000};
get(5)->
	{20000, 10000};
get(6)->
	{20000, 10000};
get(7)->
	{20000, 10000};
get(8)->
	{20000, 10000};
get(10)->
	{20000, 20000};
get(11)->
	{20000, 20000};
get(13)->
	{20000, 20000};
get(1001)->
	{20000, 20000};
get(1002)->
	{20000, 20000};
get(1003)->
	{20000, 20000};
get(1004)->
	{60000, 45000};
get(1005)->
	{20000, 10000};
get(1007)->
	{60000, 45000};
get(1008)->
	{20000, 20000};
get(1009)->
	{60000, 45000};
get(1010)->
	{60000, 45000};
get(1011)->
	{60000, 45000};
get(1012)->
	{20000, 20000};
get(1013)->
	{20000, 20000};
get(1014)->
	{10000, 10000};
get(1015)->
	{20000, 20000};
get(1018)->
	{20000, 20000};
get(1019)->
	{20000, 20000};
get(2001)->
	{20000, 20000};
get(2002)->
	{20000, 20000};
get(2004)->
	{20000, 20000};
get(2007)->
	{20000, 20000};
get(_) -> 
	{0,0}. 
