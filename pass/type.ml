open Libparser.Sdl
open Core.Std

let rec infer_type (tree : term) : t =
    match tree with
    | `Type info -> 
        info.t <- Type info.raw;
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
        let (_, t) = info.raw in
        info.t <- Type t;
        info.t
    | `TypeImply info ->
        let (t1, t2) = info.raw in
        let t_t1 = infer_type t1 in
        let t_t2 = List.map t2 ~f:infer_type in
        info.t <- Imply (t_t1 :: t_t2);
        info.t
    | `Lambda info ->
        let (var, t) = info.raw in
        let body_t = infer_type t in
        info.t <- Imply (match body_t with 
            | None -> [None]
            | Type x -> [Type var; Type x]
            | Imply lst -> Type var :: lst);
        info.t
    | `Application info ->
        (* TODO: type check *)
        info.t

let decorate_type (v : string) (t : t) =
  let rec print_t t =   
      match t with
        | None -> "None"
        | Type x -> x
        | Imply lst -> List.fold ~init:"" ~f:(^) (List.map lst ~f:(fun x -> " -> " ^ print_t x))
  in
  "[" ^ v ^ "|" ^ print_t t ^ "]"

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
    