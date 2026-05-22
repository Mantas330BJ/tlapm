---- MODULE UsedFromTheorem ----
X == 5
Y == 4
THEOREM X = 5 \* Require X (hidden)
    <1>1. Y = 4 \* Require Y (hidden)
        <2>1. USE DEF X, Y \* Use X, Y
        <2>2. QED OBVIOUS \* Require Y (show)
    <1>2. QED \* Require X (show)
        <2>1. USE DEF X
        <2>2. QED OBVIOUS
====
