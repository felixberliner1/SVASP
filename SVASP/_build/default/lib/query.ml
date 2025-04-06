open Statements

type query =
  | Verification of (string list * string list list) * (string list * string list * int list) * (string list * string list list) * (string list * int list list list) * ((string * int * int) list)
  | Uniqueness of (string list * string list list) * (string list * string list * int list) * (string list * string list list) * (string list * int list list list) * ((string * int * int) list)
  | FindSolutions of int * (string list * string list list) * (string list * string list * int list) * (string list * string list list) * (string list * int list list list) * ((string * int * int) list)
  | GeneratePuzzle of (string list * string list * int list) * (string list * string list list) * (string list * string list list * int list * int list list list) * (string list * string list list) * ((string * int * int) list)

(*
Auxiliary functions for the function check_statement below.
*)

let check_lit (x : literal) (query_components : string list) : bool = 
match x with 
| Pos (x',_) -> if List.mem (x') (query_components) then true else false
| Neg (x',_) -> if List.mem (x') (query_components) then true else false

let rec check_body (x : Statements.body list) (queryComponents : string list) : bool =
  match x with
  | [] -> false
  | Atom a :: b -> check_lit(a) (queryComponents) || check_body(b) (queryComponents)
  | Math _ :: b -> check_body(b) (queryComponents)
  | DependantAtom _ :: b -> check_body(b) (queryComponents)

let check_head (x : Statements.head) (queryComponents : string list) : bool =
  match x with
  | Atom a -> check_lit(a) (queryComponents)
  | Choice (_ , a , b) -> check_lit(a) (queryComponents) || check_lit(b) (queryComponents)
  | SpecChoice _ -> false
  | Disj _ -> false
  
(*
check_statement checks if a statement contains a relation in a given list, and if it does, returns true.
*)

let check_statement (x : Statements.statement) (queryComponents : string list) : bool =
  match x with
  | Contradiction a -> check_body(a) (queryComponents)
  | Rule (a , b) -> check_head(a) (queryComponents) || check_body(b) (queryComponents)
  | Range _ -> false 
  | Show _ -> false 
  | Const _ -> false

let rec elem_aux (cElements : int) : element list =
  if cElements < 1 then [] else Symbol("A_" ^ string_of_int(cElements)) :: elem_aux(cElements - 1)

(*
These functions differentiate the boards by making sure that each combination of solutions must have at least one differrent solution component.
*)

let rec diff_aux_2 (max : int) (min : int) (queryComponents : string list) (componentElementsList : int list) : Statements.statement list =
  if min < 1 then 
    (match (queryComponents, componentElementsList) with
    | ([],[]) -> []
    | (_ :: a, _ :: b) -> diff_aux_2(max) (max - 1) (a) (b) 
    | (_,_) -> [])
  else 
    (match (queryComponents, componentElementsList) with
    | ([],[]) -> []
    | (queryComponent :: _, componentElements :: _) -> 
      Rule(Atom(Pos("_diff", Number(max) :: Number(min) :: [])), Atom(Pos("not_" ^ queryComponent ^ "_" ^ string_of_int(max), elem_aux(componentElements))) :: Atom(Pos(queryComponent ^ "_" ^ string_of_int(min), elem_aux(componentElements))) :: []) 
      :: Rule(Atom(Pos("_diff", Number(max) :: Number(min) :: [])), Atom(Pos(queryComponent ^ "_" ^ string_of_int(max), elem_aux(componentElements))) :: Atom(Pos("not_" ^ queryComponent ^ "_" ^ string_of_int(min), elem_aux(componentElements))) :: []) 
      :: diff_aux_2(max) (min - 1) (queryComponents) (componentElementsList) 
    | (_,_) -> [])

let rec diff_aux_1 (x : int) (queryComponents : string list) (componentElements : int list) : Statements.statement list =
  if x < 1 then Contradiction(Atom(Neg("_diff", Symbol("P1") :: Symbol("P2") :: [])) :: Atom(Pos("_puzzles", Symbol("P1") :: [])) :: Atom(Pos("_puzzles", Symbol("P2") :: [])) :: Math(MoreThan(Var(Symbol("P1")), Var(Symbol("P2")))) :: []) :: []
  else diff_aux_2(x) (x - 1) (queryComponents) (componentElements) @ diff_aux_1(x - 1) (queryComponents) (componentElements)

