-module(is_prime).
-compile(export_all).

is_prime(N) when is_integer(N), N > 1 ->
   	is_prime(N, 2).
is_prime(N, X) when N > X ->
	io:format("~w~n",[X]),
	case N rem X == 0 of
		true ->
			io:fwrite("~w is not a prime number!", [N]);
		false ->
			
	end.


