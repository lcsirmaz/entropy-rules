New entropy inequalities by rules
=================================

A *rule*, as defined in [Dougherty et al](http://arxiv.org/pdf/1104.3602v1),
is a collection of vector pairs, each vector has 11 coordinates and members
of a pair is separated by a `<=` sign. Their Rule [1] from page 20 can be
rephrased by the following set of vector pairs:

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

The meaning of a rule is the following:

> *If* any non-negative linear combination of the left hand sides
> gives the coefficients of a valid entropy ineqyuality, *then* so
> does the combination of the right hand sides with the same combining
> values.

Using a rule one can quickly generate new entropy inequalities iteratively.
(The coordinate system in the Dougherty et al paper differs slightly from
our natural coordinates, and in formulating the rules they presented the
combining factors explicitely.)

A rule is specified by a *copy string* and four (possible composite) random
variables called *base*. For Rule [1] above the copy string is `r=a:bc`, and
the base is the four variable collection *ar, br, cr, d*.

### Proving the correctness of a rule

Suppose the rule is defined by the copy string **str** and base **B**.
Collect the entropies of all non-empty subsets of the random variables
occurring in the copy string and the base to the (quite long) vector **h**.
The copy string specifies that certain (composite) variables are identically
distributed, and are independent over others. These conditions can be expressed
as certain linear combinations of the entropies vanish, written here as the 
inner product of vectors **c**<sub>i</sub> and **h**:

> (1) &nbsp; &nbsp;  **c**<sub>i</sub>**h** = 0, for i=1, 2, ...

The number of **c**<sub>i</sub> vectors and their coordinates can be computed
from the copy string uniquely. Next, we collect all Shannon inequalities for the same
collection of entropies as

> (2) &nbsp; &nbsp; **s**<sub>j</sub>**h** &ge; 0, for j=1, 2, ...

We define the (easily computable) vectors *n**<sub>1</sub>,... **n**<sub>11</sub>
and **b**<sub>1</sub>, ..., **b**<sub>11</sub>  as follows. Vectors **n**<sub>1</sub>, ..., **n**<sub>11</sub> determine the first
11 natural coordinates of the random variables *a, b, c, d* as the inner
products **n**<sub>1</sub>**h**, ..., **n**<sub>11</sub>**h**. Additionally,
**b**<sub>1</sub>, ..., **b**<sub>11</sub> determine the natural coordinates
of the given base **B** as **b**<sub>1</sub>**h**, ..., **b**<sub>11</sub>**h**.

Consider all tuples  *x*<sub>1</sub>, ..., *x*<sub>11</sub>, and *y*<sub>1</sub>,
..., *y*<sub>11</sub> of non-negative real numbers for which the inequality

> (3) &nbsp; &nbsp; (*x*<sub>1</sub>**b**<sub>1</sub> + ... +
>                *x*<sub>11</sub>**b**<sub>11</sub>)**h** &le;
>              (*y*<sub>1</sub>**n**<sub>1</sub> + ... +
>                *y*<sub>11</sub>**n**<sub>11</sub>)**h**

is a consequence of the equalities / inequalities in (1) and (2). Any such pair
of tuples will be written as

>  (4) &nbsp; &nbsp;  [ *x*<sub>1</sub>, ..., *x*<sub>11</sub> ] &le; [ *y*<sub>1</sub>, ...,
> *y*<sub>11</sub> ].



**Claim 1.** *If* [ *x*<sub>i</sub> ] &le; [ *y*<sub>i</sub>], *and*
*x*<sub>1</sub>, ..., *x*<sub>11</sub> *are coefficients of a valid 
entropy inequality, then so are* *y*<sub>1</sub>, ... *y*<sub>11</sub>.


**Proof** 
Given the four random variables *a, b, c, d,* create the auxiliary
variables as described by the copy string **str**. Collect all entropies of
all these variables into the vector **h**. The vector **h** satisfies all
equalities in (1) and inequalities in (2), thus (3) holds as well. As
*x*<sub>1</sub>, ..., *x*<sub>11</sub> are coefficients of a valid entropy
inequality, and the scalar products **b**<sub>1</sub>**h**, ...,
**b**<sub>11</sub>**h** are the natural coordinates of the four random
variables defined by the base **B**, the left hand side of (3) is
non-negative. Consequently the right hand side is non-negative as well, thus
*y*<aub>1</sub>, ..., *y*<sub>11</sub> are indeed coefficients of a valid
entropy inequality. &nbsp; &#x25a1;

**Claim 2.** *If a collection of pair of tuples satisfy* (4), *then their
non-negative linear combination also satisfies* (4).

**Proof**
This is an easy consequence of the linearity of both sides of the inequality
(3). &nbsp; &#x25a1;

**Corollary.** *If all lines in a rule satisfies* (4), *then the rule is
correct.* &nbsp; &#x25a1;


### Generating rule lines automatically

According to **Claim 2** above, the collection of 22-dimensional vectors
&lt; *x*<sub>1</sub>, ..., *x*<sub>11</sub>, *y*<sub>1</sub>, ...,
*y*<sub>11</sub> &gt; forms a convex set. The ultimate set of rule lines is
the minimal set of 22-dimensional points from this set such that every other
point is a non-negative linear combination of these points. This set,
however, is nothing else but the *set of vertices* of the convex set. To get
all vertices of a (linearly defined) convex set is the task for a MOLP
solver.

In this case, however, we have some more information about the set which can
help in reducing the total work. First, the set is *homogeneous*, thus we
could settle for the cross-section where the sum of the 22 numbers in it is
exactly 1. Second, all 22 coordinates are non-negative; and at the extremal
points *x*<sub>1</sub> (the Ingleton coordinate) should be locally minimal,
*x*<aub>2</sub>, ..., *x*<sub>11</sub> be locally maximal; for the *y* 
coordinates it is just the opposite. Given the copy string and the base,
the perl utility `rulemk.pl` creates the MOLP instance; from the solution
the complete set of rule lines is extracted by ``minrule.pl`.

    # create MOLP for the rule specified by a copy string and base
    utils/rulemk.pl <copy-string> <base> vlp/NN.vlp
    # solve the problem
    inner vlp/NN.vlp -o vlp/NN.res > vlp/NN.out
    # extract the set of complete rule lines into NN.txt
    utils/minrule.pl vlp/NN.res ineq/NN.txt


### Applying a rule

Given a collection of 4-variable entropy inequalities specified by their
natural coordinates as **e**<sub>1</sub>, ..., **e**<sub>n</sub>, and a
rule with t lines:

>    [ **x**<sub>1</sub> ] &le; [ **y**<sub>1</sub> ]<br>
>    . . . <br>
>    [ **x**<sub>t</sub> ] &le; [ **y**<sub>t</sub> ]

We know that if a non-negative combination of the **x**<sub>i</sub>'s is
a valid information inequality, then so is the same combination of the
**y**<sub>i</sub>'s. Any non-negative linear combination of
**e**<sub>j</sub> is an information inequality, thus any element of this
set is a (perhaps new) information inequality:

>  (5) &nbsp; &nbsp;  &lambda;<sub>1</sub> **y**<sub>1</sub> + ... + &lambda;<sub>t</sub> **y**<sub>t</sub>

where

>  the Ingleton coefficient in (5) is 1, <br>
>  &lambda;<sub>1</sub> **x**<sub>1</sub> + ... + &lambda;<sub>t</sub>
> **x**<sub>t</sub> &ge; &mu;<sub>1</sub> **e**<sub>1</sub> + ... +
> &mu;<sub>n</sub> **e**<sub>n</sub>; the Ingleton coefficients are
> equal,<br>
>  and &lambda;<sub>i</sub> &ge; 0, &mu;<sub>j</sub> &ge; 0.

The set (5) is a convex set, and inequalities not superseded by others from
the same set are again solutions of a MOLP. To create that problem use the
perl utility `dorule.pl`, and the utility `checkall.pl` to extract the
inequalities:

    # apply a rule to a set of inequalitie and generate the vlp file
    utils/dorule.pl <ineqfile> <rule> vlp/NN.vlp
    # solve it
    inner vlp/NN.vlp -o vlp/NN.res > vlp/NN.out
    # extract inequalities not superseded by those in <ineqfile>
    utils/checkall.pl vlp/NN.res <ineqfile>

