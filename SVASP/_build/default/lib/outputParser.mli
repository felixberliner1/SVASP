
(* The type of tokens. *)

type token = 
  | UNSAT
  | UNDERSCORE
  | SAT
  | RPAREN
  | REL of (string)
  | MISC
  | LPAREN
  | INT of (int)
  | GEN
  | EOF
  | COMMA
  | ANS

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val outinfo: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> ((int * string * int list) list option)
