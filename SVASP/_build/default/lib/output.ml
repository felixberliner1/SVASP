open Unix
open Statements

type emptyQuery = 
  | E | V | U | F of int | G of ((int * string) list)

(*
organize_SAT_info and fild_rels_from_solution are functions that organize the data from the parsed Clingo output.
They take in a list of relations from Clingo's model, and based on the number attached to them sorts them into a list according to the solution they belong to.
*)

let rec find_rels_from_solution (rels : (int * string * (int list)) list) (solutionNum : int) : (string * (int list)) list =
  match rels with
  | [] -> []
  | (a,b,c) :: rels' -> if a = solutionNum then (b,c) :: (find_rels_from_solution (rels') (solutionNum)) else find_rels_from_solution (rels') (solutionNum)

let rec organize_SAT_info (rels : (int * string * (int list)) list) (solutionNum : int) : ((string * (int list)) list) list =
  match solutionNum with
  | 0 -> []
  | x -> (find_rels_from_solution (rels) (x)) :: organize_SAT_info (rels) (x - 1)

(*
The following three functions take Clingo's parsed output, and turns them into a string to show to the user.
The data is sorted into satisfying and unsatisfying results. If the result is satisfying, all of the solutions in the model are shown with their respective relations.
*)

let rec print_SAT_info_vars (vars : int list) : string =
  match vars with
  | [] -> ""
  | x :: [] -> string_of_int(x)
  | x :: x' -> string_of_int(x) ^ ", " ^ print_SAT_info_vars (x')

let rec print_SAT_info_rels (rels : (string * (int list)) list) : string =
  match rels with
  | [] -> ""
  | (a,b) :: [] -> a ^ "(" ^ (print_SAT_info_vars (b)) ^ ")"
  | (a,b) :: x -> a ^ "(" ^ (print_SAT_info_vars (b)) ^ "), " ^ print_SAT_info_rels (x)

let rec print_SAT_info_solutions (rels : ((string * (int list)) list) list) (solutionNum : int) : string = 
  match rels with
  | [] -> ""
  | x :: x' -> (print_SAT_info_solutions (x') (solutionNum - 1)) ^ "solution " ^ string_of_int(solutionNum) ^ ":\n{" ^ (print_SAT_info_rels (x)) ^ " }\n"

(*
The following two functions are the same as the above ones (taking Clingo output and turning it into a string), but specialized for the generation query. 
The only difference is that a solution "0" is used which stores the relations making up the generated puzzle instance. 
*)

let rec organize_SAT_info_gen (rels : (int * string * (int list)) list) (puzzle_components : (string * (int list)) list) (solution_components : (string * (int list)) list) : ((string * (int list)) list) list = 
  match rels with
  | [] -> ((puzzle_components) :: (solution_components) :: [])
  | (0,a,b) :: rels' -> organize_SAT_info_gen (rels') ((a,b) :: puzzle_components) (solution_components)
  | (1,a,b) :: rels' -> organize_SAT_info_gen (rels') (puzzle_components) ((a,b) :: solution_components)
  | _ -> []

let print_SAT_info_gen (rels : ((string * (int list)) list) list) : string = 
  match rels with
  | p :: s :: [] -> "Generated Puzzle: {\n" ^ (print_SAT_info_rels (p)) ^ " }\nPuzzle Solution: {\n" ^ (print_SAT_info_rels (s)) ^ " }\n"
  | _ -> failwith "Internal Error: Generate Parsing Failed.\n"

(*
This function calls the above auxiliary functions according to the type of result Clingo obtains, as well as the type of query the user asked for.
The result of this function should be a string that gets returned to the user.
*)

let print_result (unorged_info : ((int * string * (int list)) list) option) (query : emptyQuery) : string = 
  match (unorged_info, query) with
  | (None, V) -> "Puzzle is not verified.\n"
  | (None, U) -> "Puzzle is unique.\n"
  | (None, F (a)) -> string_of_int(a) ^ " solutions not found.\n"
  | (None, G (_) ) -> "No generation producing a unique puzzle found.\n"
  | (Some (x), V) -> let info = (organize_SAT_info (x) (1)) in "Puzzle is verified with the following solution:\n" ^ (print_SAT_info_solutions (info) (1))
  | (Some (x), U) -> let info = (organize_SAT_info (x) (2)) in "Puzzle is not unique, the following solutions are both possible:\n" ^ (print_SAT_info_solutions (info) (2))
  | (Some (x), F (a)) -> let info = (organize_SAT_info (x) (a)) in string_of_int(a) ^ " solutions have been found:\n" ^ (print_SAT_info_solutions (info) (a))
  | (Some (x), G _) -> let info = (organize_SAT_info_gen (x) ([]) ([])) in "Generation Found:\n" ^ (print_SAT_info_gen (info))
  | _ -> failwith "Internal Error: Query did not parse correctly"

let rec string_of_output (out : string list) : string =
  match out with
  | [] -> ""
  | x :: x' -> x ^ "\n" ^ string_of_output(x')

(*
send_to_Clingo takes a list of statements, calls statements.ml to turn those into a file, and then calls Clingo on that file.
The result from Clingo is then parsed using the output_lexer.mll and output_parser.mly files, and turned into data.
Finally, the above functions turn that data into a string, which is printed for the user to see.
*)

let send_to_clingo (a : Statements.statement list * emptyQuery) = 
  let (x,y) = a in
  write_statements(x);
  let (ocaml_stdout, ocaml_stdin, _) = open_process_full "clingo statements.lp" [||] in
  close_out ocaml_stdin;
  let out_str = string_of_output (In_channel.input_lines ocaml_stdout) in
  let lexbuf = Lexing.from_string (out_str) in
  let result = (try OutputParser.outinfo OutputLexer.out_lang lexbuf with OutputParser.Error -> print_string "Output Error : Clingo Statement Unreadable.\n"; None) in
  print_string (print_result (result) (y))