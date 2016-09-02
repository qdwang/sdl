open Core.Std
open Libparser.Lexer
open Lexing
open Pass
open Libparser.Parser.MenhirInterpreter
module S = MenhirLib.General

let prepare content =
  (String.strip content) ^ "\n"
  

(* Preparing for incremental parsing *)
let stack checkpoint =
  match checkpoint with
  | HandlingError env ->
      stack env
  | _ ->
      assert false 

let state checkpoint : int =
  let result = Lazy.force (stack checkpoint) in 
  match result with
  | S.Nil ->
      0
  | S.Cons (Element (s, _, _, _), _) ->
      number s
(* Preparing for incremental parsing *)


let test sample =
  let lexbuf = Lexing.from_string (prepare sample) in
  (*let checkpoint = Libparser.Parser.Incremental.prog lexbuf.lex_curr_p in*)
  let result = try Libparser.Parser.prog Libparser.Lexer.read lexbuf with
    | SyntaxError msg -> print_endline msg; None
    | Libparser.Parser.Error -> print_endline "Parser Error:"; None
  in
  let fmt = Format.std_formatter in
  Format.pp_set_margin fmt 150;
  match result with
  | Some v ->
    List.iter v ~f:(fun x -> 
        let _ = Pass.Type.infer_type Pass.Type.global_env x in
        Format.pp_print_newline fmt ();
        Format.pp_print_newline fmt ();
        Libparser.Sdl.pp_term fmt x)
  | None -> ()
