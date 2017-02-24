% Implement signal_morse
signal_morse([], []).
signal_morse([H | T],M):- 
	break([H | T], B), 
	run_morse(B, M).

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
run_morse([[1,1,1 | _] | Other], ['-' | Remain]):- 
	run_morse(Other, Remain).
run_morse([[0] | Other], Remain):- run_morse(Other, Remain).
run_morse([[0,0] | Other], Remain):- run_morse(Other, Remain).
run_morse([[0,0] | Other], ['^' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0] | Other], ['^' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0,0] | Other], ['^' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0,0,0] | Other], ['^' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0,0,0] | Other], ['#' | Remain]):- run_morse(Other, Remain).
run_morse([[0,0,0,0,0 | _] | Other], ['#' | Remain]):- 
	run_morse(Other, Remain).
	
