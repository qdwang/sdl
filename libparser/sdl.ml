type t = 
  | Unit
  | IsType of string * string
  | OfType of string
  | Imply of t list 
[@@deriving show]

type 'a info = {
  raw: 'a;
  mutable t: t;
}  
[@@deriving show]

let gen_info s = {
  raw = s;
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
[@@deriving show]

let message =
  fun s ->
    match s with
    | 59 ->
        "Ill-formed sentence\n"
    | 27 ->
        "Ill-formed atomic_elem_term\n"
    | 1 ->
        "Ill-formed prog\n"
    | 52 ->
        "Ill-formed NEWLINE\n"
    | 51 ->
        "Ill-formed lambda expression\n"
    | 2 ->
        "Ill-formed var_assign\n"
    | 47 ->
        "Ill-formed type_term\n"
    | 55 ->
        "Ill-formed sentence\n"
    | 23 ->
        "Ill-formed atomic term\n"
    | 22 ->
        "Ill-formed imply_term\n"
    | 31 ->
        "Ill-formed application\n"
    | 35 ->
        "Ill-formed imply_term\n"
    | 24 ->
        "Ill-formed atomic term\n"
    | 42 ->
        "Ill-formed type_define\n"
    | 45 ->
        "Ill-formed atomic_type_term\n"
    | 17 ->
        "Ill-formed atomic_type_term\n"
    | 16 ->
        "Ill-formed atomic_type_term\n"
    | 33 ->
        "Ill-formed atomic_type_term\n"
    | 44 ->
        "Ill-formed atomic_type_term\n"
    | 21 ->
        "Ill-formed atomic_type_term\n"
    | 0 ->
        "Unexcepted )\n"
    | 19 ->
        "Ill-formed atomic_elem_term\n"
    | 25 ->
        "Ill-formed elem term\n"
    | 4 ->
        "Ill-formed atomic term\n"
    | 49 ->
        "Ill-formed prog\n"
    | 6 ->
        "Ill-formed elem_term\n"
    | 8 ->
        "Ill-formed atomic term\n"
    | 7 ->
        "Ill-formed elem_term\n"
    | 10 ->
        "Ill-formed lambda_term\n"
    | 12 ->
        "Ill-formed lambda_term\n"
    | 13 ->
        "Ill-formed lambda_term\n"
    | 11 ->
        "Ill-formed lambda_term\n"
    | 39 ->
        "Ill-formed lambda_term\n"
    | 9 ->
        "Ill-formed lambda_term\n"
    | 15 ->
        "Ill-formed atomic term\n"
    | 14 ->
        "Ill-formed atomic_type_term\n"
    | 5 ->
        "Ill-formed elem_term\n"
    | _ ->
        raise Not_found
