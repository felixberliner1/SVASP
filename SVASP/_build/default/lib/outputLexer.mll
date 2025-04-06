{
    open OutputParser
}

rule out_lang = parse
    | [' ' '\n' '\t'] { out_lang lexbuf }
    | "gen" { GEN }
    | "Answer:" { ANS }
    | "SATISFIABLE" { SAT }
    | "UNSATISFIABLE" { UNSAT }
    | ',' { COMMA }
    | '_' { UNDERSCORE }
    | '(' { LPAREN }
    | ')' { RPAREN }
    | ['0'-'9']+ as s { INT(int_of_string s)}
    | ['a' - 'z'] ['a'-'z' 'A'-'Z' '0'-'9']* as s { REL(s) }
    | eof { EOF }
    | _ { MISC }