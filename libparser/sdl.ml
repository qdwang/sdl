open Core.Std

type t = 
  | Unit
  | IsType of string
  | OfType of string
  | Imply of t list

type 'a info = {
  raw: 'a;
  mutable t: t;
}

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
    | `Type x -> decorate_term "Type" x.raw
    | `Var x -> decorate_term "Var" x.raw
    | `VarAssign info ->
      let (v, t) = info.raw in  
      decorate_term "VarAssign" (v ^ "," ^ printAST t (level + 1))
    | `TypeDefine info -> 
      let (v, t) = info.raw in 
      decorate_term "TypeDefine" (v ^ "," ^ printAST t (level + 1))
    | `TypeWithVar info -> 
      let (v, t) = info.raw in 
      decorate_term "TypeWithVar" (v ^ "," ^ t)
    | `TypeImply info -> 
      let (t1, t2) = info.raw in 
      decorate_term "TypeImply" ((printAST t1 (level + 1)) ^
                                                        List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> printAST x (level + 1))))
    | `Lambda info -> 
      let (v, t) = info.raw in 
      decorate_term "Lambda" (v ^ "," ^ printAST t (level + 1))
    | `Application info -> 
      let (t1, t2) = info.raw in 
      decorate_term "Application" (printAST t1 (level + 1) ^
                                                        List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> " " ^ printAST x (level + 1))))
    )
