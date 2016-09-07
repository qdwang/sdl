let test sample =
  let succeed result =
    let fmt = Format.std_formatter in
    Format.pp_set_margin fmt 150;
    match result with
    | Some v ->
      List.iter (fun x -> 
          let _ = Pass.Type.type_check Pass.Type.global_env x in
          Format.pp_print_newline fmt ();
          Format.pp_print_newline fmt ();
          Libparser.Sdl.pp_term fmt x) v
    | None -> ()
  in
  Pass.Parse.parse sample succeed
  
