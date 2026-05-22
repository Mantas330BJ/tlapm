---- MODULE Inductive ----
EXTENDS Naturals, TLAPS
CONSTANT Start
VARIABLE x, y

Init == x = Start /\ y = Start
Next == x' = x + 1 /\ y' = y + 1
Spec == Init /\ [][Next]_<<x, y>>
Inv == x = y

THEOREM Spec => []Inv
    <1>1. Init => Inv BY DEF Init, Inv, Spec
    <1>2. Inv /\ [Next]_<<x, y>> => Inv' BY DEF Inv, Next
    <1>3. QED BY <1>1, <1>2, PTL DEF Spec
====