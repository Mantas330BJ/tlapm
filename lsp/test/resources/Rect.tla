---- MODULE Rect ----
EXTENDS Naturals

X == 5
THEOREM [name |-> "x", value |-> X] \in [name : STRING, value : Nat] BY DEF X
====
