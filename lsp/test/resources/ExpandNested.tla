---- MODULE ExpandNested ----
A == 1
Z == 5
Y == Z
X == IF (Y = 5) /\ (Z = 3) THEN 5 ELSE 4 
THEOREM X = 4 BY DEF X, Y, Z, A
====