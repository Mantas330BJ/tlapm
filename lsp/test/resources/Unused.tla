  ---- MODULE Unused ----
  EXTENDS Naturals

  VARIABLE x
  Init == x = 0
  Spec == Init
  TypeOK == x \in Nat
  Unused == x = 3
  THEOREM TypeInvariant == Spec => TypeOK
    <1>a. Init => TypeOK BY DEF Init, TypeOK, Unused
    <1> QED BY <1>a DEF Spec
  ====