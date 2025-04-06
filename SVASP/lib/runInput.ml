open InputAst
open Statements
open Query
open Output

(*
The following functions from lines 30 to 295 are all either functions for error checking or auxiliary functions for those error tests.
Here are all the errors that are tested for:

1. Make sure all appearing relations show up in domain declarations.
2. Make sure there is no crossover between puzzles, solutions, and ranges.
3. Make sure all all connections have an actual puzzle relation connected to them.
4. Make sure generation query contains all puzzle relations.
5. Basic syntax errors (doesn't parse correctly).
6. Make sure that all the domains for each relation in a domain declaration is a range.
7. Make sure the minimum is lower than maximum in a range.
8. Make sure all relations have the same length (checked against the domain declaration).
9. Make sure that connected components have matching variable amounts.
10. Make sure generate and find solution queries have positive integers.
11. Make sure all variables are bound.
12. Choice rule heads can only have a positive range on the right side.
13. There must be at least one solution relation.
*)

let rec find_args (domains : (string * string list) list) (check_string : string) : string list =
  match domains with
  | [] -> []
  | x :: x' -> 
    let (a,b) = x in
    if  a = check_string then b else find_args (x') (check_string)

let rec find_args_mult (domains : (string * string list) list) (check_strings : string list) : string list list =
  match check_strings with
  | [] -> []
  | a :: a' -> 
    find_args (domains) (a) :: find_args_mult (domains) (a')

let find_args_num (domains : (string * string list) list) (check_string : string) : int =
  List.length (find_args (domains) (check_string))

let rec find_args_num_mult (domains : (string * string list) list) (check_strings : string list) : int list =
  match check_strings with
  | [] -> []
  | a :: a' -> List.length (find_args (domains) (a)) :: find_args_num_mult (domains) (a')
  
let rec check_ranges (base_string : string) (ranges : (string * int * int) list) : bool =
  match ranges with
  | [] -> false
  | (a,_,_) :: r' -> if base_string = a then true else check_ranges (base_string) (r')

let rec find_disj_rels (domains : (string * string list) list) (puzzles : string list * int list list list) (ranges : (string * int * int) list) : string list * string list list =
  match domains with
  | [] -> ([],[])
  | x :: x' -> 
    let (a,b) = x in
    let (puznames,_) = puzzles in
    if List.mem a puznames || check_ranges (a) (ranges)
    then (find_disj_rels (x') (puzzles) (ranges))
    else
      let (a', b') = find_disj_rels (x') (puzzles) (ranges) in 
      (a::a', b::b')

let rec split_input_gen (x : (int * string) list) : int list * string list =
  match x with
  | [] -> ([],[])
  | (a,b) :: rest -> let (c,d) = split_input_gen (rest) in (a :: c, b :: d)

let rec find_gen_puzzle_input (x : string) (puzzles : string list * int list list list) : int list list =
  match puzzles with
  | ([], []) -> []
  | (a :: a', b :: b') -> if (a = x) then (b) else (find_gen_puzzle_input (x) (a', b'))
  | _ -> failwith "Internal Error: Puzzle Info Mismatch"

let rec find_gen_puzzle_inputs (findPuzzle : string list) (puzzles : string list * int list list list) : int list list list =
  match findPuzzle with
  | [] -> []
  | x :: x' -> (find_gen_puzzle_input (x) (puzzles)) :: find_gen_puzzle_inputs (x') (puzzles) 

let rec add_to_puzzle (puzzles : string list * int list list list) (added_puz : string * int list list) : string list * int list list list =
  match puzzles with
  | ([],[]) -> let (a,b) = added_puz in (a :: [], b :: [])
  | (a :: a', b :: b') -> 
    let (added_string, added_ints) = added_puz in
    if a = added_string then (a :: a', (b @ added_ints) :: b') else (let (a'', b'') = add_to_puzzle(a', b') (added_puz) in (a :: a'', b :: b''))
  | _ -> failwith "Puzzle info mismatch.\n"

let rec split_ranges (ranges : (string * int * int) list) : string list =
  match ranges with
  | [] -> []
  | (a,_,_) :: ranges' -> a :: split_ranges (ranges')

let rec check_domain_range_aux (ranges : (string * int * int) list) (domain : string * string list) = 
  match domain with
  | (_, []) -> ()
  | (name, a :: args) -> 
    let b = split_ranges(ranges) in
    if List.mem a b then check_domain_range_aux (ranges) (name, args) else failwith ("Error with range declaration of " ^ name ^ ": " ^ a ^ " is not a range.\n")

let rec check_domain_range (ranges : (string * int * int) list) (domains : (string * string list) list) =
  match domains with
  | [] -> ()
  | x :: x' -> check_domain_range_aux (ranges) (x); check_domain_range (ranges) (x')

let rec check_gen_correctness (gq : (int * string) list) (puzzles : string list * int list list list) =
  match gq with
  | [] -> ()
  | (num, name) :: gq' -> 
    let (a, _) = puzzles in
    if (num >= 0) then (if (List.mem name a) then (check_gen_correctness (gq') (puzzles)) else (failwith ("Error: " ^ name ^ " is not a puzzle relation.\n"))) else (failwith "Error: please generate a puzzle amount greater to or equal to 0.\n")

let rec check_puz_lengths (puzzles : string list * int list list list) (domains : (string * string list) list) = 
  match puzzles with
  | ([],[]) -> ()
  | (name :: names, args :: args') -> 
    let arg_length = find_args_num (domains) (name) in
    (
      match args with
      | [] -> check_puz_lengths (names, args') (domains)
      | a :: a' -> if List.length a = arg_length then check_puz_lengths (name :: names, (a') :: args') (domains) else failwith ("Error: " ^ name ^ " does not have correct number of arguments.\n")
    )
  | _ -> failwith "Puzzle info mismatch.\n"

let rec check_connection_correctness (connections : string list * string list) (puzzles : string list * int list list list) (domains : (string * string list) list) =
  match connections with
  | ([],[]) -> ()
  |(sol_name :: sol_names, puz_name :: puz_names) -> 
    let (a,_) = puzzles in
    if List.mem puz_name a then (if (find_args_num (domains) (sol_name) = find_args_num (domains) (puz_name)) then (check_connection_correctness (sol_names, puz_names) (puzzles) (domains)) else (failwith ("Connection Error: " ^ sol_name ^ " and " ^ puz_name ^ " have different numbers of arguments.\n"))) else (failwith ("Connection Error: " ^ puz_name ^ " is not a puzzle relation.\n"))
  | _ -> failwith "Connection info mismatch.\n"

let rec check_crossover_aux (puzzles : string list) (ranges : string list) =
  match puzzles with
  | [] -> ()
  | x :: x' -> if List.mem x ranges then (failwith ("Error: " ^ x ^ " is a puzzle and range relation.\n")) else check_crossover_aux (x') (ranges)

let rec check_crossover (solutions : string list) (puzzles : string list * int list list list) (ranges : (string * int * int) list) =
  let range_names = split_ranges (ranges) in
  let (puz_names, _) = puzzles in
  match solutions with
  | [] -> 
    check_crossover_aux (puz_names) (range_names)
  | x :: x' -> 
    if List.mem x puz_names then (failwith ("Error: " ^ x ^ " is a solution and puzzle relation.\n")) else 
    (
      if List.mem x range_names then (failwith ("Error: " ^ x ^ " is a solution and range relation.\n")) else check_crossover (x') (puzzles) (ranges)
    )

let rec check_body_for_domain_dec (body_list : body list) (disj_rels : string list) (puzzles : string list) (ranges : string list)=
  match body_list with
  | [] -> ()
  | Math _ :: x -> check_body_for_domain_dec (x) (disj_rels) (puzzles) (ranges)
  | Atom (Pos (rel_name, _)) :: x -> 
    if (List.mem rel_name disj_rels) then (check_body_for_domain_dec (x) (disj_rels) (puzzles) (ranges)) else (if (List.mem rel_name puzzles || List.mem rel_name ranges) then (check_body_for_domain_dec (x) (disj_rels) (puzzles) (ranges)) else (failwith ("Error: " ^ rel_name ^ " does not have a domain declaration.\n")))
  | Atom (Neg (rel_name, _)) :: x -> 
    if (List.mem rel_name disj_rels) then (check_body_for_domain_dec (x) (disj_rels) (puzzles) (ranges)) else (if (List.mem rel_name puzzles || List.mem rel_name ranges) then (check_body_for_domain_dec (x) (disj_rels) (puzzles) (ranges)) else (failwith ("Error: " ^ rel_name ^ " does not have a domain declaration.\n")))
  | _ :: x -> check_body_for_domain_dec (x) (disj_rels) (puzzles) (ranges)

let check_statement_for_domain_dec (rule : statement) (disj_rels : string list) (puzzles : string list) (ranges : string list)= 
  match rule with
  | Contradiction body_list -> check_body_for_domain_dec (body_list) (disj_rels) (puzzles) (ranges)
  | Rule (head_statement, body_list) -> 
    (
      match head_statement with
      | Atom (Pos (rel_name, _)) -> if (List.mem rel_name disj_rels) then (check_body_for_domain_dec (body_list) (disj_rels) (puzzles) (ranges)) else (if (List.mem rel_name puzzles || List.mem rel_name ranges) then (failwith ("Error: Statement heads should not contain puzzles or ranges.\n")) else (failwith ("Error: " ^ rel_name ^ " does not have a domain declaration.\n")))
      | Atom (Neg (rel_name, _)) -> if (List.mem rel_name disj_rels) then (check_body_for_domain_dec (body_list) (disj_rels) (puzzles) (ranges)) else (if (List.mem rel_name puzzles || List.mem rel_name ranges) then (failwith ("Error: Statement heads should not contain puzzles or ranges.\n")) else (failwith ("Error: " ^ rel_name ^ " does not have a domain declaration.\n")))
      | Choice (_, Pos (rel_name_l, _), Pos (rel_name_r, _)) ->
        if (List.mem rel_name_l disj_rels) then () else (if (List.mem rel_name_l puzzles || List.mem rel_name_l ranges) then (failwith "Error: left side of a choice cannot be a range or puzzle relation.\n") else (failwith ("Error: " ^ rel_name_l ^ " does not have a domain declaration.\n")));
        if (List.mem rel_name_r ranges) then () else (failwith ("Error: The right side of a choice statement must be a positive range.\n"));
        check_body_for_domain_dec (body_list) (disj_rels) (puzzles) (ranges)
      | Choice (_, Pos (_, _), Neg (_, _)) ->
        failwith ("Error: The right side of a choice statement must be a positive range.\n")
      | Choice (_, Neg (rel_name_l, _), Pos (rel_name_r, _)) ->
        if (List.mem rel_name_l disj_rels) then () else (if (List.mem rel_name_l puzzles || List.mem rel_name_l ranges) then (failwith "Error: left side of a choice cannot be a range or puzzle relation.\n") else (failwith ("Error: " ^ rel_name_l ^ " does not have a domain declaration.\n")));
        if (List.mem rel_name_r ranges) then () else (failwith ("Error: The right side of a choice statement must be a positive range.\n"));
        check_body_for_domain_dec (body_list) (disj_rels) (puzzles) (ranges)
      | Choice (_, Neg (_, _), Neg (_, _)) ->
        failwith ("Error: The right side of a choice statement must be a positive range.\n")
      | _ -> ()
    )
  | _ -> ()

let rec check_statements_for_domain_dec (rules : statement list) (disj_rels : string list) (puzzles : string list) (ranges : string list) =
  match rules with
  | [] -> ()
  | x :: x' -> 
    check_statement_for_domain_dec (x) (disj_rels) (puzzles) (ranges);
    check_statements_for_domain_dec (x') (disj_rels) (puzzles) (ranges)

let rec check_rel_lengths_body (body_list : body list) (domains : (string * string list) list) (ranges : (string * int * int) list) =
  match body_list with
  | [] -> ()
  | Math _ :: x -> check_rel_lengths_body (x) (domains) (ranges)
  | Atom (Pos (rel_name, elems)) :: x -> 
    let range_names = split_ranges (ranges) in
    if (List.mem rel_name range_names) then (if (List.length elems = 1) then (check_rel_lengths_body (x) (domains) (ranges)) else (failwith ("Error: " ^ rel_name ^ " is a range and should only have one element."))) else (if (List.length elems = (find_args_num (domains) (rel_name))) then (check_rel_lengths_body (x) (domains) (ranges)) else (failwith ("Error: " ^ rel_name ^ " needs " ^ string_of_int(find_args_num (domains) (rel_name)) ^ " elements.")))
  | Atom (Neg (rel_name, elems)) :: x -> 
    let range_names = split_ranges (ranges) in
    if (List.mem rel_name range_names) then (if (List.length elems = 1) then (check_rel_lengths_body (x) (domains) (ranges)) else (failwith ("Error: " ^ rel_name ^ " is a range and should only have one element."))) else (if (List.length elems = (find_args_num (domains) (rel_name))) then (check_rel_lengths_body (x) (domains) (ranges)) else (failwith ("Error: " ^ rel_name ^ " needs " ^ string_of_int(find_args_num (domains) (rel_name)) ^ " elements.")))
  | _  :: x -> check_rel_lengths_body (x) (domains) (ranges)

let rec check_rel_lengths (rules : statement list) (domains : (string * string list) list) (ranges : (string * int * int) list) =
  match rules with
  | [] -> ()
  | Contradiction body_list :: x -> check_rel_lengths_body (body_list) (domains) (ranges); check_rel_lengths (x) (domains) (ranges)
  | Rule (head_statement, body_list) :: x ->
    (
      match head_statement with
      | Atom (Pos (rel_name, elems)) -> 
        let range_names = split_ranges (ranges) in
        if (List.mem rel_name range_names) then (if (List.length elems = 1) then (check_rel_lengths_body (body_list) (domains) (ranges)) else (failwith ("Error: " ^ rel_name ^ " is a range and should only have one element."))) else (if (List.length elems = (find_args_num (domains) (rel_name))) then (check_rel_lengths_body (body_list) (domains) (ranges)) else (failwith ("Error: " ^ rel_name ^ " needs " ^ string_of_int(find_args_num (domains) (rel_name)) ^ " elements.")))
      | Atom (Neg (rel_name, elems)) -> 
        let range_names = split_ranges (ranges) in
        if (List.mem rel_name range_names) then (if (List.length elems = 1) then (check_rel_lengths_body (body_list) (domains) (ranges)) else (failwith ("Error: " ^ rel_name ^ " is a range and should only have one element."))) else (if (List.length elems = (find_args_num (domains) (rel_name))) then (check_rel_lengths_body (body_list) (domains) (ranges)) else (failwith ("Error: " ^ rel_name ^ " needs " ^ string_of_int(find_args_num (domains) (rel_name)) ^ " elements.")))
      | Choice (_, Pos (rel_name_l, elems_l), Pos (rel_name_r, elems_r)) ->
        let range_names = split_ranges (ranges) in
        if (List.mem rel_name_l range_names) then (if (List.length elems_l = 1) then () else (failwith ("Error: " ^ rel_name_l ^ " is a range and should only have one element."))) else (if (List.length elems_l = (find_args_num (domains) (rel_name_l))) then () else (failwith ("Error: " ^ rel_name_l ^ " needs " ^ string_of_int(find_args_num (domains) (rel_name_l)) ^ " elements.")));
        if (List.mem rel_name_r range_names) then (if (List.length elems_r = 1) then () else (failwith ("Error: " ^ rel_name_r ^ " is a range and should only have one element."))) else (if (List.length elems_r = (find_args_num (domains) (rel_name_r))) then () else (failwith ("Error: " ^ rel_name_r ^ " needs " ^ string_of_int(find_args_num (domains) (rel_name_r)) ^ " elements.")));
        check_rel_lengths_body (body_list) (domains) (ranges)
      | Choice (_, Neg (rel_name_l, elems_l), Pos (rel_name_r, elems_r)) ->
        let range_names = split_ranges (ranges) in
        if (List.mem rel_name_l range_names) then (if (List.length elems_l = 1) then () else (failwith ("Error: " ^ rel_name_l ^ " is a range and should only have one element."))) else (if (List.length elems_l = (find_args_num (domains) (rel_name_l))) then () else (failwith ("Error: " ^ rel_name_l ^ " needs " ^ string_of_int(find_args_num (domains) (rel_name_l)) ^ " elements.")));
        if (List.mem rel_name_r range_names) then (if (List.length elems_r = 1) then () else (failwith ("Error: " ^ rel_name_r ^ " is a range and should only have one element."))) else (if (List.length elems_r = (find_args_num (domains) (rel_name_r))) then () else (failwith ("Error: " ^ rel_name_r ^ " needs " ^ string_of_int(find_args_num (domains) (rel_name_r)) ^ " elements.")));
        check_rel_lengths_body (body_list) (domains) (ranges)
      | _ -> check_rel_lengths_body (body_list) (domains) (ranges)
    ); 
    check_rel_lengths (x) (domains) (ranges)
  | _  :: x -> check_rel_lengths (x) (domains) (ranges)

let rec safe_vs_unsafe (safe_vars : string list) (unsafe_vars : string list) =
  match unsafe_vars with
  | [] -> ()
  | x :: x' -> if List.mem x safe_vars then safe_vs_unsafe (safe_vars) (x') else failwith ("Error: " ^ x ^ " is unsafe.")

let rec add_elems_to_vars (var_list : string list) (elems : element list) : string list=
  match elems with
  | [] -> var_list
  | Number _ :: x' -> add_elems_to_vars (var_list) (x')
  | Symbol x :: x' -> if List.mem x var_list then add_elems_to_vars (var_list) (x') else add_elems_to_vars (x :: var_list) (x')

let rec add_elems_math_aux (vars : string list) (op : operation) : string list =
  match op with
  | Var x -> add_elems_to_vars (vars) (x :: [])
  | Addition (x,y) -> add_elems_math_aux (add_elems_math_aux (vars) (y)) (x)
  | Subtraction (x,y) -> add_elems_math_aux (add_elems_math_aux (vars) (y)) (x)
  | Multiplication (x,y) -> add_elems_math_aux (add_elems_math_aux (vars) (y)) (x)
  | Division (x,y) -> add_elems_math_aux (add_elems_math_aux (vars) (y)) (x)
  | Modulo (x,y) -> add_elems_math_aux (add_elems_math_aux (vars) (y)) (x)
  | Power (x,y) -> add_elems_math_aux (add_elems_math_aux (vars) (y)) (x)

let add_elems_math (x : comparison) (vars : string list) : string list =
  match x with
  | Equal (op_l, op_r) -> add_elems_math_aux (add_elems_math_aux (vars) (op_l)) (op_r)
  | NotEqual (op_l, op_r) -> add_elems_math_aux (add_elems_math_aux (vars) (op_l)) (op_r)
  | LessThan (op_l, op_r) -> add_elems_math_aux (add_elems_math_aux (vars) (op_l)) (op_r)
  | MoreThan (op_l, op_r) -> add_elems_math_aux (add_elems_math_aux (vars) (op_l)) (op_r)

let rec find_safe_unsafe_vars_body (body_args : body list) (safe_vars : string list) (unsafe_vars : string list) =
  match body_args with
  | [] -> safe_vs_unsafe (safe_vars) (unsafe_vars)
  | Atom (Pos (_, elems)) :: x -> find_safe_unsafe_vars_body (x) (add_elems_to_vars (safe_vars) (elems)) (unsafe_vars)
  | Atom (Neg (_, elems)) :: x -> find_safe_unsafe_vars_body (x) (add_elems_to_vars (safe_vars) (elems)) (unsafe_vars)
  | Math (comp) :: x -> find_safe_unsafe_vars_body (x) (safe_vars) (add_elems_math (comp) (unsafe_vars))
  | _ :: x -> find_safe_unsafe_vars_body (x) (safe_vars) (unsafe_vars)

let rec find_choice_safe_unsafe_var (left_elems : element list) (right_elem : element) =
  match left_elems with
  | [] -> failwith "Error: The right side of a choice must be a variable that appears on the left side."
  | Symbol x :: y -> if right_elem = Symbol x then () else find_choice_safe_unsafe_var (y) (right_elem)
  | Number _ :: y -> find_choice_safe_unsafe_var (y) (right_elem)

let rec find_head_vars (elems : element list) : string list =
  match elems with
  | [] -> []
  | Symbol x :: y -> x :: find_head_vars (y)
  | Number _ :: y -> find_head_vars (y)

let rec find_safe_unsafe_vars (rules : statement list) =
  match rules with
  | [] -> ()
  | Contradiction body_list :: x -> find_safe_unsafe_vars_body (body_list) ([]) ([]); find_safe_unsafe_vars (x)
  | Rule (head_statement, body_list) :: x ->
    (
      match head_statement with
      | Atom (Pos (_, elems)) -> find_safe_unsafe_vars_body (body_list) ([]) (find_head_vars (elems)); find_safe_unsafe_vars (x)
      | Atom (Neg (_, elems)) -> find_safe_unsafe_vars_body (body_list) ([]) (find_head_vars (elems)); find_safe_unsafe_vars (x)
      | Choice (_, Pos (_, elems_l), Pos (_, Symbol elem_r :: [])) -> find_choice_safe_unsafe_var (elems_l) (Symbol elem_r); find_safe_unsafe_vars_body (body_list) (elem_r :: []) (find_head_vars (elems_l)); find_safe_unsafe_vars_body (body_list) ([]) ([]); find_safe_unsafe_vars (x)
      | Choice (_, Neg (_, elems_l), Pos (_, Symbol elem_r :: [])) -> find_choice_safe_unsafe_var (elems_l) (Symbol elem_r); find_safe_unsafe_vars_body (body_list) (elem_r :: []) (find_head_vars (elems_l)); find_safe_unsafe_vars_body (body_list) ([]) ([]); find_safe_unsafe_vars (x)
      | _ -> failwith "Internal Error: Should not happen."
    )
  | _  :: x -> find_safe_unsafe_vars (x)

let check_empty_solutions (solutions : string list) =
  if (solutions = []) then failwith "Error: Please declare at least one solution relation." else ()

(*
convert_parsed_input takes in a list of SVASP statements, turns those into different variables, then once every statement has been read through, runs error checking on that data.
*)

let rec convert_parsed_input(x : t list) (rules : statement list) (solutions : string list) (puzzles : string list * int list list list) (domains : (string * string list) list) (ranges : (string * int * int) list) (connections : string list * string list) (q : emptyQuery) = 
  match x with
  | [] -> 
    (
      (*
      Once all statements have been sorted into data, various error tests are run to make sure no user errors have been made, and then the data is converted into the query data type.
      *)

      check_domain_range (ranges) (domains);
      check_connection_correctness (connections) (puzzles) (domains);
      check_crossover (solutions) (puzzles) (ranges);
      let (disj_rels,_) = find_disj_rels (domains) (puzzles) (ranges) in
      let (puz_rels, _) = puzzles in
      check_statements_for_domain_dec (rules) (disj_rels) (puz_rels) (split_ranges (ranges));
      check_puz_lengths (puzzles) (domains);
      check_rel_lengths (rules) (domains) (ranges);
      find_safe_unsafe_vars (rules);
      check_empty_solutions (solutions);
      match q with
      | E -> failwith "No queries.\n"
      | V -> 
        let (con_sols, con_puzs) = connections in
        let disj_rels = find_disj_rels (domains) (puzzles) (ranges) in
        ((alter_statements (rules) (Verification ((solutions, find_args_mult (domains) (solutions)), (con_sols, con_puzs, find_args_num_mult (domains) (solutions)), disj_rels, puzzles, ranges))), q)
      | U -> 
        let (con_sols, con_puzs) = connections in
        let disj_rels = find_disj_rels (domains) (puzzles) (ranges) in
        ((alter_statements (rules) (Uniqueness ((solutions, find_args_mult (domains) (solutions)), (con_sols, con_puzs, find_args_num_mult (domains) (solutions)), disj_rels, puzzles, ranges))), q)
      | F a -> 
        if a >= 0 then 
        (let (con_sols, con_puzs) = connections in
        let disj_rels = find_disj_rels (domains) (puzzles) (ranges) in
        ((alter_statements (rules) (FindSolutions (a, (solutions, find_args_mult (domains) (solutions)), (con_sols, con_puzs, find_args_num_mult (domains) (solutions)), disj_rels, puzzles, ranges)))), q)
        else failwith "Error: please enter a number of boards greater/equal to 0.\n"
      | G a' -> 
        let (a,b) = split_input_gen (a') in
        let gen_puzzles = (b, find_args_mult (domains) (b), a, find_gen_puzzle_inputs (b) (puzzles)) in
        let (con_sols, con_puzs) = connections in
        let disj_rels = find_disj_rels (domains) (puzzles) (ranges) in
        ((alter_statements (rules) (GeneratePuzzle ((con_sols, con_puzs, find_args_num_mult (domains) (solutions)), (solutions, find_args_mult (domains) (solutions)), gen_puzzles, disj_rels, ranges))), q)
    )
  (*
  Depending on the type of statement in input.txt, adds the corresponding data into the recursive function.
  *)
  | Stmt a :: x' -> convert_parsed_input (x') (a :: rules) (solutions) (puzzles) (domains) (ranges) (connections) (q)
  | RangeDec a :: x' -> 
    let (name, min, max) = a in
    if max < min then failwith ("Error (" ^ name ^ "): maximum is less than minimum.\n") else
    convert_parsed_input (x') (rules) (solutions) (puzzles) (domains) (a :: ranges) (connections) (q)
  | PuzDec(a,b) :: x' -> convert_parsed_input (x') (rules) (solutions) (add_to_puzzle (puzzles) (a,b)) (domains) (ranges) (connections) (q)
  | SolDec a :: x' -> convert_parsed_input (x') (rules) (a :: solutions) (puzzles) (domains) (ranges) (connections) (q)
  | SolConnectedDec (a,b) :: x' -> 
    let (a', b') = connections in
    convert_parsed_input (x') (rules) (a :: solutions) (puzzles) (domains) (ranges) (a::a', b::b') (q)
  | VQRY :: x' -> 
    (
      match q with
      | E -> convert_parsed_input (x') (rules) (solutions) (puzzles) (domains) (ranges) (connections) (V)
      | _ -> failwith "Error: Multiple queries.\n"
    )
  | UQRY :: x' ->
    (
      match q with
      | E -> convert_parsed_input (x') (rules) (solutions) (puzzles) (domains) (ranges) (connections) (U)
      | _ -> failwith "Error: Multiple Queries.\n"
    )
  | FQRY a :: x' ->
  (
    match q with
    | E -> convert_parsed_input (x') (rules) (solutions) (puzzles) (domains) (ranges) (connections) (F a)
    | _ -> failwith "Error: Multiple Queries.\n"
  )
  | GQRY a :: x' ->
  (
    let (b, _) = puzzles in
    if List.length a = List.length b then 
    (
    match q with
    | E -> convert_parsed_input (x') (rules) (solutions) (puzzles) (domains) (ranges) (connections) (G a)
    | _ -> failwith "Error: Multiple Queries.\n"
    )
    else failwith "Error: Please make sure all puzzles are included in the generate query."
  )
  | RelRange (a,b) :: x' -> 
    convert_parsed_input (x') (rules) (solutions) (puzzles) ((a,b) :: domains) (ranges) (connections) (q)

  (*
  This section of code contains the information for all the presets in SVASP.
  Each case is a different preset, in order to add more you just have to add more cases.
  *)
  
  | Use ("cell", a :: []) :: x' -> 
    let basic_rules = Statements.Rule(Choice(true, Pos("cell", Symbol "R" :: Symbol "C" :: Symbol "S" :: []), Pos("r", Symbol "R" :: [])), Atom(Pos("c", Symbol "C" :: [])) :: Atom(Pos("s", Symbol "S" :: [])) :: [])
    :: Rule(Choice(true, Pos("cell", Symbol "R" :: Symbol "C" :: Symbol "S" :: []), Pos("c", Symbol "C" :: [])), Atom(Pos("r", Symbol "R" :: [])) :: Atom(Pos("s", Symbol "S" :: [])) :: [])
    :: Rule(Choice(true, Pos("cell", Symbol "R" :: Symbol "C" :: Symbol "S" :: []), Pos("s", Symbol "S" :: [])), Atom(Pos("r", Symbol "R" :: [])) :: Atom(Pos("c", Symbol "C" :: [])) :: []) :: [] in
    let (cs, cp) = connections in
    convert_parsed_input (x') (basic_rules @ rules) ("cell" :: solutions) (add_to_puzzle(puzzles) ("clue", [])) (("cell", "r" :: "c" :: "s" :: []) :: ("clue", "r" :: "c" :: "s" :: []) :: domains) (("r", 1, a) :: ("c", 1, a) :: ("s", 1, a) :: ranges) ("cell" :: cs, "clue" :: cp) (q)
  | Use ("box", a :: b :: []) :: x' -> 
    let box_rules = 
      Rule(Atom(Pos("box", Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])), Atom(Pos("r", Symbol "R1" :: [])) :: Atom(Pos("c", Symbol "C1" :: [])) :: Atom(Pos("r", Symbol "R2" :: [])) :: Atom(Pos("c", Symbol "C2" :: [])) :: Math(Equal(Division(Subtraction(Var(Symbol "R1"), Var(Number 1)), Var(Number b)), Division(Subtraction(Var(Symbol "R2"), Var(Number 1)), Var(Number b)))) :: Math(Equal(Division(Subtraction(Var(Symbol "C1"), Var(Number 1)), Var(Number a)), Division(Subtraction(Var(Symbol "C2"), Var(Number 1)), Var(Number a)))) :: [])
      :: Rule(Atom(Neg("box", Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])), Atom(Pos("r", Symbol "R1" :: [])) :: Atom(Pos("c", Symbol "C1" :: [])) :: Atom(Pos("r", Symbol "R2" :: [])) :: Atom(Pos("c", Symbol "C2" :: [])) :: Math(NotEqual(Division(Subtraction(Var(Symbol "R1"), Var(Number 1)), Var(Number b)), Division(Subtraction(Var(Symbol "R2"), Var(Number 1)), Var(Number b)))) :: [])
      :: Rule(Atom(Neg("box", Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])), Atom(Pos("r", Symbol "R1" :: [])) :: Atom(Pos("c", Symbol "C1" :: [])) :: Atom(Pos("r", Symbol "R2" :: [])) :: Atom(Pos("c", Symbol "C2" :: [])) :: Math(NotEqual(Division(Subtraction(Var(Symbol "C1"), Var(Number 1)), Var(Number a)), Division(Subtraction(Var(Symbol "C2"), Var(Number 1)), Var(Number a)))) :: [])
      :: Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Atom(Pos("box", Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])) :: Math(NotEqual(Var(Symbol "R1"), Var(Symbol "R2"))) :: Math(NotEqual(Var(Symbol "C1"), Var(Symbol "C2"))) :: []) :: []
    in
    convert_parsed_input (x') (box_rules @ rules) (solutions) (puzzles) (("box", "r" :: "c" :: "r" :: "c" :: []) :: domains) (ranges) (connections) (q)
  | Use ("regions", a :: []) :: x' -> 
    let region_rules = Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Atom(Pos("regions", Symbol "N" :: Symbol "R1" :: Symbol "C1" :: [])) :: Atom(Pos("regions", Symbol "N" :: Symbol "R2" :: Symbol "C2" :: [])) :: Math(NotEqual(Var(Symbol "R1"), Var(Symbol "R2"))) :: Math(NotEqual(Var(Symbol "C1"), Var(Symbol "C2"))) :: []) :: [] in
    convert_parsed_input (x') (region_rules @ rules) (solutions) (add_to_puzzle(puzzles) ("regions", [])) (("regions", "regionNums" :: "r" :: "c" :: []) :: domains) (("regionNums", 1, a) :: ranges) (connections) (q)
  | Use ("germanWhisper", []) :: x' ->
    let germanWhisper_rules = Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("germanWhisper", Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])) :: Math(LessThan(Var(Symbol "S1"), Addition(Var(Symbol "S2"), Var(Number 5)))) :: Math(MoreThan(Var(Symbol "S1"), Subtraction(Var(Symbol "S2"), Var(Number 5)))) :: []) :: [] in
    convert_parsed_input (x') (germanWhisper_rules @ rules) (solutions) (add_to_puzzle(puzzles) ("germanWhisper", [])) (("germanWhisper", "r" :: "c" :: "r" :: "c" :: []) :: domains) (ranges) (connections) (q)
  | Use ("thermometer", []) :: x' ->
    let thermometer_rules = Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("thermometer", Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])) :: Math(MoreThan(Var(Symbol "S1"), Subtraction(Var(Symbol "S2"), Var(Number 1)))) :: []) :: [] in
    convert_parsed_input (x') (thermometer_rules @ rules) (solutions) (add_to_puzzle(puzzles) ("thermometer", [])) (("thermometer", "r" :: "c" :: "r" :: "c" :: []) :: domains) (ranges) (connections) (q)
  | Use ("kropki", []) :: x' ->
    let kropki_rules = 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("whiteKropki", Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])) :: Math(NotEqual(Var(Symbol "S1"), Subtraction(Var(Symbol "S2"), Var(Number 1)))) :: Math(NotEqual(Var(Symbol "S1"), Addition(Var(Symbol "S2"), Var(Number 1)))) :: []) ::
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("blackKropki", Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])) :: Math(NotEqual(Var(Symbol "S1"), Multiplication(Var(Symbol "S2"), Var(Number 2)))) :: Math(NotEqual(Var(Symbol "S2"), Multiplication(Var(Symbol "S1"), Var(Number 2)))) :: []) :: [] in
    convert_parsed_input (x') (kropki_rules @ rules) (solutions) (add_to_puzzle(add_to_puzzle(puzzles) ("blackKropki", [])) ("whiteKropki", [])) (("blackKropki", "r" :: "c" :: "r" :: "c" :: []) :: ("whiteKropki", "r" :: "c" :: "r" :: "c" :: []) :: domains) (ranges) (connections) (q)
  | Use ("killer", min :: max :: []) :: x' ->
    let killer_rules = 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("twoCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])) :: Math(NotEqual(Addition(Var(Symbol "S1"), Var(Symbol "S2")), Var(Symbol "Val"))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("twoCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: [])) :: Math(Equal(Var(Symbol "S1"), Var(Symbol "S2"))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("threeCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: [])) :: Math(NotEqual(Addition(Var(Symbol "S1"), Addition(Var(Symbol "S2"), Var(Symbol "S3"))), Var(Symbol "Val"))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("threeCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: [])) :: Math(Equal(Var(Symbol "S1"), Var(Symbol "S2"))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("threeCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: [])) :: Math(Equal(Var(Symbol "S1"), Var(Symbol "S3"))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("threeCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: [])) :: Math(Equal(Var(Symbol "S2"), Var(Symbol "S3"))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("cell", Symbol "R4" :: Symbol "C4" :: Symbol "S4" :: [])) :: Atom(Pos("fourCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: Symbol "R4" :: Symbol "C4" :: [])) :: Math(NotEqual(Addition(Addition(Var(Symbol "S1"), Var(Symbol "S2")), Addition(Var(Symbol "S3"), Var(Symbol "S4"))), Var(Symbol "Val"))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("cell", Symbol "R4" :: Symbol "C4" :: Symbol "S4" :: [])) :: Atom(Pos("fourCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: Symbol "R4" :: Symbol "C4" :: [])) :: Math(Equal(Var(Symbol "S1"), Var(Symbol "S2"))) :: []) ::
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("cell", Symbol "R4" :: Symbol "C4" :: Symbol "S4" :: [])) :: Atom(Pos("fourCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: Symbol "R4" :: Symbol "C4" :: [])) :: Math(Equal(Var(Symbol "S1"), Var(Symbol "S3"))) :: []) ::
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("cell", Symbol "R4" :: Symbol "C4" :: Symbol "S4" :: [])) :: Atom(Pos("fourCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: Symbol "R4" :: Symbol "C4" :: [])) :: Math(Equal(Var(Symbol "S1"), Var(Symbol "S4"))) :: []) ::
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("cell", Symbol "R4" :: Symbol "C4" :: Symbol "S4" :: [])) :: Atom(Pos("fourCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: Symbol "R4" :: Symbol "C4" :: [])) :: Math(Equal(Var(Symbol "S2"), Var(Symbol "S3"))) :: []) ::
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("cell", Symbol "R4" :: Symbol "C4" :: Symbol "S4" :: [])) :: Atom(Pos("fourCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: Symbol "R4" :: Symbol "C4" :: [])) :: Math(Equal(Var(Symbol "S2"), Var(Symbol "S4"))) :: []) ::
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S1" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S2" :: [])) :: Atom(Pos("cell", Symbol "R3" :: Symbol "C3" :: Symbol "S3" :: [])) :: Atom(Pos("cell", Symbol "R4" :: Symbol "C4" :: Symbol "S4" :: [])) :: Atom(Pos("fourCage", Symbol "Val" :: Symbol "R1" :: Symbol "C1" :: Symbol "R2" :: Symbol "C2" :: Symbol "R3" :: Symbol "C3" :: Symbol "R4" :: Symbol "C4" :: [])) :: Math(Equal(Var(Symbol "S3"), Var(Symbol "S4"))) :: []) :: [] in
    convert_parsed_input (x') (killer_rules @ rules) (solutions) (add_to_puzzle(add_to_puzzle (add_to_puzzle (puzzles) ("twoCage", [])) ("threeCage", [])) ("fourCage", []))  (("twoCage", "val" :: "r" :: "c" :: "r" :: "c" :: []) :: ("threeCage", "val" :: "r" :: "c" :: "r" :: "c" :: "r" :: "c" :: []) :: ("fourCage", "val" :: "r" :: "c" :: "r" :: "c" :: "r" :: "c" :: "r" :: "c" :: []) :: domains) (("val", min, max) :: ranges) (connections) (q)
  | Use ("knight", []) :: x' ->
    let knight_rules = 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Math(Equal(Var(Symbol "R2"), Addition(Var(Symbol "R1"), Var(Number 2)))) :: Math(Equal(Var(Symbol "C1"), Addition(Var(Symbol "C2"), Var(Number 1)))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Math(Equal(Var(Symbol "R2"), Addition(Var(Symbol "R1"), Var(Number 2)))) :: Math(Equal(Var(Symbol "C1"), Subtraction(Var(Symbol "C2"), Var(Number 1)))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Math(Equal(Var(Symbol "R2"), Subtraction(Var(Symbol "R1"), Var(Number 2)))) :: Math(Equal(Var(Symbol "C1"), Addition(Var(Symbol "C2"), Var(Number 1)))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Math(Equal(Var(Symbol "R2"), Subtraction(Var(Symbol "R1"), Var(Number 2)))) :: Math(Equal(Var(Symbol "C1"), Subtraction(Var(Symbol "C2"), Var(Number 1)))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Math(Equal(Var(Symbol "R2"), Addition(Var(Symbol "R1"), Var(Number 1)))) :: Math(Equal(Var(Symbol "C1"), Addition(Var(Symbol "C2"), Var(Number 2)))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Math(Equal(Var(Symbol "R2"), Subtraction(Var(Symbol "R1"), Var(Number 1)))) :: Math(Equal(Var(Symbol "C1"), Addition(Var(Symbol "C2"), Var(Number 2)))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Math(Equal(Var(Symbol "R2"), Addition(Var(Symbol "R1"), Var(Number 1)))) :: Math(Equal(Var(Symbol "C1"), Subtraction(Var(Symbol "C2"), Var(Number 2)))) :: []) :: 
      Contradiction(Atom(Pos("cell", Symbol "R1" :: Symbol "C1" :: Symbol "S" :: [])) :: Atom(Pos("cell", Symbol "R2" :: Symbol "C2" :: Symbol "S" :: [])) :: Math(Equal(Var(Symbol "R2"), Subtraction(Var(Symbol "R1"), Var(Number 1)))) :: Math(Equal(Var(Symbol "C1"), Subtraction(Var(Symbol "C2"), Var(Number 2)))) :: []) :: [] in
    convert_parsed_input (x') (knight_rules @ rules) (solutions) (puzzles) (domains) (ranges) (connections) (q)
  | Use (a, _) :: _ -> failwith ("Syntax error: incorrect 'use' with keyword " ^ a ^ ".\n")

(*
read_input reads the input.txt file using the input_ast.ml file as a syntax tree, input_lexer.mll as a lexer, and input_parser.mly as a parser.
This parsed data is then converted with the function convert_parsed_input into a query data type, and sent to output.ml's send_to_clingo function.
*)

let read_input () =
  let ic = open_in "input.txt" in
  let rec loop acc = 
    try 
      let l = input_line ic in
      loop (acc ^ "\n" ^ l)
    with End_of_file -> 
    let lexbuf = Lexing.from_string acc in
    let result = (try InputParser.main InputLexer.input_lang lexbuf with InputParser.Error -> print_string "Syntax Error: Incorrect Statement.\n"; []) in
    if result != [] then send_to_clingo (convert_parsed_input (result) ([]) ([]) ([],[]) ([]) ([]) ([],[]) (E)) else ()
  in
  loop "";;
