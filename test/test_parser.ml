open Core.Std
open Libparser.Lexer
open Lexing

let sample = "

and : Type -> Type -> Type
and = \\p. \\q. (c: Type) -> (p -> q -> c) -> c

conj : (p:Type) -> (q:Type) -> p -> q -> and p q
conj = \\p.\\q. \\x.\\y. \\c. \\f. f x y

proj1 : (p:Type) -> (q:Type) -> and p q -> p
proj1  = \\p. \\q. \\a. a p (\\x.\\y.x)

proj2 : (p:Type) -> (q:Type) -> and p q -> q
proj2  = \\p. \\q. \\a. a q (\\x.\\y.y)

and_commutes : (p:Type) -> (q:Type) -> and p q -> and q p
and_commutes = \\p. \\q. \\a. conj q p (proj2 p q a) (proj1 p q a)

"

let prepare content =
  (String.strip content) ^ "\n"

let test () =
  let lexbuf = Lexing.from_string (prepare sample) in
  let result = try Libparser.Parser.prog Libparser.Lexer.read lexbuf with
    | SyntaxError msg -> printf "%s" msg; None
    | Libparser.Parser.Error -> printf "%s" "Parser Error:"; None
  in
  match result with
  | Some v ->
    List.iter v ~f:(fun x -> printf "%s\n" (Libparser.Sdl.print x 0))
  | None -> ()


(* let () =
   let result = Lexer.read (Lexing.from_string sample)
   in
   (match result with
   | Parser.VAR x -> printf "%s" x
   | Parser.LAMBDA -> printf "lambda"
   | Parser.DOT -> printf "dot"
   | Parser.EOF -> printf "eof");
   printf "%s" "\n" *)
