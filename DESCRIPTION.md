Entropy inequalities
=============

#### Variables, entropy, mutual information

Lower case letters a, b, c, d, etc. denote random variables
with some joint distribution.  The *entropy* of a, bc, abd, etc is denoted
by **H**(a), **H**(bc), **H**(abd), respectively. The three basic entropy
measures introduced by Claude Shannon are the *conditional entropy*, *joint information*,
and *conditional joint information*. They are always non-negative,
and can be defined in terms of the entropy as follows.

|  | definition | name |
|---:|:------|:------|
|**H**(a\|b) | **H**(a,b) - **H**(b) | conditional entropy |
|**I**(a;b) | **H**(a)+**H**(b) - **H**(a,b) | joint (mutual) information |
|**I**(a;b\|c) | **H**(a,b)+**H**(a,b) - **H**(a,b,c) - **H**(c) | conditional joint information |

Entropy inequalities which do not follow from the non-negativity of basic 
entropy measures are called *non-Shannon inequalities*.

#### Natural coordinates

Entropy inequalities for four random variables a, b, c, and d are written
using *natural coordinates*. The coordinates are defined by the following
15 entropy expressions:

|index| coordinate  | description |
|-------:|-----------:|:-----------|
|1| [a,b,c,d]   | the *Ingleton* expression -**I**(a;b) + **I**(a;b \| c) + **I**(a;b \| d) + **I**(c;d) |
| |            |                 |
|2| (a,b \| c)  | **I**(a;b \| c) &ndash; conditional joint information of a and b assuming c |
|3| (a,c \| b)  | **I**(a;c \| b) |
|4| (b,c \| a)  | **I**(b;c \| a) |
|5| (a,b \| d)  | **I**(a;b \| d) |
|6| (a,d \| b)  | **I**(a;d \| b) |
|7| (b,d \| a)  | **I**(b;d \| a) |
| |            |                 |
|8| (c,d \| a)  | **I**(c;d \| a) |
|9| (c,d \| b)  | **I**(c;d \| b) |
|10| (c,d)       | **I**(c;d)  &ndash; joint information of c and d |
|11| (a,b \| cd) | **I**(a;b \| c,d) &ndash; conditional joint information of a and b  assuming cd |
|  |           |                 |
|12| (a \| bcd)  | **H**(a \| b,c,d) &ndash; conditional entropy of a assuming bcd |
|13| (b \| acd)  | **H**(b \| a,c,d) |
|14| (c \| abd)  | **H**(c \| a,b,d) |
|15| (d \| abc)  | **H**(d \| a,b,c) |

Permutations of a, b, c, d define six essentially different natural
coordinate systems. Permutations which swap 
a and b, and / or swap c and d only permute the order of some coordinates,
but not the whole coordinate system.
Any (linear) entropy inequality can be written in any of these six
coordinate systems. The six different forms correspond to renaming
(permuting) the variables.

Basic Shannon inequalities imply that the natural coordinates
2 &ndash; 15 always have non-negative values. Moreover for every 
2 &le; i &le; 15 there is a distribution where the i-th coordinate is
positive, and all other coordinates are zero. (But this is not true for the
the Ingleton coordinate which can take negative values).

[**Theorem**](http://arxiv.org/abs/1310.5957) *By renaming the random variables if necessary, every valid
linear non-Shannon entropy inequality can be written as*

> a<sub>1</sub> [a,b,c,d] + a<sub>2</sub> (a,b | c) + a<sub>3</sub> (a,c | b) + ... + a<sub>11</sub> (a,b | cd) + a<sub>12</sub> (a | bcd) + ... + a<sub>15</sub> (d | abc ) &ge; 0

<p><em>such that coefficients</em> a<sub>1</sub> ... a<sub>15</sub> <em>are non-negative.
Moreover, all such inequalities can be strengthened by setting the
coefficients</em>  a<sub>12</sub> = a<sub>13</sub>
= a<sub>14</sub> = a<sub>15</sub> = 0 <em>to zero</em>. &nbsp; &#x25a1; </p>

<p>Thus any linear non-Shannon entropy inequality can be specified by a sequence
of 11 non-negative numbers as</p>

<table><tr><td><sub>[a,b,c,d]</sub></td>
<td><sub>(a,b | c)</sub></td><td><sub>(a,c | b)</sub></td><td><sub>(b,c | a)</sub></td>
<td><sub>(a,b | d)</sub></td><td><sub>(a,d | b)</sub></td><td><sub>(b,d | a)</sub></td>
<td><sub>(c,d | a)</sub></td><td><sub>(c,d | b)</sub></td><td><sub>(c,d)</sub></td><td><sub>(a,b | cd)</sub></td>
<tr><td align="center"> a<sub>1</sub> </td>
<td align="center"> a<sub>2</sub> </td><td align="center"> a<sub>3</sub> </td><td align="center"> a<sub>4</sub> </td>
<td align="center"> a<sub>5</sub> </td><td align="center"> a<sub>6</sub> </td><td align="center"> a<sub>7</sub> </td>
<td align="center"> a<sub>8</sub> </td><td align="center"> a<sub>9</sub> </td><td align="center"> a<sub>10</sub> </td><td align="center"> a<sub>11</sub> </td></tr>
</table>

<p>The c &#8660; d swap of the random variables exchanges coordinates 2-3-4
and 5-6-7.  The a &#8660; b swap exchanges the coordinate pairs 3-4, 6-7,
and 8-9.  Thus in any entropy inequality we can also make these exchanges
in the coefficients and got another (equivalent and valid) inequality.</p>

#### The Zhang &ndash; Yeung inequality

The very first non-Shannon entropy inequality was discovered by
[Z. Zhang and R. W. Yeung](http://www.cs.cornell.edu/courses/cs783/2007fa/papers/ZYnonShannon.pdf)
in 1997. Using natural coordinates it can be written as

> [a,b,c,d] + (a,b | c) + (a,c | b) + (b,c | a) &ge; 0,

or, showing the a<sub>1</sub> ... a<sub>11</sub> coefficients only,

|  1|  2|  3|  4|  5|  6|  7|  8|  9| 10| 11| Name |
|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|:-----|
|  1|  1|  1|  1|  0|  0|  0|  0|  0|  0|  0|Zhang-Yeung inequality |
|  1|  0|  0|  0|  1|  1|  1|  0|  0|  0|  0|Zhang-Yeung swapping c &#8660; d |

The Zhang &ndash; Yeung inequality is symmetrical for the a &#8660; b
swap, thus it has only two forms shown above. Other inequalities might have
up to four different forms.

#### Minimal entropy inequalities

Any non-negative linear combination of entropy inequalities is also an
entropy inequality. When an entropy inequality is such a
linear combination of other known entropy inequalities, then we say that it
is *superseded*. 
We remark that this &quot;linear combination&quot; includes decreasing
coefficient a<sub>1</sub> of the Ingleton coordinate (but it must remain
non-negative), and increasing other coefficients a<sub>2</sub> ... 
a<sub>11</sub>.

An entropy inequality is *minimal* if it is not known to be superseded.
This status might change over time; listed inequalities known to be
superseded are marked as such.

Listed entropy inequalities are scaled to have integer coefficients. In some
cases the coefficients are adjusted (rounded up) and are not exact; those
cases are marked by an asterisk in their labels.
In the main lists coordinates are integers; in the
normalized lists coefficients are scaled so that the Ingleton coordinate
is 1, and other coordinates are printed as floating point numbers.

