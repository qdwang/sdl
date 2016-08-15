open Core.Std
open Lexer
open Lexing

let sample = "\\x.\\i.g (\\p.\\j.t (f g))"

let test () =
  let lexbuf = Lexing.from_string sample in
  let result = try Parser.prog Lexer.read lexbuf with
    | SyntaxError msg -> printf "%s" msg; None
    | Parser.Error -> printf "%s" "Parser Error:"; None
  in
  match result with
    | Some v -> printf "%s\n" (Sdl.print v 0 false)
    | None -> exit 0

(* let () =
  let result = Lexer.read (Lexing.from_string sample)
  in
  (match result with
  | Parser.VAR x -> printf "%s" x
  | Parser.LAMBDA -> printf "lambda"
  | Parser.DOT -> printf "dot"
  | Parser.EOF -> printf "eof");
  printf "%s" "\n" *)
