-module(game_pb).

-export([encode/1, encode/2, decode/2,
	 encode_m__chat__public_speak__s2l/1,
	 decode_m__chat__public_speak__s2l/1,
	 encode_m__chat__public_speak__l2s/1,
	 decode_m__chat__public_speak__l2s/1, encode_p_chat/1,
	 decode_p_chat/1, encode_m__room__rand_enter__l2s/1,
	 decode_m__room__rand_enter__l2s/1,
	 encode_m__room__leave_room__s2l/1,
	 decode_m__room__leave_room__s2l/1,
	 encode_m__room__leave_room__l2s/1,
	 decode_m__room__leave_room__l2s/1,
	 encode_m__room__create_room__s2l/1,
	 decode_m__room__create_room__s2l/1,
	 encode_m__room__create_room__l2s/1,
	 decode_m__room__create_room__l2s/1,
	 encode_m__room__enter_room__s2l/1,
	 decode_m__room__enter_room__s2l/1,
	 encode_m__room__enter_room__l2s/1,
	 decode_m__room__enter_room__l2s/1,
	 encode_m__room__get_list__s2l/1,
	 decode_m__room__get_list__s2l/1, encode_p_room/1,
	 decode_p_room/1, encode_m__room__get_list__l2s/1,
	 decode_m__room__get_list__l2s/1,
	 encode_m__player__errcode__s2l/1,
	 decode_m__player__errcode__s2l/1,
	 encode_m__player__info__s2l/1,
	 decode_m__player__info__s2l/1,
	 encode_m__player__info__l2s/1,
	 decode_m__player__info__l2s/1,
	 encode_m__account__login__s2l/1,
	 decode_m__account__login__s2l/1,
	 encode_m__account__login__l2s/1,
	 decode_m__account__login__l2s/1,
	 encode_p_player_show_base/1,
	 decode_p_player_show_base/1]).

-record(m__chat__public_speak__s2l,
	{msg_id, chat_type, chat}).

-record(m__chat__public_speak__l2s,
	{msg_id, chat_type, voice, content}).

-record(p_chat, {player_show_base, voice, content}).

-record(m__room__rand_enter__l2s, {msg_id}).

-record(m__room__leave_room__s2l, {msg_id}).

-record(m__room__leave_room__l2s, {msg_id}).

-record(m__room__create_room__s2l, {msg_id, room_info}).

-record(m__room__create_room__l2s,
	{msg_id, max_player_num, room_name}).

-record(m__room__enter_room__s2l,
	{msg_id, room_info, member_list}).

-record(m__room__enter_room__l2s, {msg_id, room_id}).

-record(m__room__get_list__s2l, {msg_id, room_list}).

-record(p_room,
	{room_id, cur_player_num, max_player_num, owner,
	 room_name, room_status}).

-record(m__room__get_list__l2s, {msg_id}).

-record(m__player__errcode__s2l, {msg_id, errcode}).

-record(m__player__info__s2l, {msg_id, player_id}).

-record(m__player__info__l2s, {msg_id}).

-record(m__account__login__s2l, {msg_id, result}).

-record(m__account__login__l2s, {msg_id, account_name}).

-record(p_player_show_base, {player_id, nick_name}).

encode(Record) ->
    encode(erlang:element(1, Record), Record).

encode_m__chat__public_speak__s2l(Record)
    when is_record(Record, m__chat__public_speak__s2l) ->
    encode(m__chat__public_speak__s2l, Record).

encode_m__chat__public_speak__l2s(Record)
    when is_record(Record, m__chat__public_speak__l2s) ->
    encode(m__chat__public_speak__l2s, Record).

encode_p_chat(Record) when is_record(Record, p_chat) ->
    encode(p_chat, Record).

encode_m__room__rand_enter__l2s(Record)
    when is_record(Record, m__room__rand_enter__l2s) ->
    encode(m__room__rand_enter__l2s, Record).

encode_m__room__leave_room__s2l(Record)
    when is_record(Record, m__room__leave_room__s2l) ->
    encode(m__room__leave_room__s2l, Record).

encode_m__room__leave_room__l2s(Record)
    when is_record(Record, m__room__leave_room__l2s) ->
    encode(m__room__leave_room__l2s, Record).

