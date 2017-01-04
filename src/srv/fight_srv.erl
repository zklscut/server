%% @author zhangkl
%% @doc fight_srv.
%% 2016

-module(fight_srv).
-behaviour(gen_fsm).
-export([init/1, 
        state_name/3, 
        handle_event/3, 
        handle_sync_event/4, 
        handle_info/3, 
        terminate/3, 
        code_change/4]).

-export([state_daozei/2,
         state_qiubite/2,
         state_hunxueer/2,
         state_shouwei/2,
         state_langren/2,
         state_nvwu/2,
         state_yuyanjia/2,
         state_part_jingzhang/2,
         state_part_fayan/2,
         state_xuanju_jingzhang/2,
         state_night_death/2,
         state_jingzhang/2,
         state_fayan/2,
         state_guipiao/2,
         state_toupiao/2,
         state_toupiao_death/2,
         state_day/2,
         state_over/2]).

-include("fight.hrl").
-include("errcode.hrl").
-include("game_pb.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/3,
         player_op/4,
         player_speak/3,
         print_state/1]).

start_link(RoomId, PlayerList, DutyList) ->
    gen_fsm:start(?MODULE, [RoomId, PlayerList, DutyList, ?MFIGHT], []).

player_op(Pid, PlayerId, Op, OpList) ->
    gen_fsm:send_event(Pid, {player_op, PlayerId, Op, OpList}).

player_speak(Pid, PlayerId, Chat) ->
    gen_fsm:send_event(Pid, {player_op, PlayerId, ?OP_FAYAN, [Chat]}).    

print_state(Pid) ->
    gen_fsm:send_all_state_event(Pid, print_state).

%% ====================================================================
%% Behavioural functions
%% ====================================================================

init([RoomId, PlayerList, DutyList, State]) ->
    lib_room:update_fight_pid(RoomId, self()),
    NewState = lib_fight:init(RoomId, PlayerList, DutyList, State),
    notice_game_status_change(start, NewState),
    notice_duty(NewState),
    send_event_inner(start, b_fight_state_wait:get(start)),
    {ok, state_daozei, NewState}.

%% ====================================================================
%% state_daozei
%% ====================================================================
state_daozei(start, State) ->
    do_duty_state_start(?DUTY_DAOZEI, state_daozei, State);

state_daozei(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_DAOZEI, State),
    {next_state, state_daozei, NewState};

state_daozei({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_daozei, State);

state_daozei(timeout, State) ->
    DaozeiList = maps:get(daozei, State),
    Op = 
        case lists:member(?DUTY_LANGREN, DaozeiList) of
            true ->
                ?DUTY_LANGREN;
            false ->
                util:rand_in_list(DaozeiList)
        end,
    do_duty_op_timeout([Op], state_daozei, State);

state_daozei(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_daozei_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_daozei)),
    {next_state, get_next_game_state(state_daozei), NewState}.
            
%% ====================================================================
%% state_qiubite
%% ====================================================================
state_qiubite(start, State) ->
    do_duty_state_start(?DUTY_QIUBITE, state_qiubite, State);

state_qiubite(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_QIUBITE, State),
    {next_state, state_qiubite, NewState};

state_qiubite({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_qiubite, State);

state_qiubite(timeout, State) ->
    RandLover = util:rand_in_list(lib_fight:get_alive_seat_list(State) -- 
                                  lib_fight:get_duty_seat(?DUTY_QIUBITE, State), 2),
    do_duty_op_timeout(RandLover, state_qiubite, State);    
    
state_qiubite(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_qiubite_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_qiubite)),
    {next_state, get_next_game_state(state_qiubite), NewState}.

%% ====================================================================
%% state_hunxueer
%% ====================================================================
state_hunxueer(start, State) ->
    do_duty_state_start(?DUTY_HUNXUEER, state_hunxueer, State);

state_hunxueer(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_HUNXUEER, State),
    {next_state, state_hunxueer, NewState};

state_hunxueer({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_hunxueer, State);

state_hunxueer(timeout, State) ->
    RandTarger = util:rand_in_list(lib_fight:get_alive_seat_list(State) -- 
                                  lib_fight:get_duty_seat(?DUTY_HUNXUEER, State), 1),
    do_duty_op_timeout(RandTarger, state_hunxueer, State);    

state_hunxueer(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_hunxuer_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_hunxueer)),
    {next_state, get_next_game_state(state_hunxueer), NewState}.

