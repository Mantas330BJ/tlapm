---- MODULE Except ----
EXTENDS Naturals

X == 5
THEOREM [[x \in 1..3 |-> x] EXCEPT ![2] = @ + X][2] = X + 2 BY DEF X
====
