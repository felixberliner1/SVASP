open SVASP
(*
In order to use this program:
Add two files into the folder that contains this project. Name them "input.txt" and "statements.lp".
Write your code into input.txt, then run main.ml. The result of your code should be printed to the command shell.

Code Architecture:
- main.ml 
  calls Run_input.ml file.
- run_input.ml:
  Interprets input.txt file and turns it into data, then converts that data into the proper formats, and sends it to query.ml to alter it. 
  After query.ml alters the input, sends the data to output.ml.
- query.ml
  Interprets the data from run_input and alters it according to the query it is given, adding new statements and converting statements from the base input.
- output.ml
  Calls statements.ml to turn given input into a Clingo file. Then calls Clingo on that file and outputs data to user via command shell.
- statements.ml
  Given a list of statements, turns those into a written Clingo file (statements.lp)
*)

let () = RunInput.read_input ()