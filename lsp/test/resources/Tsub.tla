---- MODULE Tsub ----
EXTENDS TLAPS, Integers
VARIABLE x

Init == x = 0
Next == x' = x + 1

THEOREM (Init /\ [][Next]_x) => ([][Next]_x /\ x = 0) BY DEF Init
====
