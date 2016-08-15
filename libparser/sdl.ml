open Core.Std

type term = [
  | `Var of string
  | `Lambda of string * term
  | `Application of term * term
]

let repeat_string (s : string) (num : int) =
  let rec repeat (r : string) (n : int) =
    if n <= 0 then
      r
    else
      repeat (r ^ s) (n - 1)
  in
  repeat "" num

let rec print (t : term) (level : int) (newline : bool) =
  match t with
    | `Var x -> x
    | `Lambda (v,t) ->
      (if newline then "\n" ^ (repeat_string " " level) else "")
         ^ "\\"
         ^ v
         ^ "."
         ^ (print t (level + 4) true)
    | `Application (t1, t2) -> "(" ^ (print t1 level false) ^ " " ^ (print t2 level false) ^ ")"
