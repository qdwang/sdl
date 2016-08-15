{
  open Lexing
  open Parser

  exception SyntaxError of string
}

let id = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*
let white = [' ' '\t' '\n']+

rule read =
  parse
  | white  { WHITE }
  | id     { VAR (Lexing.lexeme lexbuf) }
  | '\\'   { LAMBDA }
  | '.'    { DOT }
  | '('    { PL }
  | ')'    { PR }
  | eof    { EOF }
