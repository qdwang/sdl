let test sample =
  let succeed result =
    match result with
      | Some v ->
        List.iter (fun x -> print_endline (Libparser.Sdl.show_term x)) v
      | None -> ()
  in
  Pass.Parse.parse sample succeed
