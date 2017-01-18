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
		
