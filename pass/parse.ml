open Libparser.Lexer
open Lexing
open Libparser.Parser.MenhirInterpreter

let prepare content =
  (String.trim content) ^ "\n"
  

(* for incremental parsing *)
let stack checkpoint =
  match checkpoint with
  | HandlingError env ->
      stack env
  | _ ->
      assert false 

let state checkpoint : int =
  let result = Lazy.force (stack checkpoint) in 
  match result with
  | MenhirLib.General.Nil ->
      0
  | MenhirLib.General.Cons (Element (s, _, _, _), _) ->
      number s
(* for incremental parsing *)

let calc_pos lines cnum = 
  let rec find lst cnum lnum =
    match lst with
      | hd :: tl -> 
        let diff = cnum - hd in
        if diff <= 0 then
          (lnum, cnum)
        else
          find tl diff (lnum + 1)
      | _ -> (lnum, cnum)
  in
  find lines cnum 1


let parse content succeed =
  let prepared_content = prepare content in
  let lexbuf = Lexing.from_string prepared_content in
  let checkpoint = Libparser.Parser.Incremental.prog lexbuf.lex_curr_p  
  and supplier = lexer_lexbuf_to_supplier Libparser.Lexer.read lexbuf
  and fail checkpoint =
    let lines_of_colnum = List.map (fun x -> 1 + String.length x) (Str.split (Str.regexp "[\n\r]") prepared_content) in
    let (lnum, cnum) = calc_pos lines_of_colnum lexbuf.lex_curr_p.pos_cnum in
    print_endline ("Parsing Error @ line:" ^ string_of_int lnum ^ " column:" ^ string_of_int cnum);
    print_endline (Libparser.Sdl.message (state checkpoint))
  in
  loop_handle succeed fail supplier checkpoint