let diff_puzzles (x : int) (queryComponents : string list) (componentElements : int list) : Statements.statement list =
  Range("_puzzles", 1, x) :: diff_aux_1 (x) (queryComponents) (componentElements)
  
(*
These functions add statements that make sure connected solution relations share the same data as their puzzle relations across different solutions.
*)

let rec shared_inp_aux (x : int) (solNames : string list) (inpNames : string list) (componentElementsList : int list) : Statements.statement list =
  match (solNames, inpNames, componentElementsList) with
  | ([],[],[]) -> []
  | (a :: a', b :: b', c :: c') -> Rule(Atom(Pos(a ^ "_" ^ string_of_int(x), elem_aux(c))), Atom(Pos(b, elem_aux(c))) :: []) :: shared_inp_aux (x) (a') (b') (c')
  | (_,_,_) -> []

let rec shared_inp (x : int) (solNames : string list) (inpNames : string list) (componentElementsList : int list) : Statements.statement list =
  if x < 1 then [] else shared_inp_aux (x) (solNames) (inpNames) (componentElementsList) @ shared_inp(x - 1) (solNames) (inpNames) (componentElementsList)

(*
These functions add statements that show the solution components for non-generation queries.
*)

let rec show_components_aux (x : int) (solNames : string list) (componentElementsList : int list) : Statements.statement list =
  match (solNames, componentElementsList) with
  | ([],[]) -> []
  | (a :: a', b :: b') -> Show(a ^ "_" ^ string_of_int(x), b) :: show_components_aux (x) (a') (b') 
  | (_,_) -> []

let rec show_components (x : int) (queryComponents : string list) (componentElementsList : int list) : Statements.statement list = 
  if x < 1 then [] else show_components_aux (x) (queryComponents) (componentElementsList) @ show_components(x - 1) (queryComponents) (componentElementsList)

(*
These functions add statements to choose x amounts of each puzzle relation when generating.
Only calleed for generation queries.
*)

let rec gpc_aux (x : int) : Statements.element list =
  match x with
  | 0 -> []
  | x' -> if x' < 0 then [] else Symbol("A" ^ string_of_int(x)) :: gpc_aux(x - 1)

let generate_puzzle_component (gen_name : string) (gen_rel_args : int) (gen_number : int) : Statements.statement list =
  Statements.Const(gen_name ^ "_num", gen_number) 
  :: Rule(SpecChoice(gen_name ^ "_num", Pos(gen_name ^ "_gen", gpc_aux(gen_rel_args)), Pos(gen_name, gpc_aux(gen_rel_args))), []) 
  :: Show(gen_name ^ "_gen", gen_rel_args)
  :: []

let rec generate_puzzle_components (gen_names : string list) (gen_rel_args : int list) (gen_numbers : int list) : Statements.statement list =
  match (gen_names, gen_rel_args, gen_numbers) with
  | ([], [], []) -> []
  | (a::a', b::b', c::c') -> generate_puzzle_component(a) (b) (c) @ generate_puzzle_components(a') (b') (c')
  | _ -> []

(*
The following functions handle disjunction for all non-puzzle relations. 
disj_solution_component and disj_nno_puzzle adds the matrix enforcement for these disjunctions.
The other functions handle the rest of the disjunction, and are generic to all queries.
*)

let rec dsc_aux (ranges : string list) : Statements.body list =
  match ranges with
  | [] -> []
  | a::b -> Atom(Pos(a, Symbol ("A" ^ string_of_int(List.length ranges)) :: [])) :: dsc_aux(b)

let rec disj_solution_component (sol_comp_names : string list) (sol_comp_ranges_list : string list list) : Statements.statement list =
  match (sol_comp_names, sol_comp_ranges_list) with
  | ([],[]) -> []
  | (sol_comp_name :: a, sol_comp_ranges :: b) -> 
    Rule(Atom(Pos("failed_gen", [])), DependantAtom(Pos(sol_comp_name ^ "_2", gpc_aux(List.length sol_comp_ranges)), Pos(sol_comp_name ^ "_1", gpc_aux(List.length sol_comp_ranges))) :: []) :: 
    Show(sol_comp_name ^ "_1", List.length sol_comp_ranges) :: disj_solution_component (a) (b)
  | (_,_) -> [] 

