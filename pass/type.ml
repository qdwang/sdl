open Libparser.Sdl

let debug_print lst =
  print_endline ("\n" ^ (List.fold_left (fun a b -> a ^ "::" ^ b) "" lst))

type env = {
  root: (env * int) option;
  mutable stack: (string * t) list;
}
[@@deriving show]

let list_split (lst : 'a list) (pos_to_top : int) =
  let rec split lst1 lst2 p =
    if p <= 0 then 
      (List.rev lst1, lst2)
    else
      match lst2 with
      | [] -> (lst1, lst2)
      | hd :: tl -> split (hd :: lst1) tl (p - 1) in
  split [] lst pos_to_top  

let rec find_in_env (var : string) (env : env) (pos_to_bottom : int option) = 
  let result = try Some (List.find (fun (s, _) -> s = var) (match pos_to_bottom with 
      | None -> env.stack  
      | Some pos -> let (_, lst2) = list_split env.stack (List.length env.stack - pos) in lst2
  )) with | Not_found -> None
  in
  match (result, env.root) with
  | None, Some (root_env, root_pos) -> find_in_env var root_env (Some root_pos) 
  | Some v, _ -> Some v
  | None, None -> None

let rec zip lst1 lst2 =
  match lst1, lst2 with
  | (hd1 :: tl1), (hd2 :: tl2) -> (hd1, hd2) :: (zip tl1 tl2)
  | _ -> []

let rec type_check (t1 : t) (t2 : t) : bool =
  match t1, t2 with
  | IsType (_, "Type"), _ -> true
  | IsType (x, ""), IsType (y, "") -> x = y
  | IsType (x, ""), IsType (_, y) -> x = y
  | IsType (_, x), IsType (y, "") -> x = y
  | IsType (_, x), IsType (_, y) -> x = y
  | Imply lst1, Imply lst2 -> 
    let (len1, len2) = List.length lst1, List.length lst2 in
    if len1 = len2 then
      not (List.exists (fun x -> not x) (List.map (fun (x, y) -> type_check x y) (zip lst1 lst2)))
    else
      false
  | _ -> false

let rec replace_type (env : env) (t : t) : t = 
  let find v = 
    match find_in_env v env None with
    | Some (_, t) -> t
    | None -> t
  in
  match t with
  | IsType (v, "") -> find v 
  | OfType x -> find x
  | Imply lst -> Imply (List.map (replace_type env) lst)
  | _ -> t

let type_apply (fn_t : t) (args_t : t list) (current_env : env) : t =
  let type_env = {root = None; stack = []} in
  let args_t_replaced = List.map (replace_type current_env) args_t in
  let rec apply (fn : t) (args : t list) : t =
    match fn, args with
    | Imply (fn_hd :: fn_tl), args_hd :: args_tl ->
      if type_check fn_hd args_hd then
        ((match fn_hd with
            | IsType (v, _) -> 
              type_env.stack <- (v, args_hd) :: type_env.stack
            | _ -> ());
         apply (Imply (List.map (replace_type type_env) fn_tl)) args_tl)
      else
        IsType (show fn_hd ^ " && " ^ show args_hd, "ERROR")
    | _ -> fn
  in
  replace_type type_env (apply fn_t args_t_replaced)

let rec flatten_t (t : t) =
  match t with
  | Imply l -> 
    let lst = List.map flatten_t l in
    Imply (match List.rev lst with
        | Imply tl :: hd ->
          List.rev hd @ tl
        | _ -> lst)
  | _ -> t

let global_env = {root = None; stack = []}

let rec infer_type ?(assign_t : t option) (current_env : env) (tree : term) : t =
  match tree with
  | `Type info -> 
    info.t <- IsType (info.raw, if info.raw = "Type" then "Type" else "");
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
        | hd :: _ -> 
          if hd = IsType ("Type", "Type") then 
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
    info.t <- IsType (var, t);
    current_env.stack <- (var, info.t) :: current_env.stack;
    info.t
  | `TypeImply info ->
    let (t1, t2) = info.raw in
    let current_env = {root = Some (current_env, List.length current_env.stack); stack = []} in 
    let t_t1 = infer_type current_env t1 in
    let t_t2 = List.map (infer_type current_env) t2 in
    info.t <- flatten_t (Imply (t_t1 :: t_t2));
    info.t
  | `Lambda info ->
    let (var, t) = info.raw in
    let current_env = {root = Some (current_env, List.length current_env.stack); stack = []} in
    let assigned_type = match assign_t with | None -> Unit | Some t -> t in 
    let (assigned_hd, assigned_tl) = match assigned_type with 
      | Imply (hd :: tl) -> ((match hd with 
          | IsType (v, t) -> if t = "Type" then IsType (var, t) else OfType v
          | x -> x), Imply tl) 
      | _ -> (Unit, Unit) in
    current_env.stack <- (var, assigned_hd) :: current_env.stack;
    let body_t = infer_type current_env t ~assign_t:assigned_tl in
    info.t <- (match body_t with 
        | Unit -> Imply [assigned_hd; Unit]
        | IsType (x, y) -> Imply [assigned_hd; IsType (x, y)]
        | OfType x -> Imply [assigned_hd; OfType x]
        | Imply lst -> Imply (assigned_hd :: lst));
    info.t
  | `Application info ->
    let (t1, t2) = info.raw in
    let assigned_type = match assign_t with | None -> Unit | Some t -> t in 
    let assigned_hd = match assigned_type with 
      | Imply (hd :: _) -> hd
      | _ -> Unit in
    let t_t1 = infer_type current_env t1 ~assign_t:assigned_hd in
    let t_t2 = match t_t1 with
      | Imply lst -> 
        let (t_t1_lst1, _) = list_split lst (List.length t2) in
        List.map (fun (t1, t2) -> infer_type current_env t2 ~assign_t:t1) (zip t_t1_lst1 t2)
      | _ -> [] 
    in
    info.t <- type_apply t_t1 t_t2 current_env;
    info.t
