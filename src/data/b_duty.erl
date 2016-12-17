-module(b_duty).
-export([get/1]).

-include("fight.hrl").

get(6) -> [{?DUTY_LANGREN, 2}, {?DUTY_NVWU, 1}, {?DUTY_PINGMIN, 3}]; 
get(7) -> [{?DUTY_LANGREN, 2}, {?DUTY_NVWU, 1}, {?DUTY_PINGMIN, 4}]; 
get(8) -> [{?DUTY_LANGREN, 2}, {?DUTY_NVWU, 1}, {?DUTY_QIUBITE, 1}, {?DUTY_PINGMIN, 4}]; 
get(9) -> [{?DUTY_LANGREN, 2}, {?DUTY_NVWU, 1}, {?DUTY_QIUBITE, 1}, {?DUTY_PINGMIN, 5}]; 
get(16) -> [{?DUTY_LANGREN, 5}, {?DUTY_YUYANJIA, 1}, {?DUTY_NVWU, 1}, {?DUTY_QIUBITE, 1}, 
            {?DUTY_SHOUWEI, 1}, {?DUTY_DAOZEI, 1}, {?DUTY_HUNXUEER, 1}, {?DUTY_PINGMIN, 7}]; 
get(_) -> undefined. 
