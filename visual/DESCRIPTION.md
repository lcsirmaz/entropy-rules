Visualizing the entropy region
==============================

The paper of F. Matus and L. Csirmaz: 
[Entropy region and convolution](http://arxiv.org/pdf/1310.5957v1)
identified a 3-dimensional cross-section of the four-variable entropy region
which carries over most of its complexity. Using entropy inequalities found
here an outer bound for that 3-dimensional section is computed.

#### Almost entropic points

A 15-dimensional point of the Euclidean space, indexed by the natural
coordinates is *entropic* if the values are just the natural coordinates of
some (joint) distribution on random variables *a, b, c*, and *d*. The point
is *almost entropic*, or *aent*, if it is in the closure (in the usual
Euclidean topology) of the set of entropic points.

We will use h<sub>1</sub>, ..., h<sub>15</sub> to denote the coordinates as
follows.

<table><tbody><tr><td align="right"> h<sub>1</sub>
</td><td align="left"><sub>[a,b,c,d]</sub> Ingleton expression</td></tr>
<tr><td align="right">h<sub>2</sub>, h<sub>3</sub>, h<sub>4</sub></td> <td
align="left"><sub>(a,b | c)</sub> <sub>(a,c | b)</sub> <sub>(b,c | a)</sub></td></tr>
<tr><td align="right"> h<sub>5</sub>, h<sub>6</sub>, h<sub>7</sub></td> <td
align="left"><sub>(a,b | d)</sub> <sub>(a,d | b)</sub> <sub>(b,d | a)</sub></td></tr>
<tr><td align="right"> h<sub>8</sub>, h<sub>9</sub>, h<sub>10</sub>,
h<sub>11</sub></td><td align="left"> <sub>(c,d | a)</sub> <sub>(c,d | b)</sub>
<sub>(c,d)</sub> <sub>(a,b | cd)</sub></td></tr>
<tr><td align="right"> h<sub>12</sub>, h<sub>13</sub>, h<sub>14</sub>,
h<sub>15</td> <td align="left"> <sub>(a | bcd)</sub> <sub>(b | acd)</sub>
<sub>(c | abd)</sub> <sub>(d | abc)</sub></td></tr>
</tbody></table>

**Theorem 1.** *If*, h<sub>1</sub> &le; 0*, and the 15-dimensional point* &lt; h<sub>1</sub>, ...,
h<sub>15</sub> &gt; *is almost entropic, then so is the point where the 
last four coordinates* h<sub>12</sub>, h<sub>13</sub>, h<sub>14</sub>,
h<sub>15</sub> *are replaced by zero.*

**Proof.** This is Theorem 1 in [Matus -
Csirmaz](http://arxiv.org/pdf/1310.5957v1). Essentially this theorem is equivalent to
[T. H. Chan's theorem](https://arxiv.org/pdf/1302.2994.pdf) which says that
every entropy inequality can be strengthened to a balanced one. &nbsp; &#x25a1;

&nbsp;

The converse of Theorem 1 is also true in the following sense.

**Claim** *Suppose* h<sub>1</sub> &le; 0 *and the point* &lt; h<sub>1</sub>, ...,
h<sub>11</sub>, 0, 0, 0, 0 &gt; *is almost entropic. Then for any
non-negative numbers* h<sub>12</sub>, h<sub>13</sub>, h<sub>14</sub>,
h<sub>15</sub> *the point* &lt; h<sub>1</sub>, ..., h<sub>15</sub> &gt; *is
also almost entropic.*

**Proof.**
Add &quot;private info&quot; with entropies h<sub>12</sub>, etc, to the four
random variables. &quot;Private info&quot; means that the added random variable is
independent of everything else. &nbsp; &#x25a1;

From this point on we will consider only the 11-dimensional region spanned
by the first 11 natural coordinates of the almost entropic points. The
coordinates will be denoted by h<sub>1</sub>, ..., h<sub>11</sub>, and it
will always be assumed that h<sub>1</sub> is not positive, and all other 
coordinates are non-negative.

The proof of Theorem 4 of [Matus - Csirmaz](http://arxiv.org/pdf/1310.5957v1) has
the following consequences.

**Theorem 2.**
a) *Suppose* x, y *are non-negative numbers and the point* &lt; h<sub>1</sub>, ..., 
h<sub>9</sub>, h<sub>10></sub>+x+y, h<sub>11</sub> &gt; *is almost entropic.
Then so is the point* &lt; h<sub>1</sub>, h<sub>2</sub+x, h<sub>3</sub>,
h<sub>4</sub>, h<sub>5<?sub>+y, h<sub>6</sub>, h<sub>7</sub>, h<sub>8</sub>,
h<sub>9</sub>, h<sub>10</sub>, h<sub>11</sub> &gt;.

b) *Suppose* x, y *are non-negative numbers and the point* &lt;
h<sub>1</sub>, ..., h<sub>9</sub>, h<sub>10</sub>, h<sub>11</sub>+x+y &gt;
*is almost entropic. Then so is the point* &lt; h<sub>1</sub>, ...,
h<sub>7</sub>, h<sub>8</sub>+x, h<sub>9</sub>+y, h<sub>10</sub>,
h<sub>11</sub> &gt; &nbsp; &#x25a1;

For 4-variable entropy inequalities we have the following consequence.

**Corollary.**
*Suppose* &lt; a<sub>1</sub>, ..., s<sub>9</sub>, a<sub>10</sub>, a<sub>11</sub> &gt; *are
(non-negative) coefficients of a valid 4-variable entropy inequality. Let*
b<sub>10</sub> = min { a<sub>2</sub>, a<sub>5</sub>, a<sub>10</sub> }, *and*
b<sub>11</sub> = min { a<sub>8</sub>, a<sub>9</sub>, a<sub>11</sub> }. *Then
this is also a valid 4-variable inequality:* &lt; a<sub>1</sub>, ...,
a<sub>9</sub>, b<sub>10</sub>, b<sub>11</sub> &gt;.

**Proof.**
Let &lt; h<sub>1</sub>, ..., h<sub>11</sub> &gt; be an almost entropic point.
By Theorem 2 so is &lt; h<sub>1</sub>, h<sub>2</sub>+h<sub>10</sub>, h<sub>3</sub>, ...,
h<sub>9</sub>, 0, h<sub>11</sub> &gt;. The inequality with coefficients
&lt; a<sub>i</sub> &gt; holds for this tuple, thus for all almost entropic points
&lt; h<sub>j</sub> &gt; we have

> a<sub>1</sub> h<sub>1</sub> + a<sub>2</sub> h<sub>2</sub> + ... +
> a<sub>9</sub> h<sub>9</sub> + a<sub>2</sub> h<sub>10</sub> +
> a<sub>11</sub> h<sub>11</sub>

(observe that instead of a<sub>10</sub> we have a<sub>2</sub>). Similarly,
a<sub>10</sub> can also be replaced by a<sub>5</sub>, which proves the first
statement. The second one can be proved similarly. &nbsp; &#x25a1;



