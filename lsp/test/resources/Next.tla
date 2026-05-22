---- MODULE Next ----
EXTENDS Naturals, Reals, TLAPS

THEOREM ASSUME NEW S, NEW T, NEW x,
               NEW P(_),
               x \in S \cup T,
               \A y \in S : P(y),
               \A y \in T : P(y)
        PROVE  P(x) OBVIOUS

====