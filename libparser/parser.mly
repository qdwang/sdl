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
  | v = VAR; EQUAL; t = elem_term    { `VarAssign (v, t) }

type_define:
  | v = VAR; COLON; t = type_term    { `TypeDefine (v, t) }

type_term:
  | t = atomic_type_term { t }
  | t1 = atomic_type_term; t2 = imply_term+   { `TypeImply (t1, t2) }

atomic_type_term:
  | t = VAR  { `Type t }
  | PL; v = VAR; COLON; t = VAR; PR    { `TypeWithVar (v, t) }
  | PL; t1 = atomic_type_term; t2 = imply_term+; PR   { `TypeImply (t1, t2) }

imply_term:
  | ARROW; t = atomic_type_term  { t }
  | ARROW; t = application  { t }

application:
  | t1 = atomic_elem_term; t2 = atomic_elem_term+ { `Application (t1, t2) }

elem_term:
  | t = atomic_elem_term { t }
  | LAMBDA; s = VAR; DOT; t = lambda_term  { `Lambda (s, t) }
  | t = application { t }

lambda_term:
  | t = elem_term { t }
  /* rules below is for type term */
  | PL; v = VAR; COLON; t = VAR; PR    { `TypeWithVar (v, t) }
  | t1 = atomic_type_term; t2 = imply_term+   { `TypeImply (t1, t2) }

atomic_elem_term:
  | s = VAR { `Var s }
  | PL;  t = elem_term;  PR { t }
