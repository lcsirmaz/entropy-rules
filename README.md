Entropy inequalities
=============

#### Non-Shannon entropy inequalities on four variables

The four random variables (with joint distribution) are a, b, c, and d. The
15 entropies **H**(a), **H**(b), ..., **H**(ab), **H**(ac), ...,
**H**(abcd) satisfy several (linear) inequalities. The non-Shannon
inequalities do not follow from the standard Shannon inequalities.

These inequalities can be written using a different coordinate system,
called *natural coordinates*. They are defined as the 15 values below:

| number | coordinate  | definition |
|-------:|:------------|:-----------|
|1| [a,b,c,d]   | -**I**(a,b) + **I**(a,b \| c) + **I**(a,b \| d) + **I**(c,d) &ndash; the *Ingleton* expression |
| |            |                 |
|2| (a,b \| c)  | **I**(a,b \| c) &ndash; this is the conditional mutual information of a and b assuming c |
|3| (a,c \| b)  | **I**(a,c \| b) |
|4| (b,c \| a)  | **I**(b,c \| a) |
| |            |                 |
|5| (a,b \| d)  | **I**(a,b \| d) |
|6| (a,d \| b)  | **I**(a,d \| b) |
|7| (b,d \| a)  | **I**(b,d \| a) |
| |            |                 |
|8| (c,d)       | **I**(c,d)  &ndash; the mutual information of c and d |
|9| (c,d \| a)  | **I**(c,d \| a) |
|10| (c,d \| b)  | **I**(c,d \| b) |
|11| (a,b \| cd) | **I**(a,b \| cd) &ndash; the conditional mutual information of a and b  assuming cd |
|  |           |                 |
|12| (a \| bcd)  | **H**(a \| bcd) &ndahs; the conditional entropy of a assuming bcd |
|13| (b \| acd)  | **H**(b \| acd) |
|14| (c \| abd)  | **H**(c \| abd) |
|15| (d \| abc)  | **H**(d \| abc) |

Permutations of the random variables a, b, c, d which swap 
a and b, and / or swap c and d only permute these natural coordinates. Other
permutations give six other essentially different natural coordinate
systems. A (linear) entropy inequality can be written in any of these 
coordinate systems. The different forms correspond to renaming the
variables.

The basic Shannon inequalites ensure that the natural coordinates
2 &ndash 15 always have non-negative values. Moreover for every 
2 &le; i &le; 15 there is a distribution where the i-th coordinate is
one, and all other coordinates are zero. (But this is not true for the
Ingleton coordinate).

**Theorem** *By renaming the random variables if necessary, every valid 
non-Shannon inequality can be written as*

<table><tr><td> a<sub>1</sub> [a,b,c,d] + a<sub>2</sub> (a,b | c) 
    + a<sub>3</sub> (a,c | b) + ... 
    + a<sub>12</sub> (a | bcd) + ... + a<sub>15</sub> (d | abc ) &ge; 0
</td></tr></table>

*where all coefficients* a<sub>1</sub> ... a<sub>15</sub> *are non-negative.
Moreover all such inequalities can be strengthened by setting the last four
coefficients to zero:* a<sub>12</sub> = a<sub>13</sub>
= a<sub>14</sub> = a<sub>15</sub> = 0.








