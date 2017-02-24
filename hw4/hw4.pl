
% Base case: Empty morse is empty
signal_morse([], []).

% M is the match of the list if ????????
signal_morse([H|T],M):- 
	break([H|T], B), 
	valid(B, M).

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
	