encode_m__room__create_room__s2l(Record)
    when is_record(Record, m__room__create_room__s2l) ->
    encode(m__room__create_room__s2l, Record).

encode_m__room__create_room__l2s(Record)
    when is_record(Record, m__room__create_room__l2s) ->
    encode(m__room__create_room__l2s, Record).

encode_m__room__enter_room__s2l(Record)
    when is_record(Record, m__room__enter_room__s2l) ->
    encode(m__room__enter_room__s2l, Record).

encode_m__room__enter_room__l2s(Record)
    when is_record(Record, m__room__enter_room__l2s) ->
    encode(m__room__enter_room__l2s, Record).

encode_m__room__get_list__s2l(Record)
    when is_record(Record, m__room__get_list__s2l) ->
    encode(m__room__get_list__s2l, Record).

encode_p_room(Record) when is_record(Record, p_room) ->
    encode(p_room, Record).

encode_m__room__get_list__l2s(Record)
    when is_record(Record, m__room__get_list__l2s) ->
    encode(m__room__get_list__l2s, Record).

encode_m__player__errcode__s2l(Record)
    when is_record(Record, m__player__errcode__s2l) ->
    encode(m__player__errcode__s2l, Record).

encode_m__player__info__s2l(Record)
    when is_record(Record, m__player__info__s2l) ->
    encode(m__player__info__s2l, Record).

encode_m__player__info__l2s(Record)
    when is_record(Record, m__player__info__l2s) ->
    encode(m__player__info__l2s, Record).

encode_m__account__login__s2l(Record)
    when is_record(Record, m__account__login__s2l) ->
    encode(m__account__login__s2l, Record).

encode_m__account__login__l2s(Record)
    when is_record(Record, m__account__login__l2s) ->
    encode(m__account__login__l2s, Record).

encode_p_player_show_base(Record)
    when is_record(Record, p_player_show_base) ->
    encode(p_player_show_base, Record).

encode(p_player_show_base, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_player_show_base.player_id,
					none),
			   uint32, []),
		      pack(2, required,
			   with_default(_Record#p_player_show_base.nick_name,
					none),
			   string, [])]);
encode(m__account__login__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__account__login__l2s.msg_id,
					10001),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__account__login__l2s.account_name,
					none),
			   string, [])]);
encode(m__account__login__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__account__login__s2l.msg_id,
					10002),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__account__login__s2l.result,
					none),
			   int32, [])]);
encode(m__player__info__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__info__l2s.msg_id,
					12001),
			   int32, [])]);
encode(m__player__info__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__info__s2l.msg_id,
					12002),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__info__s2l.player_id,
					none),
			   uint32, [])]);
encode(m__player__errcode__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__player__errcode__s2l.msg_id,
					12004),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__player__errcode__s2l.errcode,
					none),
			   int32, [])]);
encode(m__room__get_list__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__get_list__l2s.msg_id,
					13001),
			   int32, [])]);
encode(p_room, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_room.room_id, none), int32,
			   []),
		      pack(2, required,
			   with_default(_Record#p_room.cur_player_num, none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#p_room.max_player_num, none),
			   int32, []),
		      pack(4, required,
			   with_default(_Record#p_room.owner, none),
			   p_player_show_base, []),
		      pack(5, required,
			   with_default(_Record#p_room.room_name, none), string,
			   []),
		      pack(6, required,
			   with_default(_Record#p_room.room_status, none),
			   string, [])]);
encode(m__room__get_list__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__get_list__s2l.msg_id,
					13002),
			   int32, []),
		      pack(2, repeated,
			   with_default(_Record#m__room__get_list__s2l.room_list,
					none),
			   p_room, [])]);
encode(m__room__enter_room__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__enter_room__l2s.msg_id,
					13003),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__enter_room__l2s.room_id,
					none),
			   int32, [])]);
encode(m__room__enter_room__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__enter_room__s2l.msg_id,
					13004),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__enter_room__s2l.room_info,
					none),
			   p_room, []),
		      pack(3, repeated,
			   with_default(_Record#m__room__enter_room__s2l.member_list,
					none),
			   p_player_show_base, [])]);
encode(m__room__create_room__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__create_room__l2s.msg_id,
					13005),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__create_room__l2s.max_player_num,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__room__create_room__l2s.room_name,
					none),
			   string, [])]);
