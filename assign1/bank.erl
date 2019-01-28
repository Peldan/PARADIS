-module(bank).
-compile(export_all).

test() ->
    Pid = new(),
    ok = add(Pid, 10),
    ok = add(Pid, 20),
    30 = balance(Pid),
    ok = withdraw(Pid, 15),
    15 = balance(Pid),
    insufficient_funds = withdraw(Pid, 20),
    horray.

test2() ->
	Pid = new(),
	what_are_you_doing = add(Pid, -5),
	0 = balance(Pid),
	what_are_you_doing = add(Pid, 0),
	ok = add(Pid, 500),
	500 = balance(Pid),
	ok = add(Pid, 50/2),
	io:format("You currently have $~p on your account, wow!~n", [balance(Pid)]),
	hooray.
new() ->
    spawn(fun() -> bank(0) end).

balance(Pid) ->
    rpc(Pid, {balance}).

add(Pid, X) ->
	rpc(Pid, {add, X}).

withdraw(Pid, X) ->
    rpc(Pid, {withdraw, X}).

rpc(Pid, X) ->
	Pid ! {self(), X},
	receive
		Any ->
			Any
	end.

bank(X) ->
    receive
	{From, {add, Y}} when Y > 0 ->
	    From ! ok,
	    bank(X+Y);
	{From, {add, _}} ->
		From ! what_are_you_doing;
	{From, {withdraw, Y}} when X >= Y ->
	    From ! ok,
		bank(X-Y);
	{From, {withdraw, _}} ->
		From ! insufficient_funds;
	{From, {balance}} ->
		From ! X
    end,
	bank(X).
