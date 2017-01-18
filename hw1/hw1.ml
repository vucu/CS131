let rec inset item set = 
  match set with 
    | [] -> false
    | h :: t -> if item = h 
                  then true
                  else inset item t;;

let rec subset a b = 
  match a with
    | [] -> true
    | h :: t -> if inset h b
                  then subset t b
                  else false;;
