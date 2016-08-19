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
our natural coordinates, and in formulating the rules they used the
combining factors explicitely denoted by *a*, *b*, etc.)

A rule is specified by a *copy string* and four (possible composite) random
variables called *base*. For Rule [1] above the copy string is `r=a:bc`, and
the base is the four variable collection *ar,br,cr,d*.

#### Proving the correctness of a rule

Suppose the rule is defined by the copy string **str** and base **B**.
Collect the entropies of all non-empty subsets of the random variables
occurring in the copy string and the base to the (quite long) vector **h**.
The copy string specifies that certain (composite) variables are identically
distributed, are independent over others. These conditions can be expressed
as certain linear combinations of the entropies vanish written here as the 
inner product of vectors **c**<sub>i</sub> and **h**:

> (1) &nbsp; &nbsp;  **c**<sub>i</sub>**h** = 0, for i=1, 2, ...

The number of **c**<sub>i</sub> vectors and their coordinates can be computed
from the copy string. Next, we collect all Shannon inequalities for the same
collection of entropies as

> (2) &nbsp; &nbsp; **s**<sub>j</sub>**h** &ge; 0, for j=1, 2, ...

The vectors **n**<sub>1</sub>, ..., **n**<sub>11</sub> determine the first
11 natural coordinates of the random variables *a, b, c, d* as the inner
products **n**<sub>1</sub>**h**, ..., **n**<sub>11</sub>**h**.  Finally,
**b**<sub>1</sub>, ..., **b**<sub>11</sub> determine the natural coordinates
of the given base as **b**<sub>1</sub>**h**, ..., **b**<sub>11</sub>**h**.

Consider the tuples  *x*<sub>1</sub>, ..., *x*<sub>11</sub>, and *y*<sub>1</sub>,
..., *y*<sub>11</sub> of non-negative numbers for which the inequality

> (3) &nbsp; &nbsp; (*x*<sub>1</sub>**b**<sub>1</sub> + ... +
>                *x*<sub>11</sub>**b**<sub>11</sub>)**h** &le;
>              (*y*<sub>1</sub>**n**<sub>1</sub> + ... +
>                *y*<sub>11</sub>**n**<sub>11</sub>)**h**

is a consequence of the equalities / inequalities in (1) and (2); such pair
of tuples will be written as

>  [ *x*<sub>1</sub>,..., *x*<sub>11</sub> ] &le; [ *y*<sub>1</sub>,...,
> *y*</sub>11</sub> ].



**Claim** *If* [ *x*<sub>1</sub>,... ] &le; [ *y*<sub>1</sub>,...], *and*
*x*<aub>1</sub>,... *are coefficients of a valid entropy inequality, then so
are* *y*<sub>1</sub>, ... *y*<sub>11</sub>.

&nbsp;

**Proof** 
Given the four random variables *a, b, c, d,* create the auxiliary
variables as described by the copy string **str**. Collect all entropies of
all these variables into the vector **h**. The vector **h** satisfies all
equalities in (1) and inequalities in (2), thus (3) holds as well. As
*x*<sub>1</sub>, ..., *x*<sub>11</sub> are coefficients of a valid entropy
inequality, and the scalar products **b**<sub>1</sub>**h**, ...,
**b**<sub>11</sub>**h** are the natural coordinates of the four random
variables defined by the base *B*, the left hand side of (3) is
non-negative. Consequently the right hand side is non-negative as well, thus
*y*<aub>1</sub>, ..., *y*<sub>11</sub> are indeed coefficients of a valid
entropy inequality. &nbsp; &#x25a1;


<!--

Given a rule, use `rulemk.pl` to generate the vlp file for maximal set of
inequalities. From the result `minrule.pl` extracts basic inequalities
representing that rule; the result is stored in the `ineq/NN.txt` file.

    utils/rulemk.pl <copystring> <base> rules/vlp/NN.vlp       #create MOLP for a rule
    inner rules/vlp/NN.vlp -o rule/vlp/NN.res                  #solve
    utils/minrule.pl rules/vlp/NN.vlp rules/ineq/NN.txt        #generate the rule file

The top line of a *rule file* describes what the rule was generated from.
Other lines show two vectors of 11 coefficients separated by a `<=` sign:

    c Maximal rule for r=a:bc;s=r:ab; s,b,c,d
    [0,0,0,0,0,1,0,0,0,0,1] <= [0,3,1,2,0,0,1,0,0,0,0]
    [0,0,1,0,0,1,0,0,1,0,1] <= [0,2,1,3,1,0,0,0,0,1,0]
    [0,0,1,0,0,1,0,0,1,0,1] <= [0,2,1,3,1,0,0,1,0,0,0]
    [0,0,2,0,0,2,0,0,1,0,2] <= [1,5,2,4,1,0,0,0,0,1,0]
    [0,1,0,0,0,0,0,0,0,0,0] <= [0,2,0,1,0,0,0,0,0,0,0]
    [1,0,0,0,0,0,0,0,0,0,0] <= [0,1,1,1,1,0,0,1,0,0,0]
    [1,0,0,0,0,0,0,0,0,0,0] <= [0,2,0,1,0,1,0,1,0,0,0]
    [1,0,1,0,0,0,0,0,0,0,0] <= [0,2,1,1,0,0,0,1,0,1,0]

The described rule can be phrased as follows. **If** any non-negative linear 
combination of the left hand sides gives the coeffiecients of a valied entropy
inequality, **then** so does the right hand side with the same combining values.

The utility `dorule.pl` applies a particular rule to a set of known inequalities
by generating a vlp file whose solution gives the minimal set of bootstrapped
inequalities. The procedure can be iterated using the new set of inequalities.

    utils/dorule.pl <ineqfile> <rule> <vlpfile>      #apply the rule and generate vlp 
    inner <vlpfile> -o <solution>                    #solve
    utils/downgrade.pl <solution> <known-ineqs>      #check for new inequalities

-->

#### Content

* [rules.txt](rules.txt) &nbsp;&ndash; description of rules
* [ineq](ineq) &nbsp;&ndash; the rule files
* [vlp](vlp) &nbsp;&ndash; rule vlp files and solutions for the rules
* [iter1](iter1) &nbsp;&ndash; first iteration appliead to the set of inequalities in [iter1/ineq.dw2](iter1/ineq.dw2)
* [iter2](iter2) &nbsp;&ndash; second iteration