encode(m__room__create_room__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__create_room__s2l.msg_id,
					13006),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__room__create_room__s2l.room_info,
					none),
			   p_room, [])]);
encode(m__room__leave_room__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__leave_room__l2s.msg_id,
					13007),
			   int32, [])]);
encode(m__room__leave_room__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__leave_room__s2l.msg_id,
					13008),
			   int32, [])]);
encode(m__room__rand_enter__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__room__rand_enter__l2s.msg_id,
					13009),
			   int32, [])]);
encode(p_chat, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#p_chat.player_show_base, none),
			   p_player_show_base, []),
		      pack(2, required,
			   with_default(_Record#p_chat.voice, none), bytes, []),
		      pack(3, required,
			   with_default(_Record#p_chat.content, none), string,
			   [])]);
encode(m__chat__public_speak__l2s, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__chat__public_speak__l2s.msg_id,
					14001),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__chat__public_speak__l2s.chat_type,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__chat__public_speak__l2s.voice,
					none),
			   bytes, []),
		      pack(4, required,
			   with_default(_Record#m__chat__public_speak__l2s.content,
					none),
			   string, [])]);
encode(m__chat__public_speak__s2l, _Record) ->
    iolist_to_binary([pack(1, required,
			   with_default(_Record#m__chat__public_speak__s2l.msg_id,
					14002),
			   int32, []),
		      pack(2, required,
			   with_default(_Record#m__chat__public_speak__s2l.chat_type,
					none),
			   int32, []),
		      pack(3, required,
			   with_default(_Record#m__chat__public_speak__s2l.chat,
					none),
			   p_chat, [])]).

with_default(undefined, none) -> undefined;
with_default(undefined, Default) -> Default;
with_default(Val, _) -> Val.

pack(_, optional, undefined, _, _) -> [];
pack(_, repeated, undefined, _, _) -> [];
pack(FNum, required, undefined, Type, _) ->
    exit({error,
	  {required_field_is_undefined, FNum, Type}});
pack(_, repeated, [], _, Acc) -> lists:reverse(Acc);
pack(FNum, repeated, [Head | Tail], Type, Acc) ->
    pack(FNum, repeated, Tail, Type,
	 [pack(FNum, optional, Head, Type, []) | Acc]);
pack(FNum, _, Data, _, _) when is_tuple(Data) ->
    RecName = erlang:element(1, Data),
    protobuffs:encode(FNum, encode(RecName, Data), bytes);
pack(FNum, _, Data, Type, _) ->
    protobuffs:encode(FNum, Data, Type).

decode_m__chat__public_speak__s2l(Bytes) ->
    decode(m__chat__public_speak__s2l, Bytes).

decode_m__chat__public_speak__l2s(Bytes) ->
    decode(m__chat__public_speak__l2s, Bytes).

decode_p_chat(Bytes) -> decode(p_chat, Bytes).

decode_m__room__rand_enter__l2s(Bytes) ->
    decode(m__room__rand_enter__l2s, Bytes).

decode_m__room__leave_room__s2l(Bytes) ->
    decode(m__room__leave_room__s2l, Bytes).

decode_m__room__leave_room__l2s(Bytes) ->
    decode(m__room__leave_room__l2s, Bytes).

decode_m__room__create_room__s2l(Bytes) ->
    decode(m__room__create_room__s2l, Bytes).

decode_m__room__create_room__l2s(Bytes) ->
    decode(m__room__create_room__l2s, Bytes).

decode_m__room__enter_room__s2l(Bytes) ->
    decode(m__room__enter_room__s2l, Bytes).

decode_m__room__enter_room__l2s(Bytes) ->
    decode(m__room__enter_room__l2s, Bytes).

decode_m__room__get_list__s2l(Bytes) ->
    decode(m__room__get_list__s2l, Bytes).

decode_p_room(Bytes) -> decode(p_room, Bytes).

decode_m__room__get_list__l2s(Bytes) ->
    decode(m__room__get_list__l2s, Bytes).

decode_m__player__errcode__s2l(Bytes) ->
    decode(m__player__errcode__s2l, Bytes).

decode_m__player__info__s2l(Bytes) ->
    decode(m__player__info__s2l, Bytes).

