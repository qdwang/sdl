open Test

let read_file f =
  let ic = open_in f in
  try
    let n = in_channel_length ic in
    let s = Bytes.create n in
    really_input ic s 0 n;
    close_in ic;
    (s)          
  
  with e ->                      
    close_in_noerr ic;           
    raise e     

let run_parsing_test () =
  let sample = read_file "test/sample_parser.sdl" in
  Test_parser.test sample

let run_type_infer () =
  let sample = read_file "test/sample_parser.sdl" in
  Test_type_infer.test sample

let () =
  run_type_infer ()
