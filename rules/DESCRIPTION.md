New entropy inequalities by rules
=================================

A *single rule*, as defined in [Dougherty et al](http://arxiv.org/pdf/1104.3602v1),
is a collection of vector pairs; each vector has 11 coordinates and members
of a pair are separated by a `<=` sign. For example, Rule [1] from page 20
of the cited paper can be rephrased by the following set of vector pairs:

    [1,0,0,0,0,0,0,0,0,0,0] <= [1,1,1,0,0,0,0,0,0,0,0]
    [0,1,0,0,0,0,0,0,0,0,0] <= [0,1,0,0,0,0,0,0,0,0,0]
    [0,0,1,0,0,0,0,0,0,0,0] <= [0,0,1,0,0,0,0,0,0,0,0]
    [0,0,0,1,0,0,0,0,0,0,0] <= [1,1,1,1,0,0,0,0,0,0,0]
    [0,0,0,1,0,0,0,0,0,0,0] <= [0,1,0,1,0,0,0,0,0,0,0]
    [0,0,0,1,0,0,0,0,0,0,0] <= [0,0,1,1,0,0,0,0,0,0,0]
    [0,0,0,0,0,1,0,0,0,0,0] <= [0,0,1,0,0,1,0,0,0,0,0]
    [0,0,0,0,0,0,1,0,0,0,0] <= [0,0,1,0,0,0,1,0,0,0,0]
    [0,0,0,0,0,0,0,1,0,0,0] <= [0,1,0,0,0,0,0,1,0,0,0]
    [0,0,0,0,0,0,0,0,1,0,0] <= [0,1,0,0,0,0,0,0,1,0,0]
    [0,0,0,0,0,0,0,0,0,1,0] <= [0,0,0,0,0,0,0,0,0,1,0]
    [0,0,0,0,0,0,0,0,0,0,1] <= [0,0,0,0,0,0,0,0,0,0,1]

The meaning of such a rule is the following:

> *If* any non-negative linear combination of the left hand sides
> gives the 11 coefficients of a valid 4-variable entropy inequality, *then* so
> does the combination of the right hand sides with the same combining
> values.

Using a rule one can quickly generate new entropy inequalities iteratively
from existing ones.
(The coordinate system in the Dougherty et al paper differs slightly from
our natural coordinates, and in formulating a rule they present the
combining factors explicitly.)

A rule is specified by a *copy string* and four (possible composite) random
variables called *base*. For Rule [1] above the copy string is *r*=*a*:*bc*, and
the base is the four variable collection *ar, br, cr, d*.

### What is a rule set

Suppose the rule is defined by the copy string **str** and base **B**.
Collect the entropies of all non-empty subsets of the random variables
occurring in the copy string and the base to the (quite long) vector **h**.
The copy string [specifies](copy/DESCRIPTION.md) certain linear equalities
among the entropies. These can be written as equations stating that certain
inner products of fixed
vectors **c**<sub>i</sub> (determined by the copy string) and the vector of
entropies **h** vanish:

> (1) &nbsp; &nbsp;  **c**<sub>i</sub>&#183;**h** = 0, for i=1, 2, ...

The number of **c**<sub>i</sub> vectors and their coordinates can be computed
from the copy string uniquely. Next, we collect all Shannon inequalities for the same
collection of entropies as

> (2) &nbsp; &nbsp; **s**<sub>j</sub> &#183;**h** &ge; 0, for j=1, 2, ...

We define the (easily computable) vectors **n**<sub>1</sub>,... **n**<sub>11</sub>
and **b**<sub>1</sub>, ..., **b**<sub>11</sub> as follows. Vectors
**n**<sub>1</sub>, ..., **n**<sub>11</sub> determine the first
11 natural coordinates of the random variables *a, b, c, d* as the inner
products **n**<sub>1</sub>&#183;**h**, ..., **n**<sub>11</sub>&#183;**h**.
Additionally, **b**<sub>1</sub>, ..., **b**<sub>11</sub> determine the natural
coordinates of the given base **B** as **b**<sub>1</sub>&#183;**h**, ..., 
**b**<sub>11</sub>&#183;**h**.

Consider all pairs of 11-tuples  &lt;*x*<sub>1</sub>, ..., *x*<sub>11</sub>&gt;, and
&lt;*y*<sub>1</sub>, ..., *y*<sub>11</sub>&gt; of non-negative real numbers 
for which the inequality

> (3) &nbsp; &nbsp; (*x*<sub>1</sub>**b**<sub>1</sub> + ... +
>                *x*<sub>11</sub>**b**<sub>11</sub>)&#183;**h** &le;
>              (*y*<sub>1</sub>**n**<sub>1</sub> + ... +
>                *y*<sub>11</sub>**n**<sub>11</sub>)&#183;**h**

is a consequence of **h** &ge; 0, and the equalities in (1) and inequalities
in (2). Any such pair of tuples will be written as

>  (4) &nbsp; &nbsp;  [ *x*<sub>1</sub>, ..., *x*<sub>11</sub> ] &le; [ *y*<sub>1</sub>, ...,
> *y*<sub>11</sub> ].


**Claim 1.** *If* [ *x*<sub>1</sub>, ..., *x*<sub>11</sub> ] &le; [
*y*<sub>1</sub>, ..., *y*<sub>11</sub>], *and*
*x*<sub>1</sub>, ..., *x*<sub>11</sub> *are coefficients of a valid 
4-variable entropy inequality, then so are* *y*<sub>1</sub>, ... *y*<sub>11</sub>.


**Proof.** 
Given the four random variables *a, b, c, d,* create the auxiliary
variables as described by the copy string **str**. Collect all entropies of
all these variables into the vector **h**. The natural coordinates of *a, b,
c, d* are the scalar products **n**<sub>1</sub>&#183;**h**, ...,
**n**<sub>11</sub>&#183;**h**, thus we need to show that the right hand side
of (3) is non-negative.

The vector **h** &ge; 0 satisfies all
equalities in (1) and inequalities in (2), thus (3) holds as well. As
*x*<sub>1</sub>, ..., *x*<sub>11</sub> are coefficients of a valid entropy
inequality, and the scalar products **b**<sub>1</sub>&#183;**h**, ...,
**b**<sub>11</sub>&#183;**h** are the natural coordinates of the four random
variables defined by the base **B**, the left hand side of (3) is
non-negative. Consequently the right hand side is non-negative as well, thus
*y*<sub>1</sub>, ..., *y*<sub>11</sub> are indeed coefficients of a valid
entropy inequality, as claimed. &nbsp; &#x25a1;

**Claim 2.** *If a collection of pair of tuples satisfy* (4), *then their
non-negative linear combination also satisfies* (4).

**Proof.**
This is an easy consequence of the linearity of both sides of the inequality
(3). &nbsp; &#x25a1;

**Corollary.** *If all lines in a rule satisfies* (4), *then the rule is
correct.* &nbsp; &#x25a1;


### Generating a rule

According to **Claim 2** above, the collection of 22-dimensional vectors
&lt; *x*<sub>1</sub>, ..., *x*<sub>11</sub>, *y*<sub>1</sub>, ...,
*y*<sub>11</sub> &gt; satisfying (4) forms a convex 22-dimensional set *Q*. 
The ultimate set of rule lines is the minimal set of 22-dimensional points
from *Q* such that every other point of *Q* is a non-negative linear combination of
these extremal points.  This set, however, is nothing else but the *set of vertices*
of the convex set *Q*.  To determine all vertices of a (linearly defined) convex set
is the task for a MOLP solver.

In this case we have some more information about *Q* which can
help in reducing the total work. First, *Q* is *homogeneous*, thus we
could settle for the cross-section where the sum of the last 11 coordinates is
exactly 1. Second, all 22 coordinates are non-negative (*Q* is part of the
non-negative orthant); and at the extremal points *x*<sub>1</sub> (the 
Ingleton coordinate) should be locally minimal,
*x*<sub>2</sub>, ..., *x*<sub>11</sub> be locally maximal; for the *y* 
coordinates it is just the opposite: *y*<sub>1</sub> should be locally
maximal and *y*<sub>2</sub>, ..., *y*<sub>11</sub> be locally minimal. 
(A variable is *locally minimal* if fixing the value of the other unknowns,
its value cannot be decreased.)
Given the copy string and the base,
the perl utility `rulemk.pl` creates the MOLP instance according to these
observations. From the solution of the MOLP problem the complete set of 
rule lines is extracted by the utility ``minrule.pl`.

    # create MOLP for the rule specified by a copy string and base
    utils/rulemk.pl <copystring> <base> vlp/NN.vlp
    # solve the MOLP problem
    inner vlp/NN.vlp -o vlp/NN.res > vlp/NN.out
    # extract the set of complete rule lines into NN.txt
    utils/minrule.pl vlp/NN.res ineq/NN.txt


### Applying a rule

Suppose we have a collection of 4-variable entropy inequalities 
specified by their natural coordinates (considered as a collection 
of 11-dimensional vectors) **e**<sub>1</sub>, ..., **e**<sub>n</sub>, 
and a rule with t lines:

>    [ **x**<sub>1</sub> ] &le; [ **y**<sub>1</sub> ]<br>
>    . . . <br>
>    [ **x**<sub>t</sub> ] &le; [ **y**<sub>t</sub> ] .

We know that if a non-negative combination of the **x**<sub>i</sub>'s is
a valid information inequality, then so is the same combination of the
**y**<sub>i</sub>'s. Any non-negative linear combination of
**e**<sub>j</sub> is an information inequality, thus every element of 
the following set is a valid information inequality:

>  (5) &nbsp; &nbsp;  &lambda;<sub>1</sub> **y**<sub>1</sub> + ... + 
>  &lambda;<sub>t</sub> **y**<sub>t</sub> &nbsp;&ge;&nbsp; 0,

where

> &lambda;<sub>1</sub> &ge; 0, ..., &lambda;<sub>t</sub> &ge; 0, &nbsp;
> &mu;<sub>1</sub> &ge; 0, ..., &mu;<sub>n</sub> &ge; 0; <br>
> &lambda;<sub>1</sub> **x**<sub>1</sub> + ... + &lambda;<sub>t</sub>
> **x**<sub>t</sub> &ge; &mu;<sub>1</sub> **e**<sub>1</sub> + ... +
> &mu;<sub>n</sub> **e**<sub>n</sub>; <br>
> the Ingleton coefficients on both sides are equal.

The set (5) is a convex set, and (normalized) inequalities not superseded
by others are the solutions of a MOLP. To create that problem use the
perl utility `dorule.pl`. From the result the utility `checkall.pl` extracts
new inequalities:

    # apply a rule to a set of inequalities and generate the vlp file
    utils/dorule.pl <ineqfile> <rule> vlp/NN.vlp
    # solve it
    inner vlp/NN.vlp -o vlp/NN.res > vlp/NN.out
    # extract new inequalities not superseded by those in <ineqfile>
    utils/checkall.pl vlp/NN.res <ineqfile>