decode_m__player__info__l2s(Bytes) ->
    decode(m__player__info__l2s, Bytes).

decode_m__account__login__s2l(Bytes) ->
    decode(m__account__login__s2l, Bytes).

decode_m__account__login__l2s(Bytes) ->
    decode(m__account__login__l2s, Bytes).

decode_p_player_show_base(Bytes) ->
    decode(p_player_show_base, Bytes).

decode(p_player_show_base, Bytes) ->
    Types = [{2, nick_name, string, []},
	     {1, player_id, uint32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_player_show_base, Decoded);
decode(m__account__login__l2s, Bytes) ->
    Types = [{2, account_name, string, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__account__login__l2s, Decoded);
decode(m__account__login__s2l, Bytes) ->
    Types = [{2, result, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__account__login__s2l, Decoded);
decode(m__player__info__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__info__l2s, Decoded);
decode(m__player__info__s2l, Bytes) ->
    Types = [{2, player_id, uint32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__info__s2l, Decoded);
decode(m__player__errcode__s2l, Bytes) ->
    Types = [{2, errcode, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__player__errcode__s2l, Decoded);
decode(m__room__get_list__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__get_list__l2s, Decoded);
decode(p_room, Bytes) ->
    Types = [{6, room_status, string, []},
	     {5, room_name, string, []},
	     {4, owner, p_player_show_base, [is_record]},
	     {3, max_player_num, int32, []},
	     {2, cur_player_num, int32, []},
	     {1, room_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_room, Decoded);
decode(m__room__get_list__s2l, Bytes) ->
    Types = [{2, room_list, p_room, [is_record, repeated]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__get_list__s2l, Decoded);
decode(m__room__enter_room__l2s, Bytes) ->
    Types = [{2, room_id, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__enter_room__l2s, Decoded);
decode(m__room__enter_room__s2l, Bytes) ->
    Types = [{3, member_list, p_player_show_base,
	      [is_record, repeated]},
	     {2, room_info, p_room, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__enter_room__s2l, Decoded);
decode(m__room__create_room__l2s, Bytes) ->
    Types = [{3, room_name, string, []},
	     {2, max_player_num, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__create_room__l2s, Decoded);
decode(m__room__create_room__s2l, Bytes) ->
    Types = [{2, room_info, p_room, [is_record]},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__create_room__s2l, Decoded);
decode(m__room__leave_room__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__leave_room__l2s, Decoded);
decode(m__room__leave_room__s2l, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__leave_room__s2l, Decoded);
decode(m__room__rand_enter__l2s, Bytes) ->
    Types = [{1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__room__rand_enter__l2s, Decoded);
decode(p_chat, Bytes) ->
    Types = [{3, content, string, []},
	     {2, voice, bytes, []},
	     {1, player_show_base, p_player_show_base, [is_record]}],
    Decoded = decode(Bytes, Types, []),
    to_record(p_chat, Decoded);
decode(m__chat__public_speak__l2s, Bytes) ->
    Types = [{4, content, string, []},
	     {3, voice, bytes, []}, {2, chat_type, int32, []},
	     {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__chat__public_speak__l2s, Decoded);
decode(m__chat__public_speak__s2l, Bytes) ->
    Types = [{3, chat, p_chat, [is_record]},
	     {2, chat_type, int32, []}, {1, msg_id, int32, []}],
    Decoded = decode(Bytes, Types, []),
    to_record(m__chat__public_speak__s2l, Decoded).

decode(<<>>, _, Acc) -> Acc;
decode(<<Bytes/binary>>, Types, Acc) ->
    {{FNum, WireType}, Rest} =
	protobuffs:read_field_num_and_wire_type(Bytes),
    case lists:keysearch(FNum, 1, Types) of
      {value, {FNum, Name, Type, Opts}} ->
	  {Value1, Rest1} = case lists:member(is_record, Opts) of
			      true ->
				  {V, R} = protobuffs:decode_value(WireType,
								   bytes, Rest),
				  RecVal = decode(Type, V),
				  {RecVal, R};
			      false ->
				  {V, R} = protobuffs:decode_value(WireType,
								   Type, Rest),
				  {unpack_value(V, Type), R}
			    end,
	  case lists:member(repeated, Opts) of
	    true ->
		case lists:keytake(FNum, 1, Acc) of
		  {value, {FNum, Name, List}, Acc1} ->
		      decode(Rest1, Types,
			     [{FNum, Name,
			       lists:reverse([Value1 | lists:reverse(List)])}
			      | Acc1]);
		  false ->
		      decode(Rest1, Types, [{FNum, Name, [Value1]} | Acc])
		end;
	    false ->
		decode(Rest1, Types, [{FNum, Name, Value1} | Acc])
	  end;
      false -> exit({error, {unexpected_field_index, FNum}})
    end.

unpack_value(<<Binary/binary>>, string) ->
    binary_to_list(Binary);
unpack_value(Value, _) -> Value.

to_record(p_player_show_base, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     p_player_show_base),
					 Record, Name, Val)
		end,
		#p_player_show_base{}, DecodedTuples);
to_record(m__account__login__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__account__login__l2s),
					 Record, Name, Val)
		end,
		#m__account__login__l2s{}, DecodedTuples);
to_record(m__account__login__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__account__login__s2l),
					 Record, Name, Val)
		end,
		#m__account__login__s2l{}, DecodedTuples);
to_record(m__player__info__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__info__l2s),
					 Record, Name, Val)
		end,
		#m__player__info__l2s{}, DecodedTuples);
to_record(m__player__info__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__info__s2l),
					 Record, Name, Val)
		end,
		#m__player__info__s2l{}, DecodedTuples);
to_record(m__player__errcode__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__player__errcode__s2l),
					 Record, Name, Val)
		end,
		#m__player__errcode__s2l{}, DecodedTuples);
to_record(m__room__get_list__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__get_list__l2s),
					 Record, Name, Val)
		end,
		#m__room__get_list__l2s{}, DecodedTuples);
to_record(p_room, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_room), Record,
					 Name, Val)
		end,
		#p_room{}, DecodedTuples);
to_record(m__room__get_list__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__get_list__s2l),
					 Record, Name, Val)
		end,
		#m__room__get_list__s2l{}, DecodedTuples);
to_record(m__room__enter_room__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__enter_room__l2s),
					 Record, Name, Val)
		end,
		#m__room__enter_room__l2s{}, DecodedTuples);
to_record(m__room__enter_room__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__enter_room__s2l),
					 Record, Name, Val)
		end,
		#m__room__enter_room__s2l{}, DecodedTuples);
to_record(m__room__create_room__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__create_room__l2s),
					 Record, Name, Val)
		end,
		#m__room__create_room__l2s{}, DecodedTuples);
