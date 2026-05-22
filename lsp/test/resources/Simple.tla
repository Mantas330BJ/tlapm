------------------------------- MODULE Simple -------------------------------
EXTENDS Integers

X == 5
                       
THEOREM \A n \in 1..3 : n + X > 3
<1> SUFFICES ASSUME NEW n \in 1..3
             PROVE  n + X > 3
  OBVIOUS
<1>1. QED BY DEF X
=============================================================================
