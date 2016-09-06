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
We use h<sub>1</sub>, ..., h<sub>15</sub> to denote the natural coordinates as
follows.

<table><tbody><tr><td align="left"> h<sub>1</sub>
</td><td align="left">[a,b,c,d] = -(a,b) + (a,b | c) + (a,b | d ) + (c,d) &ndash; the Ingleton expression</td></tr>
<tr><td align="left">h<sub>2</sub>, h<sub>3</sub>, h<sub>4</sub></td> <td
align="left">(a,b | c), &nbsp; (a,c | b), &nbsp; (b,c | a)</td></tr>
<tr><td align="left"> h<sub>5</sub>, h<sub>6</sub>, h<sub>7</sub></td> <td
align="left">(a,b | d), &nbsp; (a,d | b), &nbsp; (b,d | a)</td></tr>
<tr><td align="left"> h<sub>8</sub>, h<sub>9</sub>, h<sub>10</sub>,
h<sub>11</sub></td><td align="left"> (c,d | a), &nbsp; (c,d | b), &nbsp;
(c,d), &nbsp; (a,b | cd)</td></tr>
<tr><td align="left"> h<sub>12</sub>, h<sub>13</sub>, h<sub>14</sub>,
h<sub>15</td> <td align="left"> (a | bcd), &nbsp; (b | acd), &nbsp;
(c | abd), &nbsp; (d | abc)</td></tr>
</tbody></table>

**Theorem 1.** *If*, h<sub>1</sub> &le; 0*, and the 15-dimensional point* &lt; h<sub>1</sub>, ...,
h<sub>15</sub> &gt; *is almost entropic, then so is the point where the 
last four coordinates* h<sub>12</sub>, h<sub>13</sub>, h<sub>14</sub>,
h<sub>15</sub> *are set to zero while keeping the values of all other coordinates.*

