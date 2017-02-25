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

% Convert Morse to Message
message([], [], []).
message([], A, [M]):- morse(M, A).
message(['#' | T], [], ['#' | Tm]):- message(T, [], Tm).
message(['#' | T], A, [Other, '#' | Tm]):- morse(Other, A), message(T, [], Tm).
message(['^' | T], [], M):- message(T, [], M).
message(['^' | T], A, [Hm | Tm]):- morse(Hm, A), message(T, [], Tm).
message([H | T], A, M):- append(A, [H], Word), message(T, Word, M).

remove_errors_accum([], [], []).
remove_errors_accum([], A, A).
remove_errors_accum(['#' | T], [], ['#' | MT]):- remove_errors_accum(T, [], MT).
remove_errors_accum(['#' | T], [AH | AT], [AH | MT]):- remove_errors_accum(['#' | T], AT, MT). 
remove_errors_accum([error, Other | T], A, M):- =(error, Other), append(A, [error], New), remove_errors_accum([Other | T], New, M);
											 remove_errors_accum([Other |T], [], M).
remove_errors_accum([H | T], A, M):- \=([H],['error']), append(A,[H], New), remove_errors_accum(T, New, M).

remove_errors(Msg, M):- once(remove_errors_accum(Msg, [], M)).

signal_message([], []).
signal_message([H | T], M):- signal_morse([H | T], Morse), message(Morse, [], Message), remove_errors(Message, M).
