  ---- MODULE Nested ----
  EXTENDS Naturals

  VARIABLE x
  Init == x = 0
  Spec == Init
  True == TRUE
  TypeOK == x \in Nat /\ True
  Unused == x = 3
  THEOREM TypeInvariant == Spec => TypeOK
    <1>a. Init => TypeOK BY DEF Init, TypeOK, True
    <1> QED BY <1>a DEF Spec
  ====