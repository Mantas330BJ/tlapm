---- MODULE SimpleUnused ----
Obvious == 1 = 1
Unused == 2 = 2
THEOREM Obvious
    <1>1. USE DEF Obvious, Unused
    <1>2. QED OBVIOUS
====