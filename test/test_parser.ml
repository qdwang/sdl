let test sample =
  let succeed lines_of_colnum result =
    match result with
      | Some v ->
        List.iter (fun x -> print_endline (Yojson.Safe.to_string (Libparser.Sdl.term_to_yojson x))) v
      | None -> ()
  in
  Pass.Parse.parse sample succeed
