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

let rec print (t : term) (level : int) =
  "\n" ^ (repeat_string " " (level * 2)) ^
  (match t with
    | `Type x -> decorate_term "Type" x
    | `Var x -> decorate_term "Var" x
    | `VarAssign (v, t) -> decorate_term "VarAssign" (v ^ "," ^ print t (level + 1))
    | `TypeDefine (v, t) -> decorate_term "TypeDefine" (v ^ "," ^ print t (level + 1))
    | `TypeWithVar (v, t) -> decorate_term "TypeWithVar" (v ^ "," ^ t)
    | `TypeImply (t1, t2) -> decorate_term "TypeImply" ((print t1 (level + 1)) ^
                                                        List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> print x (level + 1))))
    | `Lambda (v,t) -> decorate_term "Lambda" (v ^ "," ^ print t (level + 1))
    | `Application (t1, t2) -> decorate_term "Application" (print t1 (level + 1) ^
                                                            List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> " " ^ print x (level + 1))))
    )
