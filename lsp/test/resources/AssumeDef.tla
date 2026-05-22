---- MODULE AssumeDef ----
EXTENDS Naturals
Obvious == "Obvious"
X == TRUE
Y == TRUE
THEOREM ASSUME X PROVE X /\ Y BY DEF X, Y, Obvious
====