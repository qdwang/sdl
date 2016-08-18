open Core.Std
open Libparser.Lexer
open Lexing

let prepare content =
  (String.strip content) ^ "\n"

let test sample =
  let lexbuf = Lexing.from_string (prepare sample) in
  let result = try Libparser.Parser.prog Libparser.Lexer.read lexbuf with
    | SyntaxError msg -> printf "%s" msg; None
    | Libparser.Parser.Error -> printf "%s" "Parser Error:"; None
  in
  match result with
  | Some v ->
    List.iter v ~f:(fun x -> printf "%s\n" (Libparser.Sdl.printAST x 0))
  | None -> ()
