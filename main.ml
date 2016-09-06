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

type arg = 
  | Test of string
  | Run of string
  | DoNothing

let get_cmd_arg () : arg =
  match Sys.argv with
  | [|_; "--test"; x|] -> Test x
  | [|_; path|] -> Run path
  | _ -> DoNothing

let run_parsing_test file =
  let sample = read_file file in
  Test_parser.test sample

let run_type_infer file =
  let sample = read_file file in
  Test_type_infer.test sample

let () =
  match get_cmd_arg () with
    | Test arg -> 
        run_type_infer ("test/" ^ arg ^ ".sdl")
    | Run path ->
        run_type_infer path
    | DoNothing -> ()
