type t = 
| Use of (string * int list)
| Stmt of Statements.statement 
| RangeDec of (string * int * int)
| PuzDec of (string * int list list)
| SolDec of string
| SolConnectedDec of (string * string)
| VQRY | UQRY | FQRY of int | GQRY of ((int * string) list)
| RelRange of (string * string list)
