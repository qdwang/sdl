open Libparser.Sdl
open Core.Std

let get_option_string (s : string option) =
    match s with
      | Some x -> x
      | None -> ""

let rec infer_type (tree : term) =
    match tree with
    | `Type info -> 
        info.t <- Some info.raw;
        info.t
    | `Var info -> info.t
    | `VarAssign info ->
        let (var, t) = info.raw in
        info.t <- infer_type t;
        info.t
    | `TypeDefine info ->
        let (var, t) = info.raw in
        info.t <- infer_type t;
        info.t
    | `TypeWithVar info ->
        let (var, t) = info.raw in
        info.t <- Some t;
        info.t
    | `TypeImply info ->
        let (t1, t2) = info.raw in
        let t_t1 = get_option_string (infer_type t1) in
        let t_t2 =  List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> " -> " ^ get_option_string (infer_type x))) in
        info.t <- Some (t_t1 ^ t_t2);
        info.t
    | `Lambda info ->
        let (var, t) = info.raw in
        info.t <- infer_type t;
        info.t
    | `Application info ->
        let (t1, t2) = info.raw in
        let t_t1 = get_option_string (infer_type t1) in
        let t_t2 =  List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> " -> " ^ get_option_string (infer_type x))) in
        info.t <- Some (t_t1 ^ t_t2);
        info.t

let decorate_type (v : string) (t : string option) =
  "[" ^ v ^ "|" ^ get_option_string t ^ "]"

let rec printType (t : term) (level : int) =
  "\n" ^ (repeat_string " " (level * 2)) ^
  (match t with
    | `Type info -> decorate_type info.raw info.t
    | `Var info -> decorate_type info.raw info.t
    | `VarAssign info ->
      let (v, t) = info.raw in  
      decorate_type (v ^ "," ^ printType t (level + 1)) info.t
    | `TypeDefine info -> 
      let (v, t) = info.raw in 
      decorate_type (v ^ "," ^ printType t (level + 1)) info.t
    | `TypeWithVar info -> 
      let (v, t) = info.raw in 
      decorate_type (v ^ "," ^ t) info.t
    | `TypeImply info -> 
      let (t1, t2) = info.raw in 
      decorate_type ((printType t1 (level + 1)) ^ List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> printType x (level + 1))))
                    info.t
    | `Lambda info -> 
      let (v, t) = info.raw in 
      decorate_type (v ^ "," ^ printType t (level + 1)) info.t
    | `Application info -> 
      let (t1, t2) = info.raw in 
      decorate_type (printType t1 (level + 1) ^ List.fold ~init:"" ~f:(^) (List.map t2 ~f:(fun x -> " " ^ printType x (level + 1))))
                    info.t
    )
    