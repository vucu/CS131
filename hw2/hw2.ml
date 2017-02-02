(* convert_grammar *)
type ('terminal, 'nonterminal) symbol = 
	| T of 'terminal 
	| N of 'nonterminal;;

let rec derive rules x =
	match rules with
	| [] -> []
	| head :: tail -> 	
	if ((fst head) = x) 
	then
		(snd head) :: (derive tail x)
	else
		derive tail x
	  
let convert_grammar gram1 = 
	match gram1 with
	| (start, rules) -> (start, (fun x -> (derive rules x)))
	
	
(* parse_prefix *)
let rec make_a_matcher rules rule accept derivation frag = 
	match rule with 
	| [] -> accept derivation frag
	| head :: tail -> 
	(
		match head with 
		| T(terminal) -> 
		(
			match frag with 
			| [] -> None
			| f_head :: f_tail -> 
				if (f_head = terminal) then 
					(make_a_matcher rules tail accept derivation f_tail)
				else
					None
		)
		| N(nonterminal) -> 
			make_or_matcher rules (rules nonterminal) nonterminal (make_a_matcher rules tail accept) frag derivation
	)

and make_or_matcher rules matching_rules lhs accept frag derivation = 
	match matching_rules with
	| [] -> None
	| head :: tail -> 
	(
		match make_a_matcher rules head accept (derivation @ [(lhs, head)]) frag with
		| None -> make_or_matcher rules tail lhs accept frag derivation
		| any -> any 
	)

let parse_prefix grammar accept frag = 
	match grammar with
	| (start, rules) -> make_or_matcher rules (rules start) start accept frag []