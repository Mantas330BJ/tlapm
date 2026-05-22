---- MODULE Fair ----
EXTENDS TLAPS, Integers
VARIABLE x

Next == x' = x + 1

THEOREM WF_x(Next) <=> WF_x(x' = x + 1) BY PTL DEF Next
====
