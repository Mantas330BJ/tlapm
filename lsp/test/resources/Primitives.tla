---- MODULE Primitives ----
EXTENDS Naturals

X == "str"
Y == 5
THEOREM "str" = X /\ Y = 5 BY DEF X, Y
====
