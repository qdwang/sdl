
(* The type of tokens. *)

type token = 
  | VAR of (string)
  | PR
  | PL
  | NEWLINE
  | LAMBDA
  | EQUAL
  | EOF
  | DOT
  | COLON
  | ARROW

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Sdl.term list option)

module MenhirInterpreter : sig
  
  (* The incremental API. *)
  
  include MenhirLib.IncrementalEngine.INCREMENTAL_ENGINE
    with type token = token
  
end

(* The entry point(s) to the incremental API. *)

module Incremental : sig
  
  val prog: Lexing.position -> (Sdl.term list option) MenhirInterpreter.checkpoint
  
end
