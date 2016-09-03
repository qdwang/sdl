# sdl
simple dependent-type language

### Requirement
- OCaml 4.02+
- Menhir
- Ppx_deriving

### How to build
`./build.sh [--parser] main.byte`

The `--parser` argument is optional.
With it, the current version of MenhirLib requirement will be embeded in the generated parser file.
