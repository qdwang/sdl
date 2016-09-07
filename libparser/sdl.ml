type t = 
  | Unit
  | IsType of string * string
  | OfType of string
  | Imply of t list 
[@@deriving yojson]

(*type pos = [%import: Lexing.position] [@@deriving yojson]*)

type 'a info = {
  raw: 'a;
  pos: int;
  mutable t: t;
}  
[@@deriving yojson]

let gen_info s pos = {
  raw = s;
  pos = pos;
  t = Unit;
}

type term = [
  | `Type of string info
  | `TypeWithVar of (string * string) info
  | `TypeImply of (term * (term list)) info
  | `TypeDefine of (string * term) info
  | `VarAssign of (string * term) info
  | `Var of string info
  | `Lambda of (string * term) info
  | `Application of (term * (term list)) info
]  
[@@deriving yojson]

let message =
  fun s ->
    match s with
    | 61 ->
        "Unexcepted token `elem_term`\n"
    | 27 ->
        "Unexcepted token `atomic_term`\n"
    | 1 ->
        "Unexcepted token `VAR`\n"
    | 15 ->
        "Unexcepted token `PL VAR`\n"
    | 17 ->
        "Unexcepted token `PL VAR COLON VAR `\n"
    | 16 ->
        "Unexcepted token `PL VAR COLON`\n"
    | 33 ->
        "Unexcepted token `PL atomic_type_term nonempty_list(imply_term) `\n"
    | 14 ->
        "Unexcepted token `PL`\n"
    | 21 ->
        "Unexcepted token `PL atomic_type_term`\n"
    | 54 ->
        "Unexcepted token `NEWLINE`\n"
    | 53 ->
        "Unexcepted token `var_assign`\n"
    | 2 ->
        "Unexcepted token `VAR EQUAL`\n"
    | 49 ->
        "Unexcepted token `atomic_type_term`\n"
    | 57 ->
        "Unexcepted token `type_define`\n"
    | 23 ->
        "Unexcepted token `VAR`\n"
    | 22 ->
        "Unexcepted token `ARROW`\n"
    | 25 ->
        "Unexcepted token `atomic_elem_term `\n"
    | 35 ->
        "Unexcepted token `imply_term`\n"
    | 44 ->
        "Unexcepted token `VAR COLON`\n"
    | 47 ->
        "Unexcepted token `PL VAR`\n"
    | 46 ->
        "Unexcepted token `PL`\n"
    | 0 ->
        "Unexcepted token `prog`\n"
    | 19 ->
        "Unexcepted token `PL elem_term`\n"
    | 37 ->
        "Unexcepted token `atomic_elem_term `\n"
    | 4 ->
        "Unexcepted token `PL`\n"
    | 51 ->
        "Unexcepted token `NEWLINE`\n"
    | 6 ->
        "Unexcepted token `LAMBDA VAR`\n"
    | 8 ->
        "Unexcepted token `VAR`\n"
    | 7 ->
        "Unexcepted token `LAMBDA VAR DOT`\n"
    | 10 ->
        "Unexcepted token `PL VAR`\n"
    | 12 ->
        "Unexcepted token `PL VAR COLON VAR `\n"
    | 13 ->
        "Unexcepted token `PL VAR COLON VAR PR`\n"
    | 11 ->
        "Unexcepted token `PL VAR COLON`\n"
    | 41 ->
        "Unexcepted token `atomic_type_term `\n"
    | 9 ->
        "Unexcepted token `PL`\n"
    | 5 ->
        "Unexcepted token `LAMBDA`\n"
    | _ ->
        raise Not_found