let rec non_puz_disj_aux_ngv (sol_comp_name : string) (sol_comp_ranges : string list) (board_num : int) : Statements.statement list =
  match board_num with
  | 0 -> []
  | x -> if x < 0 then [] else Rule(Disj(Pos(sol_comp_name ^ "_" ^ string_of_int(x), gpc_aux(List.length sol_comp_ranges)), Pos("not_" ^ sol_comp_name ^ "_" ^ string_of_int(x), gpc_aux(List.length sol_comp_ranges))), dsc_aux(sol_comp_ranges)) :: non_puz_disj_aux_ngv (sol_comp_name) (sol_comp_ranges) (x-1)

let rec disj_non_puzzle_nongenver (sol_comp_names : string list) (sol_comp_ranges : string list list) (board_num : int): Statements.statement list =
  match (sol_comp_names, sol_comp_ranges) with 
  | ([],[]) -> []
  | (a :: a', b :: b') -> non_puz_disj_aux_ngv (a) (b) (board_num) @ disj_non_puzzle_nongenver (a') (b') (board_num)
  | _ -> []

let rec non_puz_disj_aux (sol_comp_name : string) (sol_comp_ranges : string list) (board_num : int) : Statements.statement list =
  match board_num with
  | 0 -> []
  | x -> if x < 0 then [] else Rule(Disj(Pos(sol_comp_name ^ "_" ^ string_of_int(x), gpc_aux(List.length sol_comp_ranges)), Pos("not_" ^ sol_comp_name ^ "_" ^ string_of_int(x), gpc_aux(List.length sol_comp_ranges))), dsc_aux(sol_comp_ranges)) 
    :: non_puz_disj_aux (sol_comp_name) (sol_comp_ranges) (x-1)

let rec disj_non_puzzle (sol_comp_names : string list) (sol_comp_ranges : string list list) (board_num : int): Statements.statement list =
  match (sol_comp_names, sol_comp_ranges) with 
  | ([],[]) -> []
  | (a :: a', b :: b') -> non_puz_disj_aux (a) (b) (board_num) @ disj_non_puzzle (a') (b') (board_num) @ 
  Rule(Atom(Pos(a ^ "_2", gpc_aux(List.length b))), Atom(Pos("failed_gen", [])) :: dsc_aux(b))
  :: Rule(Atom(Pos("not_" ^ a ^ "_2", gpc_aux(List.length b))), Atom(Pos("failed_gen", [])) :: dsc_aux(b)) :: []
  | _ -> []

(*
Enforces connected components for generation queries.
*)

let rec puz_to_sol_component_gen (puz_comp_names : string list) (sol_comp_names : string list) (arg_nums : int list) : Statements.statement list =
  match (puz_comp_names, sol_comp_names, arg_nums) with
  | ([],[],[]) -> []
  | (puz_comp_name :: a, sol_comp_name :: 
    b, arg_num :: c) -> Contradiction(Atom(Pos(puz_comp_name ^ "_gen", gpc_aux(arg_num))) :: Atom(Pos("not_" ^ sol_comp_name ^ "_1", gpc_aux(arg_num))) :: [])
    :: Rule(Atom(Pos("failed_gen", [])), Atom(Pos(puz_comp_name ^ "_gen", gpc_aux(arg_num))) :: Atom(Pos("not_" ^ sol_comp_name ^ "_2", gpc_aux(arg_num))) :: []) :: puz_to_sol_component_gen (a) (b) (c)
  | (_,_,_) -> []

(*
This function handles the matrix :- not matrix part of the 2qbf conversion for generating.
*)

let gen_enforce_failed_gen () : Statements.statement list = 
  Rule(Atom(Pos("failed_gen", [])), Atom(Neg("failed_gen", [])) :: []) :: []

