#!/bin/sh

dist=""

if [ $# -eq 0 ]
then
    dist="main.byte"
else
    if [ $1 = "--parser" ]
    then
        menhir --table ./libparser/parser_gen.mly --base ./libparser/parser
    else
        if [ $1 = "--native" ]
        then
            dist="main.native"
        elif [ $1 = "--byte" ]
        then
            dist="main.byte"
        fi
    fi
fi

if [ "$dist" != "" ]
then
    ocamlbuild \
        -use-ocamlfind \
        -pkg str \
        -pkg ppx_deriving_yojson \
        -pkg menhirLib \
        -tag thread \
        -tag debug \
        -tag bin_annot \
        -tag short_paths \
        -cflags "-w A-4-33-40-41-42-43-34-44" \
        -cflags -strict-sequence \
        $dist
fi
