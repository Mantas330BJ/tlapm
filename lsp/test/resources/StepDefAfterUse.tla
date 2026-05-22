---- MODULE StepDefAfterUse ----
X == 5

THEOREM TRUE
    <1>1. USE DEF X
    <1>2. TRUE
        <2>1. QED
            <3>1. X = 5 OBVIOUS
            <3>2. QED OBVIOUS
    <1>3. QED OBVIOUS
====