(*
The following functions handle the 2qbf conversion algorithm for the generation query. 
They are similar to the convert functions below, but add in the matrix relation, called "failed_gen".
Negate lit handles literals, body handles the body of a statement, nce_aux_two through neg_choice_aux handle a choice rule's head, 
and negate_rule controls all of those functions. negate_rules calls negate_rule for all statements.
*)

let negate_lit (x : Statements.literal) (first_board : bool) (sol_comps : string list) (puz_comps : string list) : Statements.literal =
  match x with
  | Pos(a,b) -> if check_lit (x) (sol_comps) then (if first_board then Pos(a ^ "_1", b) else Pos(a ^ "_2", b)) else (if check_lit (x) (puz_comps) then Pos(a ^ "_gen", b) else Pos(a, b))
  | Neg(a,b) -> if check_lit (x) (sol_comps) then (if first_board then Pos("not_" ^ a ^ "_1", b) else Pos("not_" ^ a ^ "_2", b)) else (if check_lit (x) (puz_comps) then Neg(a ^ "_gen", b) else Neg(a, b)) (*Last else should not happen*)

let rec negate_body (x : Statements.body list) (first_board : bool) (sol_comps : string list) (puz_comps : string list): Statements.body list =
  match x with
  | [] -> []
  | Atom a :: b -> Atom (negate_lit(a) (first_board) (sol_comps) (puz_comps)) :: negate_body(b) (first_board) (sol_comps) (puz_comps)
  | Math a :: b -> Math a :: negate_body(b) (first_board) (sol_comps) (puz_comps)
  | DependantAtom (a,b) :: c -> DependantAtom (negate_lit(a) (first_board) (sol_comps) (puz_comps), negate_lit(b) (first_board) (sol_comps) (puz_comps)) :: negate_body(c) (first_board) (sol_comps) (puz_comps) (*Should be negated but only for altered rules, never in orignal*)


let rec nce_aux_two (elems : Statements.element list) (a : Statements.element) (first_rel : bool) : Statements.element list =
  if first_rel then elems else (
  match a with
  | Symbol a_name -> 
    (match elems with
    | [] -> []
    | Symbol x :: x' -> if x = a_name then ((Symbol(x ^ "'")) :: (nce_aux_two(x') (a) (first_rel))) else ((Symbol(x)) :: (nce_aux_two(x') (a) (first_rel)))
    | Number x :: x' -> Number(x) :: nce_aux_two (x') (a) (first_rel))
  | _ -> [])

let nce_aux (a : Statements.element) (prime : bool): Statements.element =
  match a with
  | Symbol x -> if prime then Symbol (x ^ "'") else Symbol x
  | Number _ -> a

let neg_choice_exact_rule (a : Statements.literal) (b : Statements.literal) : Statements.body list =
  match b with
  | Pos(_, b_elem :: []) ->
    (match a with
    | Pos(a_name, a_elems) -> Atom (Pos(a_name, nce_aux_two(a_elems) (b_elem) (true))) :: Atom (Pos(a_name, nce_aux_two(a_elems) (b_elem) (false))) :: Math (LessThan(Var (nce_aux(b_elem) (false)), Var (nce_aux(b_elem) (true)))) :: []
    | Neg (a_name, a_elems) -> Atom (Neg(a_name, nce_aux_two(a_elems) (b_elem) (true))) :: Atom (Neg(a_name, nce_aux_two(a_elems) (b_elem) (false))) :: Math (LessThan(Var (nce_aux(b_elem) (false)), Var (nce_aux(b_elem) (true)))) :: [])
  | _ -> [] 

