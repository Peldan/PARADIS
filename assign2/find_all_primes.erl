-module(find_all_primes).
-compile(export_all).

find_all_primes(N) ->
	filter:filter(fun prime:is_prime/1, seq_find:seq(N)).  
