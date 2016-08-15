%token <string> VAR
%token LAMBDA
%token DOT
%token EOF
%token WHITE
%token PL
%token PR

%start <Sdl.term option> prog

%%
prog:
  | v = term; EOF {Some v}
  | EOF      { None }

term:
  | s = VAR { `Var s }
  | LAMBDA; s = VAR; DOT; t = term  { `Lambda (s, t) }
  | t1 = atomic_term; WHITE; t2 = atomic_term { `Application (t1, t2) }
  | PL; t = term; PR  { t }


atomic_term:
  | s = VAR { `Var s }
  | PL; t = term; PR { t }