let negate_choice_aux (x : Statements.statement) (first_board : bool) (sol_comps : string list) (puz_comps : string list) : Statements.statement list =
  match x with
  | Rule (Choice (a,b,c), body_args) -> 
    (match b with
    | Pos (b_name,b_args) -> if a then 
      if first_board then 
        (Statements.Contradiction (negate_body(body_args @ neg_choice_exact_rule(b) (c)) (first_board) (sol_comps) (puz_comps)) :: Statements.Contradiction (negate_body(body_args @ DependantAtom(Neg(b_name, b_args),c) :: []) (first_board) (sol_comps) (puz_comps)) :: []) else 
        (Statements.Rule (Atom (Pos("failed_gen", [])), negate_body(body_args @ neg_choice_exact_rule(b) (c)) (first_board) (sol_comps) (puz_comps)) :: Statements.Rule (Atom (Pos("failed_gen", [])),negate_body(body_args @ DependantAtom(Neg(b_name, b_args),c) :: []) (first_board) (sol_comps) (puz_comps)) :: [])
      else if first_board then 
        (Statements.Contradiction (negate_body(body_args @ DependantAtom(b,c) :: []) (first_board) (sol_comps) (puz_comps)) :: []) 
      else (Statements.Rule (Atom (Pos("failed_gen", [])),negate_body(body_args @ DependantAtom(b,c) :: []) (first_board) (sol_comps) (puz_comps)) :: [])
    | _ -> x ::[])
  | _ -> x :: []

let negate_rule (x : Statements.statement) (first_board : bool) (sol_comps : string list) (puz_comps) : Statements.statement list =
  match x with
  | Statements.Contradiction a -> if first_board then (Statements.Contradiction (negate_body (a) (first_board) (sol_comps) (puz_comps)) :: []) else (Statements.Rule(Atom(Pos("failed_gen", [])), (negate_body (a) (first_board) (sol_comps) (puz_comps))) :: [])
  | Statements.Rule (a , b) -> 
    (match a with
    | Atom Pos(c,d) -> if first_board then Statements.Contradiction (negate_body(Atom (Neg(c,d)) :: b) (first_board) (sol_comps) (puz_comps)) :: [] else Statements.Rule(Atom(Pos("failed_gen", [])), (negate_body(Atom (Neg(c,d)) :: b) (first_board) (sol_comps) (puz_comps))) :: []
    | Atom Neg(c,d) -> if first_board then Statements.Contradiction (negate_body(Atom (Pos(c,d)) :: b) (first_board) (sol_comps) (puz_comps)) :: [] else Statements.Rule(Atom(Pos("failed_gen", [])), (negate_body(Atom (Pos(c,d)) :: b) (first_board) (sol_comps) (puz_comps))) :: [] 
    | Choice (_,_,_) -> negate_choice_aux (x) (first_board) (sol_comps) (puz_comps)
    | _ -> x :: [])
  | Statements.Range _ -> x :: [] 
  | Statements.Show _ -> x :: []
  | Statements.Const _ -> x :: []

let rec negate_rules (x : Statements.statement list) (first_board : bool) (sol_comps : string list) (puz_comps) : Statements.statement list =
  match x with
  | [] -> []
  | a :: a' -> negate_rule (a) (first_board) (sol_comps) (puz_comps) @ negate_rules (a') (first_board) (sol_comps) (puz_comps)

(*
The following functions perform the dnf simulation conversion for all queries besides generation.
convert_literal is called for all relations, and convert_body and convert_head are used on their corresponding portions of a statement.
*)

let convert_literal (x : Statements.literal) (solutionNum : int) (queryComponents : string list) (puz_components : string list): Statements.literal =
  match x with 
  | Pos (a , b) -> if check_lit(x) (queryComponents) then Pos(a ^ "_" ^ string_of_int(solutionNum), b) else Pos(a, b)
  | Neg (a , b) -> if check_lit(x) (queryComponents) then let a' = "not_" ^ a ^ "_" ^ string_of_int(solutionNum) in Pos(a', b) else (if List.mem (a) (puz_components) then Neg(a,b) else Pos("not_" ^ a, b))

let rec convert_body (x : Statements.body list) (solutionNum : int) (queryComponents : string list) (puz_components : string list): Statements.body list =
  match x with
  | [] -> []
  | Atom a :: b -> Statements.Atom (convert_literal(a) (solutionNum) (queryComponents) (puz_components)) :: convert_body(b) (solutionNum) (queryComponents) (puz_components)
  | Math a :: b -> Math a :: convert_body(b) (solutionNum) (queryComponents) (puz_components)
  | DependantAtom (a,c) :: b -> DependantAtom ((convert_literal (a) (solutionNum) (queryComponents) (puz_components)),c) :: convert_body(b) (solutionNum) (queryComponents) (puz_components)