%% ====================================================================
%% state_shouwei
%% ====================================================================
state_shouwei(start, State) ->
    do_duty_state_start(?DUTY_SHOUWEI, state_shouwei, State);

state_shouwei(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_SHOUWEI, State),
    {next_state, state_shouwei, NewState};

state_shouwei({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_shouwei, State);

state_shouwei(timeout, State) ->
    do_duty_op_timeout([0], state_shouwei, State);

state_shouwei(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_shouwei_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_shouwei)),
    {next_state, get_next_game_state(state_shouwei), NewState}.
            
%% ====================================================================
%% state_langren
%% ====================================================================
state_langren(start, State) ->
    do_duty_state_start(?DUTY_LANGREN, state_langren, State);

state_langren(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_LANGREN, State),
    {next_state, state_langren, NewState};

state_langren({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_langren, State);

state_langren(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_langren, State};

state_langren(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_langren_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_langren)),
    {next_state, get_next_game_state(state_langren), NewState}.
                 
%% ====================================================================
%% state_nvwu
%% ====================================================================
state_nvwu(start, State) ->
    do_duty_state_start(?DUTY_NVWU, state_nvwu, State);

state_nvwu(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_NVWU, State),
    {next_state, state_nvwu, NewState};

state_nvwu({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_nvwu, State);

state_nvwu(timeout, State) ->
    do_duty_op_timeout([0, 0], state_nvwu, State);

state_nvwu(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_nvwu_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_nvwu)),

    NextState = 
        case is_over(NewState) of
            true ->
                state_day;
            false ->
                get_next_game_state(state_nvwu)
        end,
    {next_state, NextState, NewState}.
            
%% ====================================================================
%% state_yuyanjia
%% ====================================================================
state_yuyanjia(start, State) ->
    do_duty_state_start(?DUTY_YUYANJIA, state_yuyanjia, State);

state_yuyanjia(wait_op, State) ->
    NewState = do_duty_state_wait_op(?DUTY_YUYANJIA, State),
    {next_state, state_yuyanjia, NewState};

state_yuyanjia({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_yuyanjia, State);

state_yuyanjia(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_yuyanjia, State};

state_yuyanjia(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_yuyanjia_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_yuyanjia)),
    NextState = 
        case maps:get(game_round, State) of
            1 ->
                get_next_game_state(state_yuyanjia);
            _ ->
                state_night_death
        end,
    {next_state, NextState, NewState}.

%% ====================================================================
%% state_part_jingzhang
%% ====================================================================

state_part_jingzhang(start, State) ->
    notice_game_status_change(state_part_jingzhang, State),
    send_event_inner(wait_op),
    {next_state, state_part_jingzhang, State};

state_part_jingzhang(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_PART_JINGZHANG)),
    notice_jingxuan_jingzhang(State),
    StateAfterWait = do_set_wait_op(lib_fight:get_alive_seat_list(State), State),
    {next_state, state_part_jingzhang, StateAfterWait};

state_part_jingzhang({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_part_jingzhang, State);

state_part_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_part_jingzhang, State};

state_part_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_part_jingzhang_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_part_jingzhang)),
    {next_state, get_next_game_state(state_part_jingzhang), NewState}. 

%% ====================================================================
%% state_part_fayan
%% ====================================================================

state_part_fayan(start, State) ->
    do_fayan_state_start(maps:get(part_jingzhang, State), state_part_fayan, State);

state_part_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_PART_FAYAN, state_part_fayan, State);

state_part_fayan({player_op, PlayerId, Op, [0]}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], state_part_fayan, State);

state_part_fayan({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    do_receive_fayan(PlayerId, Chat, State),
    {next_state, state_part_fayan, State};

state_part_fayan(timeout, State) ->
    do_fayan_state_timeout(state_part_fayan, State);

state_part_fayan(op_over, State) ->
    do_fayan_state_op_over(state_part_fayan, State).

%% ====================================================================
%% state_xuanju_jingzhang
%% ====================================================================
state_xuanju_jingzhang(start, State) ->
    case maps:get(part_jingzhang, State) of
        [] ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_xuanju_jingzhang), State};
        _ ->
            notice_game_status_change(state_xuanju_jingzhang, State),
            send_event_inner(wait_op),
            {next_state, state_xuanju_jingzhang, State}
    end;

