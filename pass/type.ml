open Libparser.Sdl
open Core.Std

type env = {
    root: (env * int) option;
    mutable stack: (string * t) list;
}
[@@deriving show]

let list_split (lst : 'a list) (pos_to_top : int) =
    let rec split lst1 lst2 p =
        if p <= 0 then 
            (lst1, lst2)
        else
            match lst2 with
                | [] -> (lst1, lst2)
                | hd :: tl -> split (hd :: lst1) tl (p - 1) in
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

let rec infer_type ?(assign_t : t option) (current_env : env) (tree : term) : t =
    match tree with
    | `Type info -> 
        info.t <- IsType info.raw;
        info.t
    | `Var info -> 
        let result = find_in_env info.raw current_env None in
        (match result with
            | None -> info.t <- Unit
            | Some (_, t) -> info.t <- t);
        info.t
    | `VarAssign info ->
        let (var, t) = info.raw in
        let var_type = match find_in_env var current_env None with
            | None -> Unit 
            | Some (_, t) -> t 
            in
        info.t <- infer_type current_env t ~assign_t:var_type;
        (match var_type with
            | Imply lst ->
                (match List.rev lst with
                    | [] -> ()
                    | hd :: tl -> 
                        if hd = IsType "Type" then 
                            current_env.stack <- (var, info.t) :: current_env.stack
                        else
                            ())
            | _ -> ());
        info.t
    | `TypeDefine info ->
        let (var, t) = info.raw in
        info.t <- infer_type current_env t;
        current_env.stack <- (var, info.t) :: current_env.stack;
        info.t
    | `TypeWithVar info ->
        let (var, t) = info.raw in
        info.t <- IsType t;
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
        let assigned_type = match assign_t with | None -> Unit | Some t -> t in 
        let (assigned_hd, assigned_tl) = match assigned_type with | Imply (hd :: tl) -> (hd, Imply tl) | _ -> (Unit, Unit) in
        let body_t = infer_type current_env t ~assign_t:assigned_tl in
        info.t <- (match body_t with 
            | Unit -> Unit
            | IsType x -> Imply [assigned_hd; IsType x]
            | OfType x -> Imply [assigned_hd; OfType x]
            | Imply lst -> Imply (assigned_hd :: lst));
        current_env.stack <- (var, assigned_hd) :: current_env.stack;
        info.t
    | `Application info ->
        let (t1, t2) = info.raw in
        let t_t1 = infer_type current_env t1 in
        let t_t2 = List.map t2 ~f:(infer_type current_env) in
        info.t <- (match t_t1 with
            | Unit -> Unit
            | IsType _ -> Unit
            | OfType _ -> Unit
            | Imply lst -> 
                let (lst1, lst2) = list_split lst (List.length t_t2) in
                if lst1 = t_t2 then
                    Imply lst2
                else
                    IsType "error");
        info.t