let convert_head (x : Statements.head) (solutionNum : int) (queryComponents : string list) (puz_components : string list) : Statements.head =
  match x with
  | Atom a -> Atom (convert_literal(a) (solutionNum) (queryComponents) (puz_components))
  | Choice (a , b , c) -> let b' = convert_literal(b) (solutionNum) (queryComponents) (puz_components) in let c' = convert_literal(c) (solutionNum) (queryComponents) (puz_components) in Choice(a, b', c')
  | SpecChoice _ -> x
  | Disj (_,_) -> x

(*
convert_statement takes in a list of statements and converts them to the dnf format necessary for generating.
It calls the above functions depending on the part of the statement it is converting.
*)

let convert_statement (x : Statements.statement) (solutionNum : int) (queryComponents : string list) (puz_components : string list) : Statements.statement list =
  match x with
  | Statements.Contradiction a -> Statements.Contradiction (convert_body (a) (solutionNum) (queryComponents) (puz_components)) :: []
  | Statements.Rule (a , b) -> 
    (match a with
    | Atom Pos(a_name, a_args) -> Statements.Contradiction (convert_body (Atom(Neg(a_name, a_args)) :: b) (solutionNum) (queryComponents) (puz_components)) :: []
    | Atom Neg(a_name, a_args) -> Statements.Contradiction (convert_body (Atom(Pos(a_name, a_args)) :: b) (solutionNum) (queryComponents) (puz_components)) :: []
    | Choice (exact,y,z) -> 
      (match y with
      | Pos (y_name,y_args) -> if exact then (Statements.Contradiction (convert_body(b @ neg_choice_exact_rule(y) (z)) (solutionNum) (queryComponents) (puz_components)) :: Statements.Contradiction (convert_body(b @ DependantAtom(Neg(y_name, y_args),z) :: []) (solutionNum) (queryComponents) (puz_components)) :: [])
      else (Statements.Contradiction (convert_body(b @ DependantAtom(y,z) :: []) (solutionNum) (queryComponents) (puz_components)) :: []) 
      | _ -> x ::[])
    | _ -> x :: []
    )
  | Statements.Range _ -> x :: []
  | Statements.Show _ -> x :: []
  | Statements.Const _ -> x :: []

(*
These two functions split up statements based off of which solution they correspond to.
*)

let rec splitter(x : Statements.statement) (totalSolutions : int) (queryComponents : string list) (puz_components : string list) : Statements.statement list =
  if totalSolutions < 1 then [] else convert_statement(x) (totalSolutions) (queryComponents) (puz_components) @ splitter(x) (totalSolutions - 1) (queryComponents) (puz_components)

let split_statement (x : Statements.statement) (totalSolutions : int) (queryComponents : string list) (puz_components : string list) : Statements.statement list =
  if (check_statement(x) (queryComponents)) then (splitter(x) (totalSolutions) (queryComponents) (puz_components)) else x :: []  

let rec make_ranges (ranges : (string * int * int) list) : Statements.statement list =
  match ranges with
  | [] -> []
  | (a,b,c) :: r' -> Range(a,b,c) :: make_ranges(r')

(*
These functions create fact statements for each puzzle relation.
*)

let rec make_puz_elems (nums : int list) : Statements.element list =
  match nums with
  | [] -> []
  | x :: x' -> Number x :: make_puz_elems (x')

let rec make_puz_comp (puz_name : string) (puz_nums : int list list) : Statements.statement list =
  match puz_nums with
  | [] -> []
  | x :: x' -> Rule(Atom(Pos(puz_name, make_puz_elems (x))), []) :: make_puz_comp (puz_name) (x')

let rec make_puz_comps (puz_names : string list) (puz_nums : int list list list) : Statements.statement list =
  match (puz_names, puz_nums) with
  | ([],[]) -> []
  | (a :: a', b :: b') -> make_puz_comp(a) (b) @ make_puz_comps (a') (b')
  | (_,_) -> failwith "Internal Error : Puzzle relation mismatch"

(*
complete_gen is an auxiliary function called by alter_statements to make the alteration of the base statements easier to read, since generation is more complex.
*)