**Proof.** This is Theorem 1 in [Matus -
Csirmaz](http://arxiv.org/pdf/1310.5957v1). Essentially this theorem is equivalent to
[T. H. Chan's theorem](https://arxiv.org/pdf/1302.2994.pdf) which says that
every entropy inequality can be strengthened to a balanced inequality. &nbsp; &#x25a1;

The converse of Theorem 1 is also true in the following sense.

**Claim** *Suppose* h<sub>1</sub> &le; 0 *and the point* &lt; h<sub>1</sub>, ...,
h<sub>11</sub>, 0, 0, 0, 0 &gt; *is almost entropic. Then for any
non-negative numbers* h<sub>12</sub>, h<sub>13</sub>, h<sub>14</sub>,
h<sub>15</sub> *the point* &lt;h<sub>1</sub>, ..., h<sub>15</sub>&gt; *is
also almost entropic.*

**Proof.**
Add &quot;private info&quot; with entropies h<sub>12</sub>, h<sub>13</sub>,
h<sub>14</sub>, h<sub>15</sub> 
to the four random variables. &quot;Private info&quot; means that the added random
variables are independent of each other and of everything else. &nbsp; &#x25a1;

From this point on we will consider only the 11-dimensional region spanned
by the first 11 natural coordinates of the almost entropic points. The
coordinates will be denoted by &lt;h<sub>1</sub>, ..., h<sub>11</sub>&gt;, 
and it will always be assumed that h<sub>1</sub> is not positive, and all 
other coordinates are non-negative.

The proof of Theorem 4 in [Matus - Csirmaz](http://arxiv.org/pdf/1310.5957v1) has
the following consequences.

**Theorem 2.**
a) *Suppose* x, y *are non-negative numbers and the point* &lt;h<sub>1</sub>, ..., 
h<sub>9</sub>, h<sub>10</sub>+x+y, h<sub>11</sub>&gt; *is almost entropic.
Then so is the point* &lt;h<sub>1</sub>, h<sub>2</sub>+x, h<sub>3</sub>,
h<sub>4</sub>, h<sub>5</sub>+y, h<sub>6</sub>, h<sub>7</sub>, h<sub>8</sub>,
h<sub>9</sub>, h<sub>10</sub>, h<sub>11</sub>&gt;.

b) *Suppose* x, y *are non-negative numbers and the point* &lt;h<sub>1</sub>,
..., h<sub>9</sub>, h<sub>10</sub>, h<sub>11</sub>+x+y &gt;
*is almost entropic. Then so is the point* &lt;h<sub>1</sub>, ...,
h<sub>7</sub>, h<sub>8</sub>+x, h<sub>9</sub>+y, h<sub>10</sub>,
h<sub>11</sub>&gt; &nbsp; &#x25a1;

For 4-variable entropy inequalities this theorem has the following
consequence.

**Corollary.**
*Suppose* &lt;a<sub>1</sub>, ..., a<sub>9</sub>, a<sub>10</sub>, a<sub>11</sub>&gt; *are
(non-negative) coefficients of a valid 4-variable entropy inequality. Let*
b<sub>10</sub> = min { a<sub>2</sub>, a<sub>5</sub>, a<sub>10</sub> }, *and*
b<sub>11</sub> = min { a<sub>8</sub>, a<sub>9</sub>, a<sub>11</sub> }.
*Then* &lt;a<sub>1</sub>, ..., a<sub>9</sub>, b<sub>10</sub>, 
b<sub>11</sub>&gt; *are also coefficients of a valid 4-variable inequality.* 

**Proof.**
Let &lt;h<sub>1</sub>, ..., h<sub>11</sub>&gt; be an almost entropic point.
By Theorem 2 so is &lt;h<sub>1</sub>, h<sub>2</sub>+h<sub>10</sub>, h<sub>3</sub>, ...,
h<sub>9</sub>, 0, h<sub>11</sub>&gt;. The inequality with coefficients
&lt;a<sub>i</sub>&gt; holds for this tuple, thus for all almost entropic points
&lt;h<sub>j</sub>&gt; we have

> a<sub>1</sub> h<sub>1</sub> + a<sub>2</sub> h<sub>2</sub> + ... +
> a<sub>9</sub> h<sub>9</sub> + a<sub>2</sub> h<sub>10</sub> +
> a<sub>11</sub> h<sub>11</sub> &ge; 0

(observe that here we have a<sub>2</sub> instead of a<sub>10</sub>). Similarly,
a<sub>10</sub> can also be replaced by a<sub>5</sub>, which proves the first
statement. The second one can be proved similarly. &nbsp; &#x25a1;

#### A 3-dimensional cross-section

Four permutations of the four random variables *a, b, c, d* keep the
Ingleton coordinate h<sub>1</sub>, and permute other natural coordinates as
follows. The c &#8660; d swap exchanges coordinates 2-3-4 and 5-6-7. The a
&#8660; b swap exchanges the coordinate pairs 3-4, 6-7 and 8-9. Thus if the
first line in the following table is almost entropic, then so are the other
three - and, consequently, the average of the four lines (recall that the 
almost entropic region is a closed convex cone).

<table><tr><td> abcd &nbsp; </td>
<td> h<sub>1</sub> </td>
<td> h<sub>2</sub> </td><td> h<sub>3</sub> </td><td> h<sub>4</sub> </td>
<td> h<sub>5</sub> </td><td> h<sub>6</sub> </td><td> h<sub>7</sub> </td>
<td> h<sub>8</sub> </td><td> h<sub>9</sub> </td><td> h<sub>10</sub> </td><td> h<sub>11</sub> </td>
</tr><tr><td> abdc &nbsp; </td>
<td> h<sub>1</sub> </td>
<td> h<sub>5</sub> </td><td> h<sub>6</sub> </td><td> h<sub>7</sub> </td>
<td> h<sub>2</sub> </td><td> h<sub>3</sub> </td><td> h<sub>4</sub> </td>
<td> h<sub>8</sub> </td><td> h<sub>9</sub> </td><td> h<sub>10</sub> </td><td> h<sub>11</sub> </td>
</tr><tr><td> bacd &nbsp; </td>
<td> h<sub>1</sub> </td>
<td> h<sub>2</sub> </td><td> h<sub>4</sub> </td><td> h<sub>3</sub> </td>
<td> h<sub>5</sub> </td><td> h<sub>7</sub> </td><td> h<sub>6</sub> </td>
<td> h<sub>9</sub> </td><td> h<sub>8</sub> </td><td> h<sub>10</sub> </td><td> h<sub>11</sub> </td>
</tr><tr><td> badc &nbsp; </td>
<td> h<sub>1</sub> </td>
<td> h<sub>5</sub> </td><td> h<sub>7</sub> </td><td> h<sub>6</sub> </td>
<td> h<sub>2</sub> </td><td> h<sub>4</sub> </td><td> h<sub>3</sub> </td>
<td> h<sub>9</sub> </td><td> h<sub>8</sub> </td><td> h<sub>10</sub> </td><td> h<sub>11</sub> </td>
</tr></table>

According to Theorem 2, the value of h<sub>10</sub> can be transferred to h<sub>2</sub>
(and h<sub>5</sub>) while keeping the point almost-entropic. Similarly, h<sub>11</sub> can be
transferred to h<sub>8</sub> (and h<sub>9</sub>). So if 
&lt;h<sub>1</sub>, ..., h<sub>11</sub>&gt; is almost entropic, then so is
the point with coordinates

> (1) &nbsp; &nbsp; &lt; -&alpha;, 2&beta;, &delta;, &delta;, 2&beta;, &delta;, &delta;, 
>  &gamma;, &gamma;, 0, 0 &gt;

where the non-negative values &alpha;, &beta;, &gamma;, &delta; are defined as

> &alpha; = - h<sub>1</sub><br>
> 2&beta; = ( h<sub>2</sub> + h<sub>5</sub>)/2 +  h<sub>10</sub><br>
> &gamma; = ( h<sub>8</sub> + h<sub>9</sub>)/2 +  h<sub>11</sub><br>
> &delta; = ( h<sub>3</sub> + h<sub>4</sub> + h<sub>6</sub> + h<sub>7</sub>)/4<br>

The symmetric central core or the almost entropy region defined by points in (1)
is a 4-dimensional closed convex cone. The 3-dimensional convex body **S** is
its cross-section when normalizing by the total entropy.

The total entropy **H**(abcd) of the four random variables can be expressed using the 
natural coordinates h<sub>1</sub>, ..., h<sub>15</sub> as

> **H**(abcd) = -4 h<sub>1</sub> + h<sub>2</sub> + h<sub>3</sub> + h<sub>4</sub> + 
> h<sub>5</sub> + h<sub>6</sub> + h<sub>7</sub> + 2 h<sub>8</sub> + 2 h<sub>9</sub> +
> h<sub>10</sub> + 3 h<sub>11</sub> + h<sub>12</sub> + h<sub>13</sub> + h<sub>14</sub> +
> h<sub>15</sub>.

If the coordinates h<sub>10</sub> = h<sub>11</sub> = ... = h<sub>15</sub> = 0, as
is the case in (1), then the total entropy is

> **H** = 4 &alpha; + 4 &beta; + 4 &gamma; + 4 &delta;,

thus we can normalize **S** by assuming that the total entropy is 4, that is, requiring

>  &alpha; + &beta; + &gamma; + &delta; = 1.

#### Visualizing **S**

The numbers &alpha;, &beta;, &gamma;, and &delta; sum to 1, thus they can be considered as 
*barycentric* coordinates: put weights &alpha;, &beta;, &gamma;, &delta; to the vertices of
a regular tetrahedron, and the point represented is the center of the weight. Points (1,0,0,0),
(0,1,0,0), (0,0,1,0) and (0,0,0,1) are the vertices of the tetrahedron. As &alpha;, &beta;,
&gamma;, &delta; are non-negative numbers, **S** has no point outside the tetrahedron. As
points (0,1,0,0), (0,0,1,0), and (0,0,0,1) are entropic, the whole &beta;&gamma;&delta;
triangle is part of **S**. The fourth vertex (1,0,0,0) is not elmost
entropic: it violates the Zhang-Yeung inequality, which can be expressed as (see (1)):

>  &alpha; &le; 2 &beta; + 2 &delta;

Similarly to this one, all 4-variable entropy inequality imposes some bound on **S**.
Collecting such inequalities, their intersection gives an outer
approximation of **S**.

