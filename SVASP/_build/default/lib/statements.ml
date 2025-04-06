type element = 
  | Number of int
  | Symbol of string

type literal_size = string * int

type literal = 
  | Pos of string * element list
  | Neg of string * element list

type operation = 
  | Var of element
  | Addition of operation * operation
  | Subtraction of operation * operation
  | Multiplication of operation * operation
  | Division of operation * operation
  | Modulo of operation * operation
  | Power of operation * operation

type comparison = 
  | Equal of operation * operation
  | NotEqual of operation * operation
  | LessThan of operation * operation
  | MoreThan of operation * operation

type body = 
  | Atom of literal
  | Math of comparison
  | DependantAtom of literal * literal

type head = 
  | Atom of literal
  | Choice of bool * literal * literal
  | SpecChoice of string * literal * literal (* Internal type only - users cannot access *)
  | Disj of literal * literal (* Internal type only - users cannot access *)

type statement =
  | Contradiction of body list 
  | Rule of head * body list 
  | Range of string * int * int
  | Show of string * int (* Internal type only - users cannot access *)
  | Const of string * int (* Internal type only - users cannot access *)

(*
write_lit turns individual relations into written Clingo equivalents. element_aux is an auxiliary function for write_lit.
*)

let rec element_aux (x : element list) : string =
  match x with
  | [] -> ""
  | a :: [] -> 
    (match a with
    | Number a' -> string_of_int(a')
    | Symbol a' -> a')
  | a :: b -> 
    match a with
    | Number a' -> string_of_int(a') ^ ", " ^ element_aux(b)
    | Symbol a' -> a' ^ ", " ^ element_aux(b)

let write_lit (x : literal) : string = 
  match x with
  | Pos (a , []) -> a
  | Neg (a , []) -> "not " ^ a
  | Pos (a , b) -> a ^ "(" ^ element_aux(b) ^ ")"
  | Neg (a , b) -> "not " ^ a ^ "(" ^ element_aux(b) ^ ")"

(*
Clingo math equations are made of two operation types (individual vars or operations like +, -, *, / ) connected by a comparison ( == , != , <, > ).
These are handled by write_operation and write_comparison respectively.
To disambiguate order of operations, all mathematical operations inside an operation must be enclosed in parenthesis.
*)

let rec write_operation (x : operation) : string =
  match x with
  | Var a -> 
    (match a with
    | Number a' -> string_of_int(a')
    | Symbol a' -> a')
  | Addition (a , b) -> "(" ^ write_operation(a) ^ ")" ^ " + (" ^ write_operation(b) ^ ")"
  | Subtraction (a , b) -> "(" ^ write_operation(a) ^ ")" ^ " - (" ^ write_operation(b) ^ ")"
  | Multiplication (a , b) -> "(" ^ write_operation(a) ^ ")" ^ " * (" ^ write_operation(b) ^ ")"
  | Division (a , b) -> "(" ^ write_operation(a) ^ ")" ^ " / (" ^ write_operation(b) ^ ")"
  | Modulo (a,b) -> "(" ^ write_operation(a) ^ ")" ^ " \\ (" ^ write_operation(b) ^ ")"
  | Power (a,b) -> "(" ^ write_operation(a) ^ ")" ^ " ** (" ^ write_operation(b) ^ ")"

let write_comparison (x : comparison) : string =
  match x with
  | Equal (a , b) -> write_operation(a) ^ " == " ^ write_operation(b)
  | NotEqual (a , b) -> write_operation(a) ^ " != " ^ write_operation(b)
  | LessThan (a , b) -> write_operation(a) ^ " < " ^ write_operation(b)
  | MoreThan (a , b) -> write_operation(a) ^ " > " ^ write_operation(b)

(*
write_body handles converting data for the body of a statement, which is either a relation, conditional, or math statement. 
These are handled accordingly using the above functions.
*)

let rec write_body (x : body list) : string = 
  match x with
  | [] -> "." 
  | a :: [] -> 
    (match a with
    | Atom a' -> write_lit(a') ^ "."
    | Math a' -> write_comparison(a') ^ "."
    | DependantAtom (x,y) -> write_lit(x) ^ " : " ^ write_lit(y) ^ ".")
  | a :: b -> 
    (match a with
    | Atom a' -> write_lit(a') ^ ", " ^ write_body(b)
    | Math a' -> write_comparison(a') ^ ", " ^ write_body(b)
    | DependantAtom (x,y) -> write_lit(x) ^ " : " ^ write_lit(y) ^ ", " ^ write_body(b))

(*
write_head handles converting data for the head of a statement, which is either a single atom, a choice, or disjunction. 
SpecChoice is only used for generating puzzle relations.
*)

let write_head (x : head) : string = 
  match x with 
  | Atom a -> write_lit(a)
  | Choice (a , b , c) -> 
    if a then "1 {" ^ write_lit(b) ^ " : " ^ write_lit(c) ^ "} 1" else "1 {" ^ write_lit(b) ^ " : " ^ write_lit(c) ^ "}"
  | SpecChoice(a, b, c) -> "{" ^ write_lit(b) ^ " : " ^ write_lit(c) ^ "} " ^ a 
  | Disj (a,b) -> write_lit(a) ^ " | " ^ write_lit(b) 

(*
write_statement converts a single statement to a Clingo statement. 
Most statements use a combination of a head and body, but some are simpler (Show, Range, Const) and do not require auxiliary functions.
*)

let write_statement (x : statement) : string =
  match x with
  | Contradiction a -> ":- " ^ write_body(a)
  | Rule (a , []) -> write_head(a) ^ "."
  | Rule (a , b) -> write_head(a) ^ " :- " ^ write_body(b)
  | Range (a , b , c) -> a ^ "(" ^ string_of_int(b) ^ ".." ^ string_of_int(c) ^ ")."
  | Show (a , b) -> "#show " ^ a ^ "/" ^ string_of_int(b) ^ "."
  | Const (a, b) -> "#const " ^ a ^ " = " ^ string_of_int(b) ^ "."

let rec string_of_statements (statements : statement list) : string =
  match statements with
  | [] -> ""
  | a :: b -> write_statement(a) ^ "\n" ^ string_of_statements(b)

(*
write_statements calls the above string_of_statements to perform all of the conversions, then writes the string to the file statements.lp.
*)

let write_statements (statements : statement list) =
  let oc = Out_channel.open_text "statements.lp" in
  let clingo_file = string_of_statements(statements) in
  Out_channel.output_string oc clingo_file;
  Out_channel.flush oc;
  Out_channel.close oc; 