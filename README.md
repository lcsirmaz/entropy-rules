Entropy inequalities
=============

#### Non-Shannon entropy inequalities on four variables

The four random variables (with joint distribution) are a, b, c, and d. The
15 entropies **H**(a), **H**(b), ..., **H**(ab), **H**(ac), ...,
**H**(abcd) satisfy several (linear) inequalities. The non-Shannon
inequalities ar those valid inequalities which do not follow from
the standard Shannon ones.

Entropy inequalities for four variables will be written using a
different coordinate system, called *natural coordinates*. These
coordinates are defined as the following 15 entropy expressions:

|index| coordinate  | description |
|-------:|-----------:|:-----------|
|1| [a,b,c,d]   | -**I**(a,b) + **I**(a,b \| c) + **I**(a,b \| d) + **I**(c,d) &ndash; the *Ingleton* expression |
| |            |                 |
|2| (a,b \| c)  | **I**(a,b \| c) &ndash; the conditional mutual information of a and b assuming c |
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

The basic Shannon inequalites imply that the natural coordinates
2 &ndash; 15 always have non-negative values. Moreover for every 
2 &le; i &le; 15 there is a distribution where the i-th coordinate is
one, and all other coordinates are zero. (But this is not true for the
first, the Ingleton coordinate).

**Theorem** *By renaming the random variables if necessary, every valid 
linear non-Shannon entropy inequality can be written as*

<table><tr><td> a<sub>1</sub> [a,b,c,d] + a<sub>2</sub> (a,b | c) 
    + a<sub>3</sub> (a,c | b) + ... + a<sub>11</sub> (a,b | cd)
    + a<sub>12</sub> (a | bcd) + ... + a<sub>15</sub> (d | abc ) &ge; 0
</td></tr></table>

*such that all coefficients* a<sub>1</sub> ... a<sub>15</sub> *are non-negative.
Moreover, all such inequalities can be strengthened by setting the last four
coefficients to zero:* a<sub>12</sub> = a<sub>13</sub>
= a<sub>14</sub> = a<sub>15</sub> = 0.


Thus a linear non-Shannon entropy inequality can be specified by a sequence
of the 11 non-negative coefficients as

<table><tr><td>[a,b,c,d]</td>
<td>(a,b | c)</td><td>(a,c | b)</td><td>(b,c | a)</td>
<td>(a,b | d)</td><td>(a,d | b)</td><td>(b,d | a)</td>
<td>(c,d)</td><td>(c,d | a)</td><td>(c,d | b)</td><td>(a,b | cd)</td>
<tr><td> a<sub>1</sub> </td>
<td> a<sub>2</sub> </td><td> a<sub>3</sub> </td><td> a<sub>4</sub> </td>
<td> a<sub>5</sub> </td><td> a<sub>6</sub> </td><td> a<sub>7</sub> </td>
<td> a<sub>8</sub> </td><td> a<sub>9</sub> </td><td> a<sub>10</sub> </td><td> a<sub>11</sub> </td></tr>
</table>

The c &#8660; d swap of the random variables exchanges coordinates 2-3-4 and 5-6-7. The
a &#8660; b swap exchanges the coordinate pairs 3-4, 6-7, and 9-10. Thus in any entropy
inequality we can also make these exchanges in the coefficients and got another
(equaivalent) inequality; and only the lexicographically maximal one os shown in the
listing.

All inequalities have (non-negative) integer coefficients. A floating-point version is
also presented where the Ingleton coordinate is normalized to 1.







