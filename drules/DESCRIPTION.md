The bootstrap method
=======================

We outline first the idea behind the [copy
method](../copy/DESCRIPTION.md). Start with four random variables (denoted here by
*a, b, c, d*) as the initial pool. Create iteratively
identical copies of existing variables (or groups of variables) from the pool
such that these copies are independent given another subset of the
pool. This procedure is described by the *copy string*. The independence
and symmetries give several equalities among the entropies of the final set
of pool variables. The consequences of

> (1) &nbsp; &nbsp; these equalities, and <br>
> (2) &nbsp; &nbsp; the collection of Shannon inequalities (for all subsets
> of pool variables)

on the 15 entropies of the original four variables are extracted by solving
a MOLP problem.

Next to the Shannon inequalities in (2), entropies of the subsets of the
pool variables satisfy other entropy inequalities, particularly
those ones which have been generated earlier.
Consequently, to the list above we can add

> (3) &nbsp; &nbsp; a collection of known 4-variable inequalities for one,
> two, or more bases,

and extract the consequences on this extended set instead. A *base*
is just a sequence of four subsets of the pool variables to which the 4-variable
inequalities are applied.

#### How to do it

The perl utility [apply.pl](../utils/apply.pl) takes as arguments

* the description of a copy string,
* a file containing 4-variable inequalities,
* a series of bases,
* and the file name where the MOLP problem is to be written.

The utility creates the MOLP from (1), (2) and (3) as described above. 
New consequences can be extracted from the solution of the MOLP problem.

    # create the MOLP problem
    utils/apply.pl <copystring> <ineq-file> <base1> <base2> ... vlp/NN.vlp
    # solve the problem
    inner vlp/NN.vlp -o vlp/NN.res > vlp/NN.out
    # and extract 4-variable inequalities not superseded by those in <old-ineq>
    utils/checkall.pl vlp/NN.res <old-ineq> > result/NN.new

#### Rules as special cases

Rules, as defined by [Dougherty et al](http://arxiv.org/pdf/1104.3602v1),
generate a new 4-variables inequality from one or two such inequality.
The general form of such a *double rule* is described below, but see
the description in [9drule](../9drule/DESCRIPTION.md). 

A *rule* (or ruleset) is defined by three 11-tuples of (non-negative)
(column) vectors. In other words, by three matrices with the same number of
rows, and 11 columns each. The first one is
**c**<sub>1</sub>, through **c**<sub>11</sub>, the second one is **d**<sub>1</sub>
through **d**<sub>11</sub>, and the third one is **e**<sub>1</sub> 
through **e**<sub>11</sub>. All vectors have the same dimension, the number
or rows in the matrices. Such a ruleset can be used to generate new
entropy inequality as follows:

> Choose the non-negative parameters **x** = &lt; x_j &gt; arbitrarily.
> <br>
> If the numbers **c**<sub>1</sub>&#183;**x**, **c**<sub>2</sub>&#183;**x**, ..., **c**<sub>11</sub>&#183;**x**,
> and 
> **d**<sub>1</sub>&#183;**x**, **d**<sub>2</sub>&#183;**x**, ..., **d**<sub>11</sub>&#183;**x**
> are coefficients of valid 4-variable inequalities, <br> then so are
> numbers
> **e**<sub>1</sub>&#183;**x**, **e**<sub>2</sub>&#183;**x**, ...,
> **e**<sub>11</sub>&#183;**x**.

Here, for example, the inner product **c**<sub>1</sub>&#183;**x** is
computed as c<sub>1,1</sub>x<sub>1</sub> + c<sub>1,2</sub>x<sub>2</sub> +
... + c<sub>1,j</sub>x<sub>j</sub> + ...

Such a rule is determined by a copy string and two bases. Using equalities
(1) and inequalities (2) for the copy string, then adding the 
first 4-variable inequality for the first base, the second 4-variables
inequality for the second base (two additional inequalities in (3)), 
the generated inequality is (one of) the consequences of this set as 
extracted by the bootstrap process.

#### Iterations

The description of the iteratively applied copy string &ndash; base 
pairs are in [drules](drules.txt). The labels are the
rule numbers from [Dougherty et al](http://arxiv.org/pdf/1104.3602v1). Cases
marked by * are handled as [rules](../rules), and are not considered here.

In each iteration usually typically the set of plugged-in 4-variable inequalities
changes, but ocassionally new copy strings are added. Please check the
corresponding README file in these folders.




