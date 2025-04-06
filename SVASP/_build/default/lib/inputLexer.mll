{
    open InputParser
    exception SyntaxError of string
}

rule input_lang = parse
    | [' ' '\n' '\t'] { input_lang lexbuf }
    | ['0'-'9']+ as s { INT(int_of_string s) }
    | ';' { SEMICOLON }
    | '(' { LPAREN }
    | ')' { RPAREN }
    | ',' { COMMA }
    | '{' { LCURLY }
    | '}' { RCURLY }
    | '+' { PLUS }
    | '-' { MINUS }
    | '*' { TIMES }
    | '/' { FSLASH }
    | '\\' { BSLASH }
    | '^' { CARROT }
    | '=' { EQUALSIGN }
    | "!=" { NEQUALSIGN }
    | '<' { LESS }
    | '>' { MORE }
    | "use" { USE }
    | "forall" { FORALL }
    | "never" { NEVER }
    | "where" { WHERE }
    | "thereis" { THEREIS }
    | "not" { NOT }
    | "some" { SOME }
    | "one" { ONE }
    | "st" { ST }
    | "in" { IN }
    | "range" { RANGE }
    | "puzzle" { PUZZLE }
    | "solution" { SOLUTION }
    | "has" { HAS }
    | "domain" { DOMAIN }
    | "from" { FROM }
    | "verify" { VERIFY }
    | "unique" { UNIQUE }
    | "find" { FIND }
    | "generate" { GENERATE }
    | ['a'-'z'] ['a'-'z' 'A'-'Z' '0'-'9']* as s 
    { 
        let first = Char.escaped (Char.uppercase_ascii (String.get (s) (0))) in
        let len = String.length (s) - 1 in
        let rest = String.sub (s) (1) (len) in
        VARIABLE (first ^ rest)
    }
    | ['A'-'Z'] ['a'-'z' 'A'-'Z' '0'-'9']* as s 
    { 
        let first = Char.escaped (Char.lowercase_ascii (String.get (s) (0))) in
        let len = String.length (s) - 1 in
        let rest = String.sub (s) (1) (len) in
        REL (first ^ rest)
    }
    | _ {raise (SyntaxError ("Unexpected Character: " ^ Lexing.lexeme lexbuf ^ ".\n"))}
    | eof { EOF }