open Libparser.Sdl
open Core.Std

type env = {
    root: (env * int) option;
    mutable stack: (string * t) list;
}

let list_split (lst : 'a list) (pos_to_top : int) =
    let rec split lst1 lst2 p =
        if p <= 0 then 
            (lst1, lst2)
        else
            match lst1 with
                | [] -> (lst1, lst2)
                | hd :: tl -> split (hd :: lst1) lst2 (p - 1) in
    split [] lst pos_to_top  

let rec find_in_env (var : string) (env : env) (pos_to_bottom : int option) = 
    let result = List.find (match pos_to_bottom with 
            | None -> env.stack  
            | Some pos -> let (lst1, lst2) = list_split env.stack (List.length env.stack - pos) in lst2
        ) (fun x -> let (s, t) = x in s = var)
        in
    match (result, env.root) with
        | None, Some (root_env, root_pos) -> find_in_env var root_env (Some root_pos) 
        | Some v, _ -> Some v
        | None, None -> None

let global_env = {root = None; stack = []}

let rec infer_type (current_env : env) (tree : term)  : t =
    match tree with
    | `Type info -> 
        info.t <- TYPE;
        info.t
    | `Var info -> 
        let result = find_in_env info.raw current_env None in
        (match result with
            | None -> info.t <- Unit
            | Some (_, t) -> info.t <- t);
        info.t
    | `VarAssign info ->
        (* TODO: type check *)
        info.t
    | `TypeDefine info ->
        let (var, t) = info.raw in
        info.t <- infer_type current_env t;
        current_env.stack <- (var, info.t) :: current_env.stack;
        info.t
    | `TypeWithVar info ->
        let (var, t) = info.raw in
        info.t <- Type t;
        current_env.stack <- (var, info.t) :: current_env.stack;
        info.t
    | `TypeImply info ->
        let (t1, t2) = info.raw in
        let current_env = {root = Some (current_env, List.length current_env.stack); stack = []} in 
        let t_t1 = infer_type current_env t1 in
        let t_t2 = List.map t2 ~f:(infer_type current_env) in
        info.t <- Imply (t_t1 :: t_t2);
        info.t
    | `Lambda info ->
        let (var, t) = info.raw in
        let current_env = {root = Some (current_env, List.length current_env.stack); stack = []} in 
        let body_t = infer_type current_env t in
        info.t <- (match body_t with 
            | Unit -> Unit
            | TYPE -> Imply [Unit; TYPE]
            | Type x -> Imply [Unit; Type x]
            | Imply lst -> Imply (Unit :: lst));
        current_env.stack <- (var, info.t) :: current_env.stack;
        info.t
    | `Application info ->
        let (t1, t2) = info.raw in
        let t_t1 = infer_type current_env t1 in
        let t_t2 = List.map t2 ~f:(infer_type current_env) in
        info.t <- (match t_t1 with
            | Unit -> Unit
            | TYPE -> Unit
            | Type _ -> Unit
            | Imply lst -> 
                let (lst1, lst2) = list_split lst (List.length t_t2) in
                if lst1 = t_t2 then
                    Imply lst2
                else
                    Unit);
        info.t

let decorate_type (v : string) (t : t) =
  let rec print_t t =   
      match t with
        | Unit -> "Unit"
        | TYPE -> "TYPE"
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
