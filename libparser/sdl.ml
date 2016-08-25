open Core.Std

type t = 
  | Unit
  | IsType of string
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