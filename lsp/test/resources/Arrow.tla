---- MODULE Arrow ----
EXTENDS Naturals

X == 5
THEOREM [x \in 1..3 |-> X] \in [1..3 -> 1..X] BY DEF X
====
