
(* The type of tokens. *)

type token = 
  | WHERE
  | VERIFY
  | VARIABLE of (string)
  | USE
  | UNIQUE
  | TIMES
  | THEREIS
  | ST
  | SOME
  | SOLUTION
  | SEMICOLON
  | RPAREN
  | REL of (string)
  | RCURLY
  | RANGE
  | PUZZLE
  | PLUS
  | ONE
  | NOT
  | NEVER
  | NEQUALSIGN
  | MORE
  | MINUS
  | LPAREN
  | LESS
  | LCURLY
  | INT of (int)
  | IN
  | HAS
  | GENERATE
  | FSLASH
  | FROM
  | FORALL
  | FIND
  | EQUALSIGN
  | EOF
  | DOMAIN
  | COMMA
  | CARROT
  | BSLASH

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (InputAst.t list)
