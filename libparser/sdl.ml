open Core.Std

type term = [
  | `Type of string
  | `TypeWithVar of string * string
  | `TypeImply of term * (term list)
  | `TypeDefine of string * term
  | `VarAssign of string * term
  | `Var of string
  | `Lambda of string * term
  | `Application of term * (term list)
]

let repeat_string (s : string) (num : int) =
  let rec repeat (r : string) (n : int) =
    if n <= 0 then
      r
    else
      repeat (r ^ s) (n - 1)
  in
  repeat "" num

let decorate_term (t : string) (v : string) =
  "[" ^ t ^ "|" ^ v ^ "]"

let rec printAST (t : term) (level : int) =
  "\n" ^ (repeat_string " " (level * 2)) ^
  (match t with
    | `Type x -> decorate_term "Type" x
    | `Var x -> decorate_term "Var" x
    | `VarAssign (v, t) -> decorate_term "VarAssign" (v ^ "," ^ printAST t (level + 1))
    | `TypeDefine (v, t) -> decorate_term "TypeDefine" (v ^ "," ^ printAST t (level + 1))
    | `TypeWithVar (v, t) -> decorate_term "TypeWithVar" (v ^ "," ^ t)
    | `TypeImply (t1, t2) -> decorate_term "TypeImply" ((printAST t1 (level + 1)) ^
                                                        List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> printAST x (level + 1))))
    | `Lambda (v,t) -> decorate_term "Lambda" (v ^ "," ^ printAST t (level + 1))
    | `Application (t1, t2) -> decorate_term "Application" (printAST t1 (level + 1) ^
                                                            List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> " " ^ printAST x (level + 1))))
    )
