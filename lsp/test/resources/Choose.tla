---- MODULE Choose ----
EXTENDS Naturals
X == 5
THEOREM (CHOOSE X \in {1} : X = 1) = 1 /\ X - X = 0 BY DEF X 
====