state_xuanju_jingzhang(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_XUANJU_JINGZHANG)),
    notice_xuanju_jingzhang(State),
    WaitList = lib_fight:get_alive_seat_list(State) -- maps:get(part_jingzhang, State),
    StateAfterWait = do_set_wait_op(WaitList, State),
    {next_state, state_xuanju_jingzhang, StateAfterWait};    
    
state_xuanju_jingzhang({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_xuanju_jingzhang, State);

state_xuanju_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_xuanju_jingzhang, State};

state_xuanju_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, XuanjuResult, NewState} = lib_fight:do_xuanju_jingzhang_op(State#{xuanju_draw_cnt := 1}),
    notice_xuanju_jingzhang_result(IsDraw, maps:get(jingzhang, NewState), XuanjuResult, NewState),
    case IsDraw of
        true ->
            send_event_inner(wait_op),
            {next_state, state_xuanju_jingzhang, NewState};
        false ->   
            send_event_inner(start, b_fight_state_wait:get(state_xuanju_jingzhang)),
            {next_state, get_next_game_state(state_xuanju_jingzhang), NewState}
    end.     


%% ====================================================================
%% state_night_death
%% ====================================================================

state_night_death(start, State) ->
    notice_night_result(State),
    DieList = maps:get(die, State) ,
    case maps:get(game_round, State) of
        1 ->
            do_fayan_state_start(DieList, state_night_death, State);
        _ ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_night_death), State}
    end;

state_night_death(wait_op, State) ->
    do_fayan_state_wait_op(?OP_DEATH_FAYAN, state_night_death, State);

state_night_death({player_op, PlayerId, Op, [0]}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], state_night_death, State);

state_night_death({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    do_receive_fayan(PlayerId, Chat, State),
    {next_state, state_night_death, State};

state_night_death(timeout, State) ->
    do_fayan_state_timeout(state_night_death, State);

state_night_death(op_over, State) ->
    do_fayan_state_op_over(state_night_death, State).    

%% ====================================================================
%% state_jingzhang
%% ====================================================================
state_jingzhang(start, State) ->
    case maps:get(jingzhang, State, 0) of
        0 ->
            NewState = lib_fight:do_no_jingzhang_op(State),
            send_event_inner(start),
            {next_state, get_next_game_state(state_jingzhang), NewState};
        _ ->
            notice_game_status_change(state_jingzhang, State),
            send_event_inner(wait_op),
            {next_state, state_jingzhang, State}
    end;

state_jingzhang(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_JINGZHANG_ZHIDING)),
    JingZhang = maps:get(jingzhang, State),
    notice_player_op(?OP_JINGZHANG_ZHIDING, maps:get(die, State), [JingZhang], State),
    StateAfterWait = do_set_wait_op([JingZhang], State),
    {next_state, state_jingzhang, StateAfterWait}; 

state_jingzhang({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_jingzhang, State);

state_jingzhang(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_jingzhang, State};

state_jingzhang(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_jingzhang_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_jingzhang)),
    {next_state, get_next_game_state(state_jingzhang), NewState}.

%% ====================================================================
%% state_fayan
%% ====================================================================

state_fayan(start, State) ->
    do_fayan_state_start(maps:get(fayan_turn, State), state_fayan, State);

state_fayan(wait_op, State) ->
    do_fayan_state_wait_op(?OP_FAYAN, state_fayan, State);

state_fayan({player_op, PlayerId, Op, [0]}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], state_fayan, State);

