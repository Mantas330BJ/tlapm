---- MODULE DifferentDefinitionFact ----
Y == 4
X == 5
THEOREM X = 5
    <1>1. Y = 4 BY DEF Y
    <1>2. QED BY <1>1 DEF X
====