let complete_gen (base_rules : Statements.statement list) (puzzle_components : string list * int list * int list) (solution_components : string list * string list list) (p_to_s_components : string list * string list * int list) (norm_components : string list * string list list): Statements.statement list =
  let (a,b,c) = p_to_s_components in
  let (d,e) = solution_components in
  let (f,g,h) = puzzle_components in
  let (i,j) = norm_components in
  negate_rules (base_rules) (true) (i)  (f)
  @ negate_rules (base_rules) (false) (i) (f)
  @ gen_enforce_failed_gen ()
  @ puz_to_sol_component_gen (b) (a) (c)
  @ disj_solution_component (d) (e) 
  @ disj_non_puzzle (i) (j) (2)
  @ generate_puzzle_components (f) (g) (h)

let rec alter_aux (x : Statements.statement list) (totalSolutions : int) (sol_components : string list) (puz_components : string list) : Statements.statement list =
  match x with
  | [] -> []
  | a :: b -> split_statement(a) (totalSolutions) (sol_components) (puz_components) @ alter_aux(b) (totalSolutions) (sol_components) (puz_components)

let rec get_arg_lengths (x : string list list) : int list =
  match x with
  | [] -> []
  | curr :: x' -> List.length (curr) :: get_arg_lengths(x')

(*
alter_statements takes in data from a query, and uses it to alter a list of base statements using the above functions.
*)

let alter_statements (base_rules : Statements.statement list) (q : query) : Statements.statement list = 
  match q with
  | Verification ((solution_rels, sr_args) , (imp_sol_rels, imp_puz_rels, imp_args), (non_puz_rels, non_puz_args), (puz_rels, puz_inputs), ranges) -> show_components(1) (solution_rels) (get_arg_lengths (sr_args)) @ shared_inp(1) (imp_sol_rels) (imp_puz_rels) (imp_args) @ alter_aux(base_rules) (1) (non_puz_rels) (puz_rels) @ disj_non_puzzle_nongenver(non_puz_rels) (non_puz_args) (1) @ make_puz_comps (puz_rels) (puz_inputs) @ make_ranges (ranges)
  | Uniqueness ((solution_rels, sr_args) , (imp_sol_rels, imp_puz_rels, imp_args), (non_puz_rels, non_puz_args), (puz_rels, puz_inputs), ranges) -> show_components(2) (solution_rels) (get_arg_lengths (sr_args)) @ shared_inp(2) (imp_sol_rels) (imp_puz_rels) (imp_args) @ diff_puzzles(2) (solution_rels) (get_arg_lengths (sr_args)) @ alter_aux(base_rules) (2) (non_puz_rels) (puz_rels) @ disj_non_puzzle_nongenver(non_puz_rels) (non_puz_args) (2) @ make_puz_comps (puz_rels) (puz_inputs) @ make_ranges (ranges)
  | FindSolutions (board_num, (solution_rels, sr_args) , (imp_sol_rels, imp_puz_rels, imp_args), (non_puz_rels, non_puz_args), (puz_rels, puz_inputs), ranges) -> show_components(board_num) (solution_rels) (get_arg_lengths (sr_args)) @ shared_inp(board_num) (imp_sol_rels) (imp_puz_rels) (imp_args) @ diff_puzzles(board_num) (solution_rels) (get_arg_lengths (sr_args)) @ alter_aux(base_rules) (board_num) (non_puz_rels) (puz_rels) @ disj_non_puzzle_nongenver(non_puz_rels) (non_puz_args) (board_num) @ make_puz_comps (puz_rels) (puz_inputs) @ make_ranges (ranges)
  | GeneratePuzzle ((imp_sol_rels, imp_puz_rels, imp_args), (solution_rels, sr_args), (puz_rels, puz_args, puz_gen_nums, puz_inputs), (non_puz_rels, non_puz_args), ranges) -> complete_gen (base_rules) (puz_rels, get_arg_lengths (puz_args), puz_gen_nums) (solution_rels, sr_args) (imp_sol_rels, imp_puz_rels, imp_args) (non_puz_rels, non_puz_args) @ make_puz_comps (puz_rels) (puz_inputs) @ make_ranges (ranges)