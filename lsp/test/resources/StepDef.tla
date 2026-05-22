---- MODULE StepDef ----
EXTENDS Naturals
X == 5
THEOREM X > 4
    <1>1. QED
        <2>1. USE DEF X
        <2>3. QED OBVIOUS
            
====