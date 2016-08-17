{
  open Lexing
  open Parser

  exception SyntaxError of string
}

let id = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*
let white = [' ' '\t']+
let eol = ['\n' '\r']+

rule read =
  parse
  | "->"   { ARROW }
  | ':'   { COLON }
  | '='   { EQUAL }
  | '\\'   { LAMBDA }
  | '.'    { DOT }
  | '('    { PL }
  | ')'    { PR }
  | eol  { NEWLINE }
  | white  { read lexbuf }
  | id     { VAR (Lexing.lexeme lexbuf) }
  | eof    { EOF }
