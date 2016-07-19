Entropy inequalities by copy strings
=====================================

The *copy method*, invented by Z. Zhang and R. W. Yeung, lead to the first
non-Shannon entropy inequality. The method has been described in details by
R. Dougherty, C. Freiling and K. Zeger:
[Non-Shannon information inequalities in four random variables](http://arxiv.org/pdf/1104.3602v1)

Starting with four random variables, denoted by *a, b, c, d*, one creates
iteratively identical copies of some existing variables (or groups of variables)
which are independent given another subset of the variables. This procedure
is described by the **copy string**, an example is

    rs=cd:ab;tu=cr:ab;v=(tu):ad

It describes three iterations. First, *r* and *s* are identical copies of *c*
and *d*, respectively, such that *rs* and *cd* are independent over *ab*. Next,
*t* and *u* are copies of *c* and *r* such that *tu* and *cr* are independent
over *ab*. Finally, *v* is a copy of the group *tu* (they are identically 
distributed), and they are independent given *ad*.

The independence and symmetries in the copy string gives several equalities
among the entropies of the final set of random variables. These together with
all Shannon inequalities have consequences on the entropies of the original
four variables. The consequences are extracted using the MOLP solver 
[inner](https://github.com/lcsirmaz/inner).

    utils/mkvlp.pl <copystring> copy/vlp/NN.vlp      # create MOLP problem for a copy string
    inner copy/vlp/NN.vlp -o copy/vlp/NN.res         # solve MOLP problem

Extracting new inequalities: all, those with coefficients below 200, and with
coefficients below 100. Labels for superseded inequalities are collected in
files `sups.*`:

    utils/downgrade.pl -t 1000 copy/vlp/NN.res <known-ineqs>  copy/NN.new
    utils/downgrade.pl -t 99   copy/vlp/NN.res <known-ineqs>  copy/NN.dw1
    utils/downgrade.pl -t 199  copy/vlp/NN.res <known-ineqs>  copy/NN.dw2

#### Content

* [copy.txt](copy.txt) &nbsp;&ndash; description of copy strings
* NN.new &nbsp;&ndash; new inequalities from the given copy string
* NN.dw1 &nbsp;&ndash; new inequalities with coeffs <100
* NN.dw2 &nbsp;&ndash; new inequalities with coeffs <200
* [vlp](vlp) &nbsp;&ndash; vlp files and solutions of the MOLP problems

