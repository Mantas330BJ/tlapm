---- MODULE UsedFromTheorem ----
X == 5
Y == 4
THEOREM X = 5
    <1>1. Y = 4
        <2>1. USE DEF X, Y
        <2>2. QED OBVIOUS
    <1>2. QED
        <2>1. USE DEF X
        <2>2. QED OBVIOUS
====
