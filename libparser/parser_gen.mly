%token <string> VAR
%token LAMBDA
%token DOT
%token EOF
%token ARROW
%token EQUAL
%token COLON
%token PL
%token PR
%token NEWLINE

%start <Sdl.term list option> prog

%%
prog:
  | v = sent+; EOF    { Some v }
  | NEWLINE*; EOF     { None }

sent:
  | t = type_define; NEWLINE+  { t }
  | t = var_assign; NEWLINE+   { t }
  | t = elem_term; NEWLINE+    { t }

var_assign:
  | v = VAR; EQUAL; t = elem_term    { `VarAssign (Sdl.gen_info (v, t)) }

type_define:
  | v = VAR; COLON; t = type_term    { `TypeDefine (Sdl.gen_info (v, t)) }

type_term:
  | t = atomic_type_term { t }
  | t1 = atomic_type_term; t2 = imply_term+   { `TypeImply (Sdl.gen_info (t1, t2)) }

atomic_type_term:
  | t = VAR  { `Type (Sdl.gen_info t) }
  | t = atomic_complex_type_term { t }

atomic_complex_type_term:
  | PL; v = VAR; COLON; t = VAR; PR    { `TypeWithVar (Sdl.gen_info (v, t)) }
  | PL; t1 = atomic_type_term; t2 = imply_term+; PR   { `TypeImply (Sdl.gen_info (t1, t2)) }

imply_term:
  | ARROW; t = atomic_type_term  { t }
  | ARROW; t = application  { t }

application:
  | t1 = atomic_elem_term; t2 = atomic_term+ { `Application (Sdl.gen_info (t1, t2)) }

elem_term:
  | t = atomic_elem_term { t }
  | LAMBDA; s = VAR; DOT; t = lambda_term  { `Lambda (Sdl.gen_info (s, t)) }
  | t = application { t }

lambda_term:
  | t = elem_term { t }
  /* rules below is for type term */
  | PL; v = VAR; COLON; t = VAR; PR    { `TypeWithVar (Sdl.gen_info (v, t)) }
  | t1 = atomic_type_term; t2 = imply_term+   { `TypeImply (Sdl.gen_info (t1, t2)) }

atomic_elem_term:
  | s = VAR { `Var (Sdl.gen_info s) }
  | PL;  t = elem_term;  PR { t }

atomic_term:
  | t = atomic_elem_term { t }
  | t = atomic_complex_type_term { t }