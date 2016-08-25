#!/bin/sh

ocamlbuild \
    -use-ocamlfind \
    -use-menhir \
    -pkg core \
    -pkg ppx_deriving.std \
    -tag thread \
    -tag debug \
    -tag bin_annot \
    -tag short_paths \
    -cflags "-w A-4-33-40-41-42-43-34-44" \
    -cflags -strict-sequence \
    $@
