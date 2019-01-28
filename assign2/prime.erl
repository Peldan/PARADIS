-module(prime).
-compile(export_all).
is_prime(1) -> false;
is_prime(2) -> true;
is_prime(N) when is_number(N) -> is_prime(N, 2).
is_prime(N, X) -> %TODO hitta snygg lösning för 2 som också är primtal	
	case N rem X == 0 of
		true ->
			false;
		false ->
			if
				N - 1 > X ->
					is_prime(N, X+1);
				true ->
					true
			end
	end.

