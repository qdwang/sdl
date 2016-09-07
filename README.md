# sdl
simple dependent-type language

### Requirement
- OCaml 4.02+
- menhir
- ppx_deriving_yojson

### How to build

- Build the parser
```
./build.sh --parser
```

- Build to bytecode
```
./build.sh
```

- Build to native code
```
./build.sh --native
```

### How to run

```
./main.byte <.sdl filepath>
```

### How to test

```
./main.byte --test <test_suit_case>
```

*test_suit_case* list
- sample 