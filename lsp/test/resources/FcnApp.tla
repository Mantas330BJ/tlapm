---- MODULE Fcn ----
EXTENDS Naturals

X == 5
THEOREM [X \in 1..X |-> X * 2][2] = 4 BY DEF X
====
