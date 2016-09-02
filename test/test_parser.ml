open Core.Std

let prepare content =
  (String.strip content) ^ "\n"

let test sample =
  let succeed result =
    match result with
      | Some v ->
        List.iter v ~f:(fun x -> print_endline (Libparser.Sdl.show_term x))
      | None -> ()
  in
  Pass.Parse.parse sample succeed
