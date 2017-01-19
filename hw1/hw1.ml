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
						
