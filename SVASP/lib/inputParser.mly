%{
    open InputAst
    open Statements
%}

%token <int> INT
%token <string> REL
%token <string> VARIABLE
%token EOF
%token SEMICOLON LPAREN RPAREN LCURLY RCURLY COMMA
%token PLUS MINUS TIMES FSLASH BSLASH CARROT EQUALSIGN NEQUALSIGN LESS MORE
%token USE FORALL NEVER WHERE THEREIS NOT SOME ONE ST IN RANGE PUZZLE SOLUTION HAS DOMAIN FROM 
%token VERIFY UNIQUE FIND GENERATE 

%start main
%type <t list> main

%%

main:
    | list(statement) EOF {$1}
;

numelements:
    | INT {$1}
    | INT COMMA {$1} 
;

numelementsaux:
    | LPAREN list(numelements) RPAREN {$2} 
;

genaux: 
    | INT REL {$1, $2}
    | INT REL COMMA {$1, $2} 
;

elem:
    | VARIABLE { Symbol $1}
    | INT { Number $1 }
;

atom:
    | elem IN REL { Atom(Pos($3, $1 :: [])) }
    | elem NOT IN REL { Atom(Neg($4, $1 :: [])) }
    | LPAREN separated_list(COMMA, elem) RPAREN IN REL { Atom(Pos($5, $2)) }
    | LPAREN separated_list(COMMA, elem) RPAREN NOT IN REL { Atom(Neg($6, $2)) }
    | REL { Atom(Pos($1, [])) }
    | NOT REL { Atom(Neg($2, [])) }
;

choiceatom_r:
    | elem IN REL { Pos($3, $1 :: []) }
    | NOT elem IN REL { Neg($4, $2 :: []) }
    | LPAREN separated_list(COMMA, elem) RPAREN IN REL { Pos($5, $2) }
    | NOT LPAREN separated_list(COMMA, elem) RPAREN IN REL { Neg($6, $3) }
;

choiceatom_l:
    | elem IN REL { Pos($3, $1 :: []) }
    | NOT elem IN REL { Neg($4, $2 :: []) }
    | LPAREN separated_list(COMMA, elem) RPAREN IN REL { Pos($5, $2) }
    | NOT LPAREN separated_list(COMMA, elem) RPAREN IN REL { Neg($6, $3) }
;

headatom:
    | elem IN REL { Atom(Pos($3, $1 :: [])) }
    | elem NOT IN REL { Atom(Neg($4, $1 :: [])) }
    | LPAREN separated_list(COMMA, elem) RPAREN IN REL { Atom(Pos($5, $2)) }
    | LPAREN separated_list(COMMA, elem) RPAREN NOT IN REL { Atom(Neg($6, $2)) }
    | REL { Atom(Pos($1, [])) }
    | NOT REL { Atom(Neg($2, [])) }
;

math_inner:
    | VARIABLE { Var(Symbol $1) }
    | INT { Var(Number $1) }
    | LPAREN math_inner PLUS math_inner RPAREN { Addition($2, $4) }
    | LPAREN math_inner MINUS math_inner RPAREN { Subtraction($2, $4) }
    | LPAREN math_inner TIMES math_inner RPAREN { Multiplication($2, $4) }
    | LPAREN math_inner FSLASH math_inner RPAREN { Division($2, $4) }
    | LPAREN math_inner BSLASH math_inner RPAREN { Modulo($2, $4) }
    | LPAREN math_inner CARROT math_inner RPAREN { Power($2, $4) }
;

math_outer:
    | math_inner EQUALSIGN math_inner { Math(Equal($1, $3)) }
    | math_inner NEQUALSIGN math_inner { Math(NotEqual($1, $3)) }
    | math_inner LESS math_inner { Math(LessThan($1, $3)) }
    | math_inner MORE math_inner { Math(MoreThan($1, $3)) }
;

statement:
    | RANGE REL LPAREN INT COMMA INT RPAREN SEMICOLON {RangeDec ($2, $4, $6)}
    | USE REL SEMICOLON {Use ($2, [])}
    | USE REL LPAREN separated_list(COMMA, INT) RPAREN SEMICOLON {Use ($2, $4)}
    | PUZZLE REL LCURLY separated_list(COMMA, numelementsaux) RCURLY SEMICOLON {PuzDec ($2, $4)}
    | SOLUTION REL SEMICOLON {SolDec ($2)}
    | SOLUTION REL FROM REL SEMICOLON {SolConnectedDec ($2, $4)}
    | VERIFY SEMICOLON {VQRY}
    | UNIQUE SEMICOLON {UQRY}
    | FIND INT SEMICOLON {FQRY ($2)}
    | GENERATE LCURLY list(genaux) RCURLY SEMICOLON {GQRY ($3)}
    | REL HAS DOMAIN LPAREN separated_list(COMMA, REL) RPAREN SEMICOLON { RelRange ($1, $5) } 
    | NEVER separated_list(COMMA, atom) SEMICOLON { Stmt(Contradiction($2)) }
    | NEVER separated_list(COMMA, atom) WHERE separated_list(COMMA, math_outer) SEMICOLON { Stmt(Contradiction($2 @ $4)) }
    | FORALL separated_list(COMMA, atom) THEREIS headatom SEMICOLON { Stmt(Rule($4, $2)) }
    | FORALL separated_list(COMMA, atom) WHERE separated_list(COMMA, math_outer) THEREIS headatom SEMICOLON { Stmt(Rule($6, $2 @ $4)) }
    | FORALL separated_list(COMMA, atom) THEREIS SOME choiceatom_r ST choiceatom_l SEMICOLON { Stmt(Rule(Choice(false, $7, $5), $2)) }
    | FORALL separated_list(COMMA, atom) WHERE separated_list(COMMA, math_outer) THEREIS SOME choiceatom_r ST choiceatom_l SEMICOLON { Stmt(Rule(Choice(false, $9, $7), $2 @ $4)) }
    | FORALL separated_list(COMMA, atom) THEREIS ONE choiceatom_r ST choiceatom_l SEMICOLON { Stmt(Rule(Choice(true, $7, $5), $2)) }
    | FORALL separated_list(COMMA, atom) WHERE separated_list(COMMA, math_outer) THEREIS ONE choiceatom_r ST choiceatom_l SEMICOLON { Stmt(Rule(Choice(true, $9, $7), $2 @ $4)) }
;

