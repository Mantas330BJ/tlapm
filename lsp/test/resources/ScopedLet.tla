---- MODULE ScopedLet ----
EXTENDS Naturals

X == 5
THEOREM (LET X == TRUE IN X)
    <1>1. X > 4 BY DEF X
    <1>2. QED OBVIOUS
====