state_fayan({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    do_receive_fayan(PlayerId, Chat, State),
    {next_state, state_fayan, State};

state_fayan(timeout, State) ->
    do_fayan_state_timeout(state_fayan, State);

state_fayan(op_over, State) ->
    do_fayan_state_op_over(state_fayan, State).
    
%% ====================================================================
%% state_guipiao
%% ====================================================================
state_guipiao(start, State) ->
    case maps:get(jingzhang, State, 0) of
        0 ->
            send_event_inner(start),
            {next_state, get_next_game_state(state_guipiao), State};
        _ ->
            notice_game_status_change(state_guipiao, State),
            send_event_inner(wait_op),
            {next_state, state_guipiao, State}
    end;

state_guipiao(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_GUIPIAO)),
    JingZhang = maps:get(jingzhang, State),
    notice_player_op(?OP_GUIPIAO, [JingZhang], State),
    StateAfterWait = do_set_wait_op([JingZhang], State),
    {next_state, state_guipiao, StateAfterWait}; 

state_guipiao({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_guipiao, State);

state_guipiao(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_guipiao, State};

state_guipiao(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    NewState = lib_fight:do_guipiao_op(State),
    send_event_inner(start, b_fight_state_wait:get(state_guipiao)),
    {next_state, get_next_game_state(state_guipiao), NewState}.

%% ====================================================================
%% state_toupiao
%% ====================================================================
state_toupiao(start, State) ->
    notice_game_status_change(state_toupiao, State),
    send_event_inner(wait_op),
    {next_state, state_toupiao, State};

state_toupiao(wait_op, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_TOUPIAO)),
    notice_toupiao(State),
    WaitList = lib_fight:get_alive_seat_list(State),
    StateAfterWait = do_set_wait_op(WaitList, State),
    {next_state, state_toupiao, StateAfterWait};    
    
state_toupiao({player_op, PlayerId, Op, OpList}, State) ->
    do_receive_player_op(PlayerId, Op, OpList, state_toupiao, State);

state_toupiao(timeout, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    send_event_inner(op_over),
    {next_state, state_toupiao, State};

state_toupiao(op_over, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    {IsDraw, TouPiaoResult, MaxSelectList, NewState} = lib_fight:do_toupiao_op(State),
    notice_state_toupiao_result(IsDraw, maps:get(quzhu, NewState), TouPiaoResult, NewState),
    case IsDraw of
        true ->
            notice_toupiao(MaxSelectList, NewState),
            StateAfterWait = do_set_wait_op(lib_fight:get_alive_seat_list(State) -- MaxSelectList, NewState),
            {next_state, state_toupiao, StateAfterWait};
        false ->   
            notice_toupiao_out(maps:get(quzhu, NewState), NewState),
            send_event_inner(start, b_fight_state_wait:get(state_toupiao)),
            NextState = 
                case is_over(NewState) of
                    true ->
                        state_day;
                    false ->
                        get_next_game_state(state_toupiao)
                end,
            {next_state, get_next_game_state(state_toupiao), NewState}
    end.  

%% ====================================================================
%% state_toupiao_death
%% ====================================================================

state_toupiao_death(start, State) ->
    do_fayan_state_start([maps:get(quzhu, State)], state_toupiao_death, State);

state_toupiao_death(wait_op, State) ->
    do_fayan_state_wait_op(?OP_QUZHU_FAYAN, state_toupiao_death, State);

state_toupiao_death({player_op, PlayerId, Op, [0]}, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    do_receive_player_op(PlayerId, Op, [0], state_toupiao_death, State);

state_toupiao_death({player_op, PlayerId, ?OP_FAYAN, [Chat]}, State) ->
    do_receive_fayan(PlayerId, Chat, State),
    {next_state, state_toupiao_death, State};

state_toupiao_death(timeout, State) ->
    do_fayan_state_timeout(state_toupiao_death, State);

state_toupiao_death(op_over, State) ->
    do_fayan_state_op_over(state_toupiao_death, State).

%% ====================================================================
%% state_day
%% ====================================================================
state_day(start, State) ->
    notice_game_status_change(state_day, State),
    NewState = out_die_player(State),
    {IsOver, Winner} = get_fight_result(NewState),
    case IsOver of
        true ->
            send_fight_result(Winner, NewState),
            send_event_inner(start, b_fight_state_wait:get(state_day)),
            {next_state, state_over, NewState};
        false ->
            send_event_inner(start, b_fight_state_wait:get(state_day)),
            {next_state, get_next_game_state(state_day), clear_night_op(NewState)}
    end.

%% ====================================================================
%% state_over
%% ====================================================================

state_over(start, State) ->
    {stop, normal, State}.


state_name(_Event, _From, StateData) ->
    Reply = next_state,
    {reply, Reply, state_name, StateData}.

handle_event(print_state, StateName, StateData) ->
    lager:info("state name ~p", [StateName]),
    lager:info("state data ~p", [StateData]),
    {next_state, StateName, StateData}.

handle_sync_event(_Event, _From, StateName, StateData) ->
    Reply = ok,
    {reply, Reply, StateName, StateData}.

handle_info(_Info, StateName, StateData) ->
    {next_state, StateName, StateData}.

terminate(_Reason, _StateName, _StatData) ->
    ok.

code_change(_OldVsn, StateName, StateData, _Extra) ->
    {ok, StateName, StateData}.


%% ====================================================================
%% gen_fsm Internal functions
%% ====================================================================

send_event_inner(Event) ->
    send_event_inner(Event, 0).

send_event_inner(Event, Time) ->
    gen_fsm:send_event_after(Time, Event).

%%启动一个gen_fsm定时器并将ref保存在进程字典
start_fight_fsm_event_timer(Event, Time) ->
    TimerRef = gen_fsm:send_event_after(Time, Event),
    put(Event, TimerRef).

%%取消一个gen_fsm定时器删除进程字典
cancel_fight_fsm_event_timer(Event) ->
    TimerRef = get(Event),
    case TimerRef of
        undefined ->
            ignore;
        _ ->
            gen_fsm:cancel_timer(TimerRef),
            erase(Event)
    end.

% send_event_to_fsm(Event, Player) ->
%     PlayerFightProcess = lib_room:get_fight_pid_by_player(Player),
%     case PlayerFightProcess of
%         undefined ->
%             ignore;
%         _ ->
%             gen_fsm:send_event(PlayerFightProcess, Event)
%     end.

% send_event_to_all_state(Event, Player) ->
%     PlayerFightProcess = lib_room:get_fight_pid_by_player(Player),
%     case PlayerFightProcess of
%         undefined ->
%             ignore;
%         _ ->
%             gen_fsm:send_all_state_event(PlayerFightProcess, Event)
%     end.

%% ====================================================================
%% Internal functions
%% ====================================================================

notice_duty(State) ->
    SeatDutyMap = maps:get(seat_duty_map, State),
    FunNotice = 
        fun(SeatId) ->
            Duty = maps:get(SeatId, SeatDutyMap),
            Send = #m__fight__notice_duty__s2l{duty = Duty,
                                               seat_id = SeatId},
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, maps:keys(SeatDutyMap)).

do_duty_state_start(Duty, GameState, State) ->
    SeatIdList = lib_fight:get_duty_seat(Duty, State),
    case SeatIdList of
        [] ->
            send_event_inner(start),
            {next_state, get_next_game_state(GameState), State};
        _ ->
            notice_game_status_change(GameState, State),
            send_event_inner(wait_op),
            {next_state, GameState, State}
    end.

do_duty_state_wait_op(Duty, State) ->
    case b_fight_op_wait:get(Duty) of
        0 ->
            ignore;
        WaitTime ->
            start_fight_fsm_event_timer(?TIMER_TIMEOUT, WaitTime)
    end,
    SeatIdList = lib_fight:get_duty_seat(Duty, State),
    notice_player_op(Duty, SeatIdList, State),
    do_set_wait_op(SeatIdList, State).

do_duty_op_timeout(OpList, StateName, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    SeatId = hd(maps:get(wait_op_list, State)),
    StateAfterLogOp = do_log_op(SeatId, OpList, State),
    {_, StateAfterWaitOp} = do_remove_wait_op(SeatId, StateAfterLogOp),
    send_event_inner(op_over),
    {next_state, StateName, StateAfterWaitOp}.

do_receive_player_op(PlayerId, Op, OpList, StateName, State) ->
    try
        assert_op_in_wait(PlayerId, State),
        assert_op_legal(Op, StateName),
        assert_op_fit(Op, OpList, State),
        SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
        StateAfterLogOp = do_log_op(SeatId, OpList, State),
        {IsWaitOver, StateAfterWaitOp} = do_remove_wait_op(SeatId, StateAfterLogOp),
        case IsWaitOver of
            true ->
                send_event_inner(op_over);
            false ->
                ignore
        end,
        {next_state, StateName, StateAfterWaitOp}
    catch 
        throw:ErrCode ->
            net_send:send_errcode(ErrCode, PlayerId),
            {next_state, StateName, State}
    end.

do_fayan_state_start(FayanList, StateName, State) ->
    case FayanList == [0] orelse FayanList == [] of
        true ->
            send_event_inner(start),
            {next_state, get_next_game_state(StateName), State};
        false ->
            notice_game_status_change(StateName, State),
            NewState = maps:put(fayan_turn, FayanList, State),
            send_event_inner(wait_op),
            {next_state, StateName, NewState}
    end.

do_fayan_state_wait_op(Op, StateName, State) ->
    start_fight_fsm_event_timer(?TIMER_TIMEOUT, b_fight_op_wait:get(?OP_FAYAN)),
    Fayan = hd(maps:get(fayan_turn, State)),
    notice_start_fayan(Fayan, State),
    notice_player_op(Op, [Fayan], State),
    StateAfterWait = do_set_wait_op([Fayan], State),
    {next_state, StateName, StateAfterWait}.

do_fayan_state_timeout(StateName, State) ->
    cancel_fight_fsm_event_timer(?TIMER_TIMEOUT),
    notice_stop_fayan(hd(maps:get(wait_op_list, State)), State),
    send_event_inner(op_over),
    {next_state, StateName, State}.

do_fayan_state_op_over(StateName, State) ->
    StateAfterFayan = lib_fight:do_fayan_op(State),
    case maps:get(fayan_turn, StateAfterFayan) of
        [] ->
            send_event_inner(start, b_fight_state_wait:get(StateName)),
            {next_state, get_next_game_state(StateName), StateAfterFayan};
        _ ->
            send_event_inner(wait_op),
            {next_state, StateName, StateAfterFayan}
    end.

do_receive_fayan(PlayerId, Chat, State) ->
    try
        assert_op_in_wait(PlayerId, State),
        lib_fight:do_send_fayan(PlayerId, Chat, State)
    catch
        throw:ErrCode ->
            net_send:send_errcode(ErrCode, PlayerId)
    end.       

notice_player_op(?DUTY_DAOZEI, SeatList, State) ->
    notice_player_op(?DUTY_DAOZEI, maps:get(daozei, State), SeatList, State);
    
notice_player_op(?DUTY_NVWU, SeatList, State) ->
    notice_player_op(?DUTY_NVWU, [lists:sum(maps:get(nvwu_left, State))] ++ [maps:get(langren, State)], SeatList, State);

notice_player_op(?OP_XUANJU_JINGZHANG, SeatList, State) ->
    notice_player_op(?OP_XUANJU_JINGZHANG, maps:get(part_jingzhang, State), SeatList, State);

notice_player_op(Op, SeatList, State) ->
    notice_player_op(Op, SeatList, SeatList, State).

notice_player_op(Op, AttachData, SeatList, State) ->
    Send = #m__fight__notice_op__s2l{op = Op,
                                     attach_data = AttachData},
    FunNotice = 
        fun(SeatId) ->
            lib_fight:send_to_seat(Send, SeatId, State)
        end,
    lists:foreach(FunNotice, SeatList).

do_set_wait_op(SeatIdList, State) ->
    maps:put(wait_op_list, SeatIdList, State).

assert_op_in_wait(PlayerId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    SeatId = lib_fight:get_seat_id_by_player_id(PlayerId, State),
    case lists:member(SeatId, WaitOpList) of
        false ->
            throw(?ERROR);
        true ->
            next_state
    end.

assert_op_legal(Op, StateName) ->
    case lists:member(Op, get_state_legal_op(StateName)) of
        true ->
            ok;
        false ->
            throw(?ERROR)
    end.

assert_op_fit(?DUTY_NVWU, [_, UseYao], State) ->
    case lists:member(UseYao, maps:get(nvwu_left, State)) == true orelse UseYao == 0 of
        true ->
            ok;
        false ->
            throw(?ERROR)
    end;

assert_op_fit(?OP_XUANJU_JINGZHANG, [SeatId], State) ->
    PartList = maps:get(part_jingzhang, State),
    case lists:member(SeatId, PartList) of
        true ->
            ok;
        false ->
            throw(?ERROR)
    end;

assert_op_fit(_, _, _) ->
    ok.

do_log_op(SeatId, Op, State) ->
    LastOpData = maps:get(last_op_data, State),
    NewLastOpData = maps:put(SeatId, Op, LastOpData),
    maps:put(last_op_data, NewLastOpData, State).

do_remove_wait_op(SeatId, State) ->
    WaitOpList = maps:get(wait_op_list, State),
    NewWaitOpList = WaitOpList -- [SeatId],
    {NewWaitOpList == [], maps:put(wait_op_list, NewWaitOpList, State)}.

notice_jingxuan_jingzhang(State) ->
    notice_player_op(?OP_PART_JINGZHANG, lib_fight:get_alive_seat_list(State), State).

notice_xuanju_result(XaunJuType, IsDraw, XuanjuSeat, XuanJuResult, State) ->
    PResutList = [#p_xuanju_result{seat_id = SeatId, 
                                   select_list = SelectList} || {SeatId, SelectList} <- XuanJuResult],
    Send = #m__fight__xuanju_result__s2l{xuanju_type = XaunJuType,
                                         result_list = PResutList,
                                         result_id = XuanjuSeat,
                                         is_draw = util:conver_bool_to_int(IsDraw)},
    lib_fight:send_to_all_player(Send, State).

notice_xuanju_jingzhang(State) ->
    PartXuanjuList = maps:get(part_jingzhang, State),
    notice_player_op(?OP_XUANJU_JINGZHANG, PartXuanjuList, 
        lib_fight:get_alive_seat_list(State) -- PartXuanjuList, State).

notice_xuanju_jingzhang_result(IsDraw, JingZhang, XuanjuResult, State) ->
    notice_xuanju_result(?XUANJU_TYPE_JINGZHANG, IsDraw, JingZhang, XuanjuResult, State).

notice_toupiao(State) ->
    notice_toupiao([], State).

notice_toupiao(MaxSelectList, State) ->
    AliveList = lib_fight:get_alive_seat_list(State),
    notice_player_op(?OP_TOUPIAO, MaxSelectList, AliveList -- MaxSelectList, State).

notice_night_result(State) ->
    Send = #m__fight__night_result__s2l{die_list = maps:get(die, State)},
    lib_fight:send_to_all_player(Send, State).

out_die_player(State) ->
    maps:put(out_seat_list, maps:get(out_seat_list, State) ++ maps:get(die, State) ++ [maps:get(quzhu, State)], State).

get_fight_result(State) ->
    LangrenAlive = lib_fight:get_duty_seat(?DUTY_LANGREN, State),
    ShenMinAlive = 
        lists:flatten([lib_fight:get_duty_seat(DutyId, State) || DutyId <- ?DUTY_LIST_SHENMIN]),
    AllLangren = lib_fight:get_duty_seat(false, ?DUTY_LANGREN, State),
    AllSeat = lib_fight:get_all_seat(State),
    try
        case LangrenAlive of
            [] ->
                throw({true, AllSeat -- AllLangren});
            _ ->
                ignore
        end,

        case ShenMinAlive of
            [] ->
                throw({true, AllLangren});
            _ ->
                ignore
        end,

        case lib_fight:get_duty_seat(?DUTY_PINGMIN, State) of
            [] ->
                throw({true, AllLangren});
            _ ->
                ignore
        end,
        {false, []}
    catch 
        throw:Result ->
            Result
    end.

clear_night_op(State) ->
    State#{wait_op_list => [],   %% 等待中的操作
           shouwei => 0,         %% 守卫的id
           nvwu => {0, 0},       %% 女巫操作
           langren => 0,         %% 狼人操作
           part_jingzhang => [], %% 參與選舉警長
           xuanju_draw_cnt => 0, %% 选举平局次数
           jingzhang => 0,       %% 选举的警长
           jingzhang_op => 0,    %% 警长操作
           fayan_turn => [],     %% 发言顺序
           die => [],            %% 死亡玩家
           quzhu => 0,           %% 驱逐的玩家
           last_op_data => #{},  %% 上一轮操作的数据, 杀了几号, 投了几号等等}.
           game_round => maps:get(game_round, State) + 1
           }.

notice_state_toupiao_result(IsDraw, Quzhu, TouPiaoResult, State) ->
    notice_xuanju_result(?XUANJU_TYPE_QUZHU, IsDraw, Quzhu, TouPiaoResult, State).  

notice_toupiao_out(0, _) ->
    ignore;

notice_toupiao_out(SeatId, State) ->  
    notice_player_op(?OP_QUZHU, [SeatId], State).

notice_game_status_change(Status, State) ->
    StatusId = get_status_id(Status),
    Send = #m__fight__game_state_change__s2l{game_status = StatusId},
    lib_fight:send_to_all_player(Send, State).

send_fight_result(Winner, State) ->
    DutyList = [#p_duty{seat_id = SeatId,
                        duty_id = DutyId} || 
                        {SeatId, DutyId} <- maps:to_list(maps:get(seat_duty_map, State))],

    #{lover := Lover,
      hunxuer := Hunxuer} = State,
    Send = #m__fight__result__s2l{winner = Winner,
                                  lover = Lover,
                                  hunxuer = Hunxuer,
                                  duty_list = DutyList},
    lib_fight:send_to_all_player(Send, State).