to_record(m__room__create_room__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__create_room__s2l),
					 Record, Name, Val)
		end,
		#m__room__create_room__s2l{}, DecodedTuples);
to_record(m__room__leave_room__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__leave_room__l2s),
					 Record, Name, Val)
		end,
		#m__room__leave_room__l2s{}, DecodedTuples);
to_record(m__room__leave_room__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__leave_room__s2l),
					 Record, Name, Val)
		end,
		#m__room__leave_room__s2l{}, DecodedTuples);
to_record(m__room__rand_enter__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__room__rand_enter__l2s),
					 Record, Name, Val)
		end,
		#m__room__rand_enter__l2s{}, DecodedTuples);
to_record(p_chat, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields, p_chat), Record,
					 Name, Val)
		end,
		#p_chat{}, DecodedTuples);
to_record(m__chat__public_speak__l2s, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__chat__public_speak__l2s),
					 Record, Name, Val)
		end,
		#m__chat__public_speak__l2s{}, DecodedTuples);
to_record(m__chat__public_speak__s2l, DecodedTuples) ->
    lists:foldl(fun ({_FNum, Name, Val}, Record) ->
			set_record_field(record_info(fields,
						     m__chat__public_speak__s2l),
					 Record, Name, Val)
		end,
		#m__chat__public_speak__s2l{}, DecodedTuples).

set_record_field(Fields, Record, Field, Value) ->
    Index = list_index(Field, Fields),
    erlang:setelement(Index + 1, Record, Value).

list_index(Target, List) -> list_index(Target, List, 1).

list_index(Target, [Target | _], Index) -> Index;
list_index(Target, [_ | Tail], Index) ->
    list_index(Target, Tail, Index + 1);
list_index(_, [], _) -> 0.

