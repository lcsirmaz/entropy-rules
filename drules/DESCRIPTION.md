The bootstrap method
=======================

We start by repeating the idea behind the [copy
method](../copy/DESCRIPTION.md). Start with four random variables (denoted here by
*a, b, c, d*) as the initial pool. Create iteratively
identical copies of existing variables (or groups of variables) from the pool
such that these copies are independent given another subset of the
pool. The procedure is described by the *copy string*. The independence
and symmetries give several equalities among the entropies of the final set
of pool variables. The consequences of

> (1) &nbsp; &nbsp; these equalities, and <br>
> (2) &nbsp; &nbsp the collection of Shannon inequalities (for all subsets
> of pool variables)

on the 15 entropies of the original four variables are extracted.

Next to the Shannon inequalities in (2), entropies of the subsets of the
pool variables also satisfies other entropy inequalities, particularly
those ones which have been generated earlier.
Consequently, to the list above we can add

> (3) &nbsp; &nbsp; a collection of known 4-variable inequalities for one,
> two, or more bases,

and extract the consequences on this extended set of inequalities. A *base*
is just four subsets of the pool variables onto which those 4-variable
inequalities are applied.

#### How to do it

The perl utility [apply.pl](../utils/apply.pl) takes as arguments

* the description of a copy string,
* a file containing 4-variable inequalities,
* a series of bases,
* and the file name where the MOLP problem is written.

The utility creates the MOLP from (1), (2) and (3) as described above. 
New consequences can be extracted from its solution.

    # create the MOLP problem
    utils/apply.pl <copystring> <ineq-file> <base1> <base2> ... vlp/NN.vlp
    # solve the problem
    inner vlp/NN.vlp -o vlp/NN.res > vlp/NN.out
    # and extract 4-variable inequalities not superseded by those in <old-ineq>
    utils/checkall.pl vlp/NN.res <old-ineq> > result/NN.new

#### Rules as special cases

Rules, as defined by [Dougherty et al](http://arxiv.org/pdf/1104.3602v1),
generate a new 4-variables inequality from one or two such inequality.
The general form of such a rule (for the two-inequality case) is the
following. 

The rule is given by three 11-tuples of (non-negative) vectors. One is
**c**<sub>1</sub>, through **c**<sub>11</sub>, the second is **d**<sub>1</sub>
through **d**<sub>11</sub>, and the third is **e**<sub>1</sub> 
through **e**<sub>11</sub>. All vectors have the same dimension. The rule
can be used to generate new entropy inequality as follows:

> Choosing the non-negative parameters **x** = &lt x_j &gt; arbitrarily,
> if the numbers <br>
> **c**<sub>1</sub>&#183;**x**> **c**<sub>2</sub>&#183;**x**, ..., **c**<sub>11</sub>&#183;**x**,
> and <br>
> **d**<sub>1</sub>&#183;**x**> **d**<sub>2</sub>&#183;**x**, ..., **d**<sub>11</sub>&#183;**x**
> <br>
> are coefficients of valid 4-variable inequalities, then so are
> numbers</br>
> **e**<sub>1</sub>&#183;**x**> **e**<sub>2</sub>&#183;**x**, ...,
> **e**<sub>11</sub>&#183;**x**.

Here, for example, the inner product **c**<sub>1</sub>&#183;**x** is
computed as c<sub>1,1</sub>x<sub<1</sub> + c<sub>1,2</sub>x<sub>2</sub> +
... + c<sub>1,j</sub>x<sub>j</sub> + ...

Such a rule is defined by a copy string and two bases. Using equalities
and inequalities (1) and (2) for the copy string, then adding the 
first 4-variable inequality for the first base, the second 4-variables
inequality for the second base (two additional inequalities for (3)), 
the generated inequality is (one of) the consequences of this set as 
extracted by the bootstrap process.

#### Iterations

The description of the iteratively applied copy string &ndash; base 
pairs can be found in the [drules](drules.txt) file. Labels are the
rule numbers from [Dougherty et al](http://arxiv.org/pdf/1104.3602v1). Cases
masked by * are handled as rules, and not considered here.

In each iteration usually only the set of plugged-in 4-variable inequalities
changes, but ocassionally sporadic copy strings are tried; please check the
README file in the folders.




