let rec subset a b = 
  match a with
    | [] -> true
    | h :: t -> if inset h b
                  then subset t b
                  else false;;
