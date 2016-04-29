Entropy inequalities
=============

#### Non-Shannon entropy inequalities on four variables

The four random variables (with joint distribution) are a, b, c, and d. The
15 entropies **H**(a), **H**(b), ..., **H**(ab), **H**(ac), ...,
**H**(abcd) satisfy several (linear) inequalities. The non-Shannon
inequalities do not follow from the standard Shannon inequalities.

These inequalities can be written using a different coordinate system,
called *natural coordinates*. They are defined as the 15 values below:

| coordinate  | definition |
|:------------|:-----------|
| [a,b,c,d]   | -**I**(a,b) + **I**(a,b \| c) + **I**(a,b \| d) + **I**(c,d) <br> the *Ingleton* expression |
|             |                 |
| (a,b \| c)  | **I**(a,b \| c) <br> conditional mutual information |
| (a,c \| b)  | **I**(a,c \| b) |
| (b,c \| a)  | **I**(b,c \| a) |
|             |                 |
| (a,b \| d)  | **I**(a,b \| d) <br> conditional mutual information |
| (a,d \| b)  | **I**(a,d \| b) |
| (b,d \| a)  | **I**(b,d \| a) |
|             |                 |
| (c,d)       | **I**(c,d)  <br> mutual information of c and d |
| (c,d \| a)  | **I**(c,d \| a) |
| (c,d \| b)  | **I**(c,d \| b) |
| (a,b \| cd) | **I**(a,b \| cd) <br> mutual information of a and b  assuming cd |
|             |                 |
| (a \| bcd)  | **H**(a \| bcd) <br> conditional entropy |
| (b \| acd)  | **H**(b \| acd) |
| (c \| abd)  | **H**(c \| abd) |
| (d \| abc)  | **H**(d \| abc) |

Permutations of the random variables a, b, c, d which swap 
a and b, and / or swap c and d only permute these natural coordinates. Other
permutations give six other essentially different natural coordinate
systems. A (linear) entropy inequality can be written in any of these 
coordinate systems. The different forms correspond to renaming the
variables.

The basic Shannon inequalites ensure that the last 14 out of the 15 natural
coordinates always have non-negative values.

**Theorem** *By renaming the random variables if necessary, every valid 
non-Shannon inequality can be written as*

<table><tr><td> a<sub>1</sub> [a,b,c,d] + a<sub>2</sub> (a,b \| c) 
    + a<sub>3</sub> (a,c \| b) + ... 
    + a<sub>12</sub> (a \| bcd) + ... + a<sub>15</sub> (d \| abc )
</td></tr></table>

*where all coefficients* a<sub>1</sub> ... a<sub>15</sub> *are non-negative.
Moreover all such inequalities can be strengthened to* a<sub>12</sub> = a<sub>13</sub>
= a<sub>14</sub> = a<sub>15</sub> = 0.








