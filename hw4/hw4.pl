% Implement signal_morse
signal_morse([], []).
signal_morse([H | T], Morse):- 
	break([H | T], B), 
	run_morse(B, Morse).

% break to list of 1s and 0s
break([], []).
break([First], [[First]]).
break([First, Second | T], [[First] | Other]) :-
	First \= Second, 
	break([Second | T], Other),
	!.
break([First, First| T], [ [First|T2] | Other] ):-
    break([First | T], [T2 | Other]),
	!.
	
run_morse([], []).
run_morse([[1] | Other], ['.' | Remain]):- run_morse(Other, Remain).
run_morse([[1,1] | Other], ['.' | Remain]):- run_morse(Other, Remain).
run_morse([[1,1] | Other], ['-' | Remain]):- run_morse(Other, Remain).
run_morse([[1,1,1] | Other], ['-' | Remain]):- run_morse(Other, Remain).
run_morse([[1,1,1,1 | _] | Other], ['-' | Remain]):- 
	run_morse(Other, Remain).
run_morse([[0] | Other], Remain):- run_morse(Other, Remain).
run_morse([[0,0] | Other], Remain):- run_morse(Other, Remain).
run_morse([[0,0] | Other], ['^' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0] | Other], ['^' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0,0] | Other], ['^' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0,0,0] | Other], ['^' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0,0,0] | Other], ['#' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0,0,0,0 | _] | Other], ['#' | Remain]):- 
	run_morse(Other, Remain).

% Morse table
morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).	   % B
morse(c, [-,.,-,.]).	   % C
morse(d, [-,.,.]).	   % D
morse(e, [.]).		   % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).	   % F
morse(g, [-,-,.]).	   % G
morse(h, [.,.,.,.]).	   % H
morse(i, [.,.]).	   % I
morse(j, [.,-,-,-]).	   % J
morse(k, [-,.,-]).	   % K or invitation to transmit
morse(l, [.,-,.,.]).	   % L
morse(m, [-,-]).	   % M
morse(n, [-,.]).	   % N
morse(o, [-,-,-]).	   % O
morse(p, [.,-,-,.]).	   % P
morse(q, [-,-,.,-]).	   % Q
morse(r, [.,-,.]).	   % R
morse(s, [.,.,.]).	   % S
morse(t, [-]).	 	   % T
morse(u, [.,.,-]).	   % U
morse(v, [.,.,.,-]).	   % V
morse(w, [.,-,-]).	   % W
morse(x, [-,.,.,-]).	   % X or multiplication sign
morse(y, [-,.,-,-]).	   % Y
morse(z, [-,-,.,.]).	   % Z
morse(0, [-,-,-,-,-]).	   % 0
morse(1, [.,-,-,-,-]).	   % 1
morse(2, [.,.,-,-,-]).	   % 2
morse(3, [.,.,.,-,-]).	   % 3
morse(4, [.,.,.,.,-]).	   % 4
morse(5, [.,.,.,.,.]).	   % 5
morse(6, [-,.,.,.,.]).	   % 6
morse(7, [-,-,.,.,.]).	   % 7
morse(8, [-,-,-,.,.]).	   % 8
morse(9, [-,-,-,-,.]).	   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)


% Implement morse_message
signal_message([], []).
signal_message([H | T], M):- 
	signal_morse([H | T], Morse), 
	message(Morse, [], Message), 
	split(Message, S),
	remove_all(S, Mcollection),
	flatten(Mcollection, M).
	
% Convert Morse to Message
message([], [], []).
message([], A, [M]):- morse(M, A).
message(['#' | T], [], ['#' | Tm]):- message(T, [], Tm).
message(['#' | T], A, [First, '#' | Tm]):- morse(First, A), message(T, [], Tm).
message(['^' | T], [], M):- message(T, [], M).
message(['^' | T], A, [Hm | Tm]):- morse(Hm, A), message(T, [], Tm).
message([H | T], A, M):- append(A, [H], Word), message(T, Word, M).

% Split the list at error
split([], []).
split([First], [[First]]).
split([error, Second | T], [[error] | Other]) :-
	split([Second | T], Other),
	!.
split([First, Second| T], [ [First|T2] | Other] ):-
    split([Second | T], [T2 | Other]),
	!.

remove_all([],[]).
remove_all([ [error] | Other], [ [error] | Other2]):- remove_all(Other, Other2).
remove_all([ Nonerror | Other], [ Result | Other2]):- rm(Nonerror, [], Result), remove_all(Other, Other2).

rm([], [], []).
rm([], A, A).
rm(['#' | T], [], ['#' | MT]):- rm(T, [], MT).
rm(['#' | T], [AH | AT], [AH | MT]):- rm(['#' | T], AT, MT). 
rm([error | T], A, M):- rm(T, [], M).
rm([H | T], A, M):- append(A,[H], Word), rm(T, Word, M).


