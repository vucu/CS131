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
let rec make_concat_matcher all_rules rule acceptor derivation frag = 
	match rule with 
	| [] -> acceptor derivation frag
	| rule_head :: rule_tail -> 
	(
		match rule_head with 
		| T(terminal) -> 
		(
			match frag with 
			| [] -> None
			| frag_head :: frag_tail -> 
			(
				if (frag_head = terminal) then 
					(make_concat_matcher all_rules rule_tail acceptor derivation frag_tail)
				else
					None
				)
			)
		| N(nonterminal) -> 
			(make_or_matcher all_rules (all_rules nonterminal) nonterminal (make_concat_matcher all_rules rule_tail acceptor) frag derivation)
	)

(*
	OR Rule
*)
and make_or_matcher all_rules matching_rules lhs acceptor frag derivation = 
	match matching_rules with
	| [] -> None
	| rules_head :: rules_tail -> 
	(
		match make_concat_matcher all_rules rules_head acceptor (derivation @ [(lhs, rules_head)]) frag with
		| None -> 
			(make_or_matcher all_rules rules_tail lhs acceptor frag derivation)
		| any -> any 
	)

let parse_prefix grammar acceptor frag = 
  match grammar with
    | (start_symbol, rules) -> make_or_matcher rules (rules start_symbol) start_symbol acceptor frag []