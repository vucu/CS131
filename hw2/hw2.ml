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
	| (s, rules) -> (s, (fun x -> (derive rules x)))
	
	
(* patse_prefix *)
(*
	Concat Rule
*)
let rec make_concat_matcher rules rule accept derivation frag = 
	match rule with 
	| [] -> accept derivation frag
	| head :: tail -> 
	(
		match head with 
		| T(terminal) -> 
		(
			match frag with 
			| [] -> None
			| frag_head :: frag_tail -> 
			(
				if (frag_head = terminal) then 
					(make_concat_matcher rules tail accept derivation frag_tail)
				else
					None
				)
			)
		| N(nonterminal) -> 
			(make_or_matcher rules (rules nonterminal) nonterminal (make_concat_matcher rules tail accept) frag derivation)
	)

(*
	OR Rule
*)
and make_or_matcher rules matching_rules lhs accept frag derivation = 
	match matching_rules with
	| [] -> None
	| head :: tail -> 
	(
		match make_concat_matcher rules head accept (derivation @ [(lhs, head)]) frag with
		| None -> 
			(make_or_matcher rules tail lhs accept frag derivation)
		| any -> any 
	)

let parse_prefix grammar accept frag = 
  match grammar with
    | (start_symbol, rules) -> make_or_matcher rules (rules start_symbol) start_symbol accept frag []