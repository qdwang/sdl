open Core.Std
open Test

let run_parsing_test () =
  let sample = In_channel.read_all "test/sample_parser.sdl" in
  Test_parser.test sample

let run_type_infer () =
  let sample = In_channel.read_all "test/sample_parser.sdl" in
  Test_type_infer.test sample
  
let () =
  run_type_infer ()