notice_start_fayan(SeatId, State) ->
    Send = #m__fight__notice_fayan__s2l{seat_id = SeatId},
    lib_fight:send_to_all_player(Send, State).

notice_stop_fayan(SeatId, State) ->
    Send = #m__fight__stop_fayan__s2l{seat_id = SeatId},
    lib_fight:send_to_seat(Send, SeatId, State).

is_over(State) ->
    NewState = out_die_player(State),
    {IsOver, _Winner} = get_fight_result(NewState),
    IsOver.

get_next_game_state(GameState) ->
    case GameState of
        state_daozei ->
            state_qiubite;
        state_qiubite ->
            state_hunxueer;
        state_hunxueer ->
            state_shouwei;
        state_shouwei ->
            state_langren;
        state_langren ->
            state_nvwu;
        state_nvwu ->
            state_yuyanjia;
        state_yuyanjia ->
            state_part_jingzhang;
        state_part_jingzhang ->
            state_part_fayan;
        state_part_fayan ->
            state_xuanju_jingzhang;
        state_xuanju_jingzhang ->
            state_night_death;
        state_night_death ->
            state_jingzhang;
        state_jingzhang ->
            state_fayan;
        state_fayan ->
            state_guipiao;
        state_guipiao ->
            state_toupiao;
        state_toupiao ->
            state_toupiao_death;
        state_toupiao_death ->
            state_day;
        state_day ->
            state_shouwei
    end.

