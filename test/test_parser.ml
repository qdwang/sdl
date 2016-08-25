open Core.Std
open Libparser.Lexer
open Lexing

let prepare content =
  (String.strip content) ^ "\n"

let test sample =
  let lexbuf = Lexing.from_string (prepare sample) in
  let result = try Libparser.Parser.prog Libparser.Lexer.read lexbuf with
    | SyntaxError msg -> print_endline msg; None
    | Libparser.Parser.Error -> print_endline "Parser Error:"; None
  in
  match result with
  | Some v ->
    List.iter v ~f:(fun x -> print_endline (Libparser.Sdl.show_term x))
  | None -> ()
