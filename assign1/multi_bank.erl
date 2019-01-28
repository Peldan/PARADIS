-module(multi_bank).
-compile(export_all).

new_bank() ->
	spawn(?MODULE, bank, [maps:new()]).

new_account(Pid, Who) ->
	rpc(Pid, {new_account, Who}). 

balance(Pid, Who) ->
    rpc(Pid, {balance, Who}).

add(Pid, Who, Amount) ->
	rpc(Pid, {add, Who, Amount}).

withdraw(Pid, Who, Amount) ->
    rpc(Pid, {withdraw, Who, Amount}).

lend(Pid, Sender, To, Amount) ->
	rpc(Pid, {lend, Sender, To, Amount}).

rpc(Pid, Msg) ->
	Pid ! {self(), Msg},
	receive
		Any ->
			Any
	end.

bank(Accounts) ->
    receive
		{From, {new_account, Who}} ->
			case maps:is_key(Who, Accounts) of
				false ->
					From ! success,
					bank(maps:put(Who, 0, Accounts));
				true ->
					From ! failure,
					bank(Accounts)
			end;

		{From, {balance, Who}} ->
			From ! maps:get(Who, Accounts, failure), % used maps:get/3, supplying a default response if no value is associated with the supplied key, thus saving a couple of lines of code (no case-statement needed)
			bank(Accounts);
		{From, {add, Who, Amount}} ->
			X = maps:get(Who, Accounts, failure),
			case is_number(X) of
				false ->
					From ! X,
					bank(Accounts);
				true ->
					From ! success,
					bank(maps:update(Who, X+Amount, Accounts))
			end;
		
		{From, {withdraw, Who, Amount}} ->
			X = maps:get(Who, Accounts, failure), %not quite sure if this approach saves any lines of code, compared to using maps:is_key/2, but I thought the approach was interesting so I tried it..
			case is_number(X) of
				false ->
					From ! X,
					bank(Accounts);
				true ->
					if
						X >= Amount ->
							From ! success,
							bank(maps:update(Who, X-Amount, Accounts));
						true ->
							From ! failure,
							bank(Accounts)
					end
			end;
		
		{From, {lend, Sender, To, Amount}} ->
			case maps:is_key(Sender, Accounts) and maps:is_key(To, Accounts) of
				false ->
					From ! failure,
					bank(Accounts);
				true ->
					From_Amount = maps:get(Sender, Accounts),
					if
						From_Amount >= Amount ->
							Temp = maps:update(Sender, From_Amount - Amount, Accounts),
							From ! success,
							bank(maps:update(To, maps:get(To, Accounts)+Amount, Temp));
						true ->
							From ! failure,
							bank(Accounts)
					end
			end
	end,
	bank(Accounts).

%TESTS
test() ->
    Pid = new_bank(),
	success = new_account(Pid, arvid),
	failure = new_account(Pid, arvid),
	failure = balance(Pid, per),
	failure = add(Pid, nonamer, 50),
	success = add(Pid, arvid, 25),
	25 = balance(Pid, arvid),
	failure = withdraw(Pid, arvid, 26),
	success = withdraw(Pid, arvid, 25),
	0 = balance(Pid, arvid),
	success = new_account(Pid, joe),
	success = add(Pid, joe, 500),
	0 = balance(Pid, arvid),
	500 = balance(Pid, joe),
	success = lend(Pid, joe, arvid, 250),
	io:fwrite("Arvid: ~w -> Joe: ~w~n",[balance(Pid, arvid), balance(Pid, joe)]),
	hooray.


