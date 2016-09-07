
type term_list = Libparser.Sdl.term list
[@@deriving yojson]

let test sample =
  let succeed lines_of_colnum result =
    match result with
    | Some v ->
      let result = List.map (fun x -> 
          let _ = Pass.Type.type_check Pass.Type.global_env x lines_of_colnum in
          x
      ) v in
      print_endline (Yojson.Safe.to_string (term_list_to_yojson result))
    | None -> ()
  in
  Pass.Parse.parse sample succeed
  
