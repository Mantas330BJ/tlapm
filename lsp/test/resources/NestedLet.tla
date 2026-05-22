---- MODULE NestedLet ----
X == 5
THEOREM (LET X == TRUE IN (LET X == TRUE IN X)) BY DEF X
====