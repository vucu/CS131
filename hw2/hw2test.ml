type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

let awksub_rules_hw1 =
   [Expr, [T"("; N Expr; T")"];
    Expr, [N Num];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"]]

let test_convert_grammar_1 = ((snd (convert_grammar (Expr, awksub_rules_hw1))) Expr = [[T"("; N Expr; T")"]; [N Num]])
let test_convert_grammar_2 = ((snd (convert_grammar (Expr, awksub_rules_hw1))) Lvalue = [[T"$"; N Expr]])
let test_convert_grammar_3 = ((snd (convert_grammar (Expr, awksub_rules_hw1))) Num = [[T"0"]])

