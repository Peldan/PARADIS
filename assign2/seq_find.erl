-module(seq_find).
-compile(export_all).

seq(N) ->
	List = [],
	seq(N, List).
seq(N, List) when N > 0 ->
	case is_integer(N) of
		true ->
			seq(N-1, lists:append(List, [N]));
		false ->
			seq(N-1, List)
	end;
seq(0, List) ->
	lists:reverse(List).
