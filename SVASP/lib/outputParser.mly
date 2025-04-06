%token <int> INT
%token <string> REL
%token GEN ANS SAT UNSAT
%token COMMA UNDERSCORE LPAREN RPAREN
%token MISC
%token EOF

%start outinfo
%type <((int * string * (int list)) list) option> outinfo

%%

junk:
    | MISC { }
    | INT { }
    | REL { }
    | COMMA { }
    | LPAREN { }
    | RPAREN { }
    | MISC { };

relations:
    | REL UNDERSCORE GEN { (0, $1, []) }
    | REL UNDERSCORE GEN LPAREN separated_list(COMMA, INT) RPAREN { (0, $1, $5) }
    | REL UNDERSCORE INT { ($3, $1, []) }
    | REL UNDERSCORE INT LPAREN separated_list(COMMA, INT) RPAREN { ($3, $1, $5) };

data:
    | UNSAT { None }
    | ANS INT list(relations) SAT { Some ($3) };

outinfo:
    | junk* UNSAT junk* EOF { None }
    | junk* ANS INT list(relations) SAT junk* EOF { Some($4) };
