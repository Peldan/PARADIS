-module(filter).
-compile(export_all).

filter(F, L) when is_function(F) -> 
	filter(F, L, []).
filter(F, [X|T], Result) -> %splits the supplied list
	case F(X) of
		true -> 
			filter(F, T, [X|Result]); % if F(x) is true: recursive call with element X appended to the Result list
		false ->
			filter(F, T, Result)
	end;
	
filter(_, L, Result) when length(L) == 0 -> %
	lists:reverse(Result).
