
module MenhirBasics = struct
  
  exception Error
  
  let _eRR =
    fun _s ->
      raise Error
  
  type token = 
    | UNSAT
    | UNDERSCORE
    | SAT
    | RPAREN
    | REL of (
# 2 "lib/outputParser.mly"
       (string)
# 19 "lib/outputParser.ml"
  )
    | MISC
    | LPAREN
    | INT of (
# 1 "lib/outputParser.mly"
       (int)
# 26 "lib/outputParser.ml"
  )
    | GEN
    | EOF
    | COMMA
    | ANS
  
end

include MenhirBasics

type ('s, 'r) _menhir_state = 
  | MenhirState00 : ('s, _menhir_box_outinfo) _menhir_state
    (** State 00.
        Stack shape : .
        Start symbol: outinfo. *)

  | MenhirState09 : (('s, _menhir_box_outinfo) _menhir_cell1_list_junk_, _menhir_box_outinfo) _menhir_state
    (** State 09.
        Stack shape : list(junk).
        Start symbol: outinfo. *)

  | MenhirState12 : (('s, _menhir_box_outinfo) _menhir_cell1_junk, _menhir_box_outinfo) _menhir_state
    (** State 12.
        Stack shape : junk.
        Start symbol: outinfo. *)

  | MenhirState15 : (('s, _menhir_box_outinfo) _menhir_cell1_list_junk_ _menhir_cell0_INT, _menhir_box_outinfo) _menhir_state
    (** State 15.
        Stack shape : list(junk) INT.
        Start symbol: outinfo. *)

  | MenhirState19 : (('s, _menhir_box_outinfo) _menhir_cell1_REL _menhir_cell0_INT, _menhir_box_outinfo) _menhir_state
    (** State 19.
        Stack shape : REL INT.
        Start symbol: outinfo. *)

  | MenhirState21 : (('s, _menhir_box_outinfo) _menhir_cell1_INT, _menhir_box_outinfo) _menhir_state
    (** State 21.
        Stack shape : INT.
        Start symbol: outinfo. *)

  | MenhirState27 : (('s, _menhir_box_outinfo) _menhir_cell1_REL, _menhir_box_outinfo) _menhir_state
    (** State 27.
        Stack shape : REL.
        Start symbol: outinfo. *)

  | MenhirState30 : (('s, _menhir_box_outinfo) _menhir_cell1_relations, _menhir_box_outinfo) _menhir_state
    (** State 30.
        Stack shape : relations.
        Start symbol: outinfo. *)

  | MenhirState33 : ((('s, _menhir_box_outinfo) _menhir_cell1_list_junk_ _menhir_cell0_INT, _menhir_box_outinfo) _menhir_cell1_list_relations_, _menhir_box_outinfo) _menhir_state
    (** State 33.
        Stack shape : list(junk) INT list(relations).
        Start symbol: outinfo. *)


and ('s, 'r) _menhir_cell1_junk = 
  | MenhirCell1_junk of 's * ('s, 'r) _menhir_state * (unit)

and ('s, 'r) _menhir_cell1_list_junk_ = 
  | MenhirCell1_list_junk_ of 's * ('s, 'r) _menhir_state * (unit list)

and ('s, 'r) _menhir_cell1_list_relations_ = 
  | MenhirCell1_list_relations_ of 's * ('s, 'r) _menhir_state * ((int * string * int list) list)

and ('s, 'r) _menhir_cell1_relations = 
  | MenhirCell1_relations of 's * ('s, 'r) _menhir_state * (int * string * int list)

and ('s, 'r) _menhir_cell1_INT = 
  | MenhirCell1_INT of 's * ('s, 'r) _menhir_state * (
# 1 "lib/outputParser.mly"
       (int)
# 100 "lib/outputParser.ml"
)

and 's _menhir_cell0_INT = 
  | MenhirCell0_INT of 's * (
# 1 "lib/outputParser.mly"
       (int)
# 107 "lib/outputParser.ml"
)

and ('s, 'r) _menhir_cell1_REL = 
  | MenhirCell1_REL of 's * ('s, 'r) _menhir_state * (
# 2 "lib/outputParser.mly"
       (string)
# 114 "lib/outputParser.ml"
)

and _menhir_box_outinfo = 
  | MenhirBox_outinfo of ((int * string * int list) list option) [@@unboxed]

let _menhir_action_01 =
  fun () ->
    (
# 14 "lib/outputParser.mly"
           ( )
# 125 "lib/outputParser.ml"
     : (unit))

let _menhir_action_02 =
  fun () ->
    (
# 15 "lib/outputParser.mly"
          ( )
# 133 "lib/outputParser.ml"
     : (unit))

let _menhir_action_03 =
  fun () ->
    (
# 16 "lib/outputParser.mly"
          ( )
# 141 "lib/outputParser.ml"
     : (unit))

let _menhir_action_04 =
  fun () ->
    (
# 17 "lib/outputParser.mly"
            ( )
# 149 "lib/outputParser.ml"
     : (unit))

let _menhir_action_05 =
  fun () ->
    (
# 18 "lib/outputParser.mly"
             ( )
# 157 "lib/outputParser.ml"
     : (unit))

let _menhir_action_06 =
  fun () ->
    (
# 19 "lib/outputParser.mly"
             ( )
# 165 "lib/outputParser.ml"
     : (unit))

let _menhir_action_07 =
  fun () ->
    (
# 20 "lib/outputParser.mly"
           ( )
# 173 "lib/outputParser.ml"
     : (unit))

let _menhir_action_08 =
  fun () ->
    (
# 216 "<standard.mly>"
    ( [] )
# 181 "lib/outputParser.ml"
     : (unit list))

let _menhir_action_09 =
  fun x xs ->
    (
# 219 "<standard.mly>"
    ( x :: xs )
# 189 "lib/outputParser.ml"
     : (unit list))

let _menhir_action_10 =
  fun () ->
    (
# 216 "<standard.mly>"
    ( [] )
# 197 "lib/outputParser.ml"
     : ((int * string * int list) list))

let _menhir_action_11 =
  fun x xs ->
    (
# 219 "<standard.mly>"
    ( x :: xs )
# 205 "lib/outputParser.ml"
     : ((int * string * int list) list))

let _menhir_action_12 =
  fun () ->
    (
# 145 "<standard.mly>"
    ( [] )
# 213 "lib/outputParser.ml"
     : (int list))

let _menhir_action_13 =
  fun x ->
    (
# 148 "<standard.mly>"
    ( x )
# 221 "lib/outputParser.ml"
     : (int list))

let _menhir_action_14 =
  fun () ->
    (
# 33 "lib/outputParser.mly"
                            ( None )
# 229 "lib/outputParser.ml"
     : ((int * string * int list) list option))

let _menhir_action_15 =
  fun _4 ->
    (
# 34 "lib/outputParser.mly"
                                                  ( Some(_4) )
# 237 "lib/outputParser.ml"
     : ((int * string * int list) list option))

let _menhir_action_16 =
  fun _1 ->
    (
# 23 "lib/outputParser.mly"
                         ( (0, _1, []) )
# 245 "lib/outputParser.ml"
     : (int * string * int list))

let _menhir_action_17 =
  fun _1 xs ->
    let _5 = 
# 241 "<standard.mly>"
    ( xs )
# 253 "lib/outputParser.ml"
     in
    (
# 24 "lib/outputParser.mly"
                                                                  ( (0, _1, _5) )
# 258 "lib/outputParser.ml"
     : (int * string * int list))

let _menhir_action_18 =
  fun _1 _3 ->
    (
# 25 "lib/outputParser.mly"
                         ( (_3, _1, []) )
# 266 "lib/outputParser.ml"
     : (int * string * int list))

let _menhir_action_19 =
  fun _1 _3 xs ->
    let _5 = 
# 241 "<standard.mly>"
    ( xs )
# 274 "lib/outputParser.ml"
     in
    (
# 26 "lib/outputParser.mly"
                                                                  ( (_3, _1, _5) )
# 279 "lib/outputParser.ml"
     : (int * string * int list))

let _menhir_action_20 =
  fun x ->
    (
# 250 "<standard.mly>"
    ( [ x ] )
# 287 "lib/outputParser.ml"
     : (int list))

let _menhir_action_21 =
  fun x xs ->
    (
# 253 "<standard.mly>"
    ( x :: xs )
# 295 "lib/outputParser.ml"
     : (int list))

let _menhir_print_token : token -> string =
  fun _tok ->
    match _tok with
    | ANS ->
        "ANS"
    | COMMA ->
        "COMMA"
    | EOF ->
        "EOF"
    | GEN ->
        "GEN"
    | INT _ ->
        "INT"
    | LPAREN ->
        "LPAREN"
    | MISC ->
        "MISC"
    | REL _ ->
        "REL"
    | RPAREN ->
        "RPAREN"
    | SAT ->
        "SAT"
    | UNDERSCORE ->
        "UNDERSCORE"
    | UNSAT ->
        "UNSAT"

let _menhir_fail : unit -> 'a =
  fun () ->
    Printf.eprintf "Internal failure -- please contact the parser generator's developers.\n%!";
    assert false

include struct
  
  [@@@ocaml.warning "-4-37"]
  
  let _menhir_goto_outinfo : type  ttv_stack. ttv_stack -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _v ->
      MenhirBox_outinfo _v
  
  let _menhir_run_34 : type  ttv_stack. ((ttv_stack, _menhir_box_outinfo) _menhir_cell1_list_junk_ _menhir_cell0_INT, _menhir_box_outinfo) _menhir_cell1_list_relations_ -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _tok ->
      match (_tok : MenhirBasics.token) with
      | EOF ->
          let MenhirCell1_list_relations_ (_menhir_stack, _, _4) = _menhir_stack in
          let MenhirCell0_INT (_menhir_stack, _) = _menhir_stack in
          let MenhirCell1_list_junk_ (_menhir_stack, _, _) = _menhir_stack in
          let _v = _menhir_action_15 _4 in
          _menhir_goto_outinfo _menhir_stack _v
      | _ ->
          _eRR ()
  
  let _menhir_run_10 : type  ttv_stack. (ttv_stack, _menhir_box_outinfo) _menhir_cell1_list_junk_ -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _tok ->
      match (_tok : MenhirBasics.token) with
      | EOF ->
          let MenhirCell1_list_junk_ (_menhir_stack, _, _) = _menhir_stack in
          let _v = _menhir_action_14 () in
          _menhir_goto_outinfo _menhir_stack _v
      | _ ->
          _eRR ()
  
  let rec _menhir_run_01 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let _v = _menhir_action_06 () in
      _menhir_goto_junk _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_goto_junk : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_junk (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | RPAREN ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
      | REL _ ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
      | MISC ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
      | LPAREN ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
      | INT _ ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
      | COMMA ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState12
      | ANS | EOF | UNSAT ->
          let _v_2 = _menhir_action_08 () in
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v_2 _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_02 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let _v = _menhir_action_03 () in
      _menhir_goto_junk _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_03 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let _v = _menhir_action_01 () in
      _menhir_goto_junk _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_04 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let _v = _menhir_action_05 () in
      _menhir_goto_junk _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_05 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let _v = _menhir_action_02 () in
      _menhir_goto_junk _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_06 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let _v = _menhir_action_04 () in
      _menhir_goto_junk _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_13 : type  ttv_stack. (ttv_stack, _menhir_box_outinfo) _menhir_cell1_junk -> _ -> _ -> _ -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_junk (_menhir_stack, _menhir_s, x) = _menhir_stack in
      let xs = _v in
      let _v = _menhir_action_09 x xs in
      _menhir_goto_list_junk_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_goto_list_junk_ : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState33 ->
          _menhir_run_34 _menhir_stack _tok
      | MenhirState12 ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
      | MenhirState09 ->
          _menhir_run_10 _menhir_stack _tok
      | MenhirState00 ->
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_08 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_list_junk_ (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | UNSAT ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | RPAREN ->
              _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
          | REL _ ->
              _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
          | MISC ->
              _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
          | LPAREN ->
              _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
          | INT _ ->
              _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
          | COMMA ->
              _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState09
          | EOF ->
              let _ = _menhir_action_08 () in
              _menhir_run_10 _menhir_stack _tok
          | _ ->
              _eRR ())
      | ANS ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | INT _v_3 ->
              let _menhir_stack = MenhirCell0_INT (_menhir_stack, _v_3) in
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | REL _v_4 ->
                  _menhir_run_16 _menhir_stack _menhir_lexbuf _menhir_lexer _v_4 MenhirState15
              | SAT ->
                  let _v_5 = _menhir_action_10 () in
                  _menhir_run_32 _menhir_stack _menhir_lexbuf _menhir_lexer _v_5 MenhirState15
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_16 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | UNDERSCORE ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | INT _v_0 ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | LPAREN ->
                  let _menhir_stack = MenhirCell1_REL (_menhir_stack, _menhir_s, _v) in
                  let _menhir_stack = MenhirCell0_INT (_menhir_stack, _v_0) in
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  (match (_tok : MenhirBasics.token) with
                  | INT _v_1 ->
                      _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v_1 MenhirState19
                  | RPAREN ->
                      let _v_2 = _menhir_action_12 () in
                      _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v_2
                  | _ ->
                      _eRR ())
              | REL _ | SAT ->
                  let (_1, _3) = (_v, _v_0) in
                  let _v = _menhir_action_18 _1 _3 in
                  _menhir_goto_relations _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
              | _ ->
                  _eRR ())
          | GEN ->
              let _tok = _menhir_lexer _menhir_lexbuf in
              (match (_tok : MenhirBasics.token) with
              | LPAREN ->
                  let _menhir_stack = MenhirCell1_REL (_menhir_stack, _menhir_s, _v) in
                  let _tok = _menhir_lexer _menhir_lexbuf in
                  (match (_tok : MenhirBasics.token) with
                  | INT _v_3 ->
                      _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v_3 MenhirState27
                  | RPAREN ->
                      let _v_4 = _menhir_action_12 () in
                      _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v_4
                  | _ ->
                      _eRR ())
              | REL _ | SAT ->
                  let _1 = _v in
                  let _v = _menhir_action_16 _1 in
                  _menhir_goto_relations _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
              | _ ->
                  _eRR ())
          | _ ->
              _eRR ())
      | _ ->
          _eRR ()
  
  and _menhir_run_20 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | COMMA ->
          let _menhir_stack = MenhirCell1_INT (_menhir_stack, _menhir_s, _v) in
          let _menhir_s = MenhirState21 in
          let _tok = _menhir_lexer _menhir_lexbuf in
          (match (_tok : MenhirBasics.token) with
          | INT _v ->
              _menhir_run_20 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
          | _ ->
              _eRR ())
      | RPAREN ->
          let x = _v in
          let _v = _menhir_action_20 x in
          _menhir_goto_separated_nonempty_list_COMMA_INT_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_goto_separated_nonempty_list_COMMA_INT_ : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      match _menhir_s with
      | MenhirState27 ->
          _menhir_run_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | MenhirState19 ->
          _menhir_run_23 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | MenhirState21 ->
          _menhir_run_22 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_23 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      let x = _v in
      let _v = _menhir_action_13 x in
      _menhir_goto_loption_separated_nonempty_list_COMMA_INT__ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
  
  and _menhir_goto_loption_separated_nonempty_list_COMMA_INT__ : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      match _menhir_s with
      | MenhirState27 ->
          _menhir_run_28 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | MenhirState19 ->
          _menhir_run_24 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_28 : type  ttv_stack. (ttv_stack, _menhir_box_outinfo) _menhir_cell1_REL -> _ -> _ -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let MenhirCell1_REL (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let xs = _v in
      let _v = _menhir_action_17 _1 xs in
      _menhir_goto_relations _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_goto_relations : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_relations (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | REL _v_0 ->
          _menhir_run_16 _menhir_stack _menhir_lexbuf _menhir_lexer _v_0 MenhirState30
      | SAT ->
          let _v_1 = _menhir_action_10 () in
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v_1
      | _ ->
          _eRR ()
  
  and _menhir_run_31 : type  ttv_stack. (ttv_stack, _menhir_box_outinfo) _menhir_cell1_relations -> _ -> _ -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let MenhirCell1_relations (_menhir_stack, _menhir_s, x) = _menhir_stack in
      let xs = _v in
      let _v = _menhir_action_11 x xs in
      _menhir_goto_list_relations_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
  
  and _menhir_goto_list_relations_ : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      match _menhir_s with
      | MenhirState15 ->
          _menhir_run_32 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | MenhirState30 ->
          _menhir_run_31 _menhir_stack _menhir_lexbuf _menhir_lexer _v
      | _ ->
          _menhir_fail ()
  
  and _menhir_run_32 : type  ttv_stack. ((ttv_stack, _menhir_box_outinfo) _menhir_cell1_list_junk_ _menhir_cell0_INT as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_outinfo) _menhir_state -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      let _menhir_stack = MenhirCell1_list_relations_ (_menhir_stack, _menhir_s, _v) in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | RPAREN ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
      | REL _ ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
      | MISC ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
      | LPAREN ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
      | INT _ ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
      | COMMA ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState33
      | EOF ->
          let _ = _menhir_action_08 () in
          _menhir_run_34 _menhir_stack _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_24 : type  ttv_stack. (ttv_stack, _menhir_box_outinfo) _menhir_cell1_REL _menhir_cell0_INT -> _ -> _ -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let MenhirCell0_INT (_menhir_stack, _3) = _menhir_stack in
      let MenhirCell1_REL (_menhir_stack, _menhir_s, _1) = _menhir_stack in
      let xs = _v in
      let _v = _menhir_action_19 _1 _3 xs in
      _menhir_goto_relations _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_22 : type  ttv_stack. (ttv_stack, _menhir_box_outinfo) _menhir_cell1_INT -> _ -> _ -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v ->
      let MenhirCell1_INT (_menhir_stack, _menhir_s, x) = _menhir_stack in
      let xs = _v in
      let _v = _menhir_action_21 x xs in
      _menhir_goto_separated_nonempty_list_COMMA_INT_ _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
  
  let _menhir_run_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_outinfo =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | RPAREN ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | REL _ ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | MISC ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | LPAREN ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | INT _ ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | COMMA ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer MenhirState00
      | ANS | UNSAT ->
          let _v = _menhir_action_08 () in
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer _v MenhirState00 _tok
      | _ ->
          _eRR ()
  
end

let outinfo =
  fun _menhir_lexer _menhir_lexbuf ->
    let _menhir_stack = () in
    let MenhirBox_outinfo v = _menhir_run_00 _menhir_stack _menhir_lexbuf _menhir_lexer in
    v
