(* Check if e in s *)
let inset e s = 
	let func elem = 
		elem = e
	in 
		List.exists func s

let subset a b = 
	let func elem =
		inset elem b
	in
		List.for_all func a

		
let equal_sets a b =
	if subset a b && subset b a
	then true
	else false;;

let set_union a b = a @ b;;

let set_intersection a b =
	let func elem =
		inset elem b
	in
		List.filter func a
		
let set_diff a b =
	let func elem =
		not (inset elem b)
	in
		List.filter func a
	
	
(* Check if x is a fixed point of f *)
let fixed_point eq f x =
	if eq (f x) x
	then true
	else false;;
	
let rec computed_fixed_point eq f x =
	if fixed_point eq f x
	then x
	else computed_fixed_point eq f (f x);;

	
(* Calculate periodic value *)	
let rec period f p x = 
	if p = 0 
    then x
    else period f (p-1) (f x);;

(* Check if x is a fixed point of f p *)	
let rec periodic_point eq f p x =
	if eq (period f p x) x 
	then true
	else false;;
	
let rec computed_periodic_point eq f p x = 
	if periodic_point eq f p x
	then x
	else computed_periodic_point eq f p (f x);;

	
let rec while_away s p x =
	if p x
	then x :: while_away s p (s x)
	else [];;

	
let rec rle_expand r e =
	if r = 0
	then []
	else e :: rle_expand (r-1) e;;
	
let rec rle_decode lp = 
	match lp with
	| [] -> []
	| (h1, h2) :: t -> (rle_expand h1 h2) @ (rle_decode t)

(****************)
(* Filter blind alleys functions *)
(****************)

type ('terminal, 'nonterminal) symbol = 
	| T of 'terminal 
	| N of 'nonterminal;;

(* Check for terminable symbol *)
let check_symbol s terminables = 
	match s with
	| T s -> true
	| N s -> inset s terminables;;

(* Check for terminable rhs *)
let rec check_rhs rhs terminables = 
	match rhs with
	| [] -> true
	| h::t -> if (check_symbol h terminables) 
		then check_rhs t terminables
		else false;;

(* Accumulate rules to x *)
let rec accumulate rules x = 
	match rules with
	| [] -> x
	| (s, rhs)::t -> if (check_rhs rhs x)
		then (
			if (inset s x) 
			then accumulate t x  
			else accumulate t (s::x) 
		)
		else accumulate t x;;

let func (x, rules) =
	((accumulate rules x), rules);;

let equal_fst (sA, rA) (sB, rB) = 
	equal_sets sA sB

(* Get all terminables *)
let get_terminables rules =  
	fst(computed_fixed_point equal_fst func ([], rules));;

(* Check for terminable rules *)
let rec check_rules rules terminables = 
	match rules with
	| [] -> []
	| (symbol, rhs)::t -> if (check_rhs rhs terminables) 
		then (symbol, rhs)::(check_rules t terminables) 
		else check_rules t terminables;;	

let filter_blind_alleys (start, rules) = 
	(start, check_rules rules (get_terminables rules));; 