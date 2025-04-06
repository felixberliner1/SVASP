#show cell_1/3.
cell_1(A_3, A_2, A_1) :- clue(A_3, A_2, A_1).
:- not_box_1(R1, C1, R2, C2), r(R1), c(C1), r(R2), c(C2), ((R1) - (1)) / (3) == ((R2) - (1)) / (3), ((C1) - (1)) / (3) == ((C2) - (1)) / (3).
:- box_1(R1, C1, R2, C2), r(R1), c(C1), r(R2), c(C2), ((R1) - (1)) / (3) != ((R2) - (1)) / (3).
:- box_1(R1, C1, R2, C2), r(R1), c(C1), r(R2), c(C2), ((C1) - (1)) / (3) != ((C2) - (1)) / (3).
:- cell_1(R1, C1, S), cell_1(R2, C2, S), box_1(R1, C1, R2, C2), R1 != R2, C1 != C2.
:- c(C), s(S), cell_1(R, C, S), cell_1(R', C, S), R < R'.
:- c(C), s(S), not_cell_1(R, C, S) : r(R).
:- r(R), s(S), cell_1(R, C, S), cell_1(R, C', S), C < C'.
:- r(R), s(S), not_cell_1(R, C, S) : c(C).
:- r(R), c(C), cell_1(R, C, S), cell_1(R, C, S'), S < S'.
:- r(R), c(C), not_cell_1(R, C, S) : s(S).
box_1(A4, A3, A2, A1) | not_box_1(A4, A3, A2, A1) :- r(A4), c(A3), r(A2), c(A1).
cell_1(A3, A2, A1) | not_cell_1(A3, A2, A1) :- r(A3), c(A2), s(A1).
r(1..9).
c(1..9).
s(1..9).
