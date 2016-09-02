#!/bin/sh

for last; do true; done

if [ $1 = "--parser" ] 
then
    menhir --table ./libparser/parser_gen.mly --base ./libparser/parser
fi

ocamlbuild \
    -use-ocamlfind \
    -pkg str \
    -pkg core \
    -pkg ppx_deriving.std \
    -pkg menhirLib \
    -tag thread \
    -tag debug \
    -tag bin_annot \
    -tag short_paths \
    -cflags "-w A-4-33-40-41-42-43-34-44" \
    -cflags -strict-sequence \
    $last