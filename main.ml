open Core.Std
open Test

let () =
  let sample = In_channel.read_all "test/sample_parser.sdl" in
  Test_parser.test sample
