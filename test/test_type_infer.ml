open Core.Std
open Libparser.Lexer
open Lexing
open Pass

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
    List.iter v ~f:(fun x -> 
        let _ = Pass.Type.infer_type x in
        printf "%s\n" (Pass.Type.printType x 0))
  | None -> ()
