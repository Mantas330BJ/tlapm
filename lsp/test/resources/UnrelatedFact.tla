---- MODULE UnrelatedFact ----
EXTENDS Naturals

Y == 5
X == Y

THEOREM X = 5
    <1>1. Y = 5 BY DEF Y
    <1>2. X > 3 BY DEF X, Y
    <1>3. QED BY <1>1, <1>2 DEF X
====