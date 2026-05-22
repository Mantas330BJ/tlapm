---- MODULE Sub ----
EXTENDS Naturals
X == 5
VARIABLE a
THEOREM ASSUME a \in Nat PROVE ([a' = a + X]_a) => (a' = X + a \/ a' = a) BY DEF X 
====