get_state_legal_op(GameState) ->
    case GameState of
        state_daozei ->
            [?DUTY_DAOZEI];
        state_qiubite ->
            [?DUTY_QIUBITE];
        state_hunxueer ->
            [?DUTY_HUNXUEER];
        state_shouwei ->
            [?DUTY_SHOUWEI];
        state_langren ->
            [?DUTY_LANGREN];
        state_nvwu ->
            [?DUTY_NVWU];
        state_yuyanjia ->
            [?DUTY_YUYANJIA];
        state_part_jingzhang ->
            [?OP_PART_JINGZHANG];
        state_part_fayan ->
            [?OP_PART_FAYAN, ?OP_FAYAN];
        state_xuanju_jingzhang ->
            [?OP_XUANJU_JINGZHANG];
        state_night_death ->
            [?OP_FAYAN, ?OP_DEATH_FAYAN];
        state_jingzhang ->
            [?OP_JINGZHANG_ZHIDING];
        state_guipiao ->
            [?OP_GUIPIAO];
        state_fayan ->
            [?OP_FAYAN];
        state_toupiao ->
            [?OP_TOUPIAO];
        state_toupiao_death ->
            [?OP_FAYAN, ?OP_QUZHU_FAYAN];
        state_day ->
            []
    end.

get_status_id(GameState) ->
    case GameState of
        start ->
            0;
        state_daozei ->
            1;
        state_qiubite ->
            2;
        state_hunxueer ->
            3;
        state_shouwei ->
            4;
        state_langren ->
            5;
        state_nvwu ->
            6;
        state_yuyanjia ->
            7;
        state_part_jingzhang ->
            8;
        state_part_fayan ->
            9;
        state_xuanju_jingzhang ->
            10;
        state_night_death ->
            11;
        state_jingzhang ->
            12;
        state_fayan ->
            13;
        state_guipiao ->
            14;
        state_toupiao ->
            15;
        state_toupiao_death ->
            16;
        state_day ->
            17
    end.