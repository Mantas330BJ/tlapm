  ---- MODULE Simplified ----
EXTENDS Naturals
\* cx 12
VARIABLE x

\* cx 13
Init == x = 0

\* cx 14
Spec == Init

\* cx 15
TypeOK == x \in Nat

\* cx 16
Unused == x = 3

\* Sequent active = Spec (17 - 3 = 14), TypeOK (17 - 2 = 15)
THEOREM TypeInvariant == Spec => TypeOK
    \* theorem.orig_prf

    \* steps -> step list
    \* Assert sequent (Init => TypeOk) (opaques)
    \* Justification Proof usable defs "BY DEF Init, TypeOK"
    \* Structure BY [facts] DEF [definitions]

    <1>a. Init => TypeOK BY 0 \in Nat DEF Init, TypeOK
    <1> QED BY <1>a DEF Spec

THEOREM Easy1 == ASSUME NEW P PROVE P => P /\ P
    OBVIOUS
THEOREM Easy2 == ASSUME NEW P, NEW Q PROVE P \/ Q \/ ~P
    OBVIOUS

====
