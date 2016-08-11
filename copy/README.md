Entropy inequalities by copy strings
=====================================

The *copy method*, invented by Z. Zhang and R. W. Yeung, lead to the first
non-Shannon entropy inequality. The method has been described in details in
R. Dougherty, C. Freiling and K. Zeger:
[Non-Shannon information inequalities in four random variables](http://arxiv.org/pdf/1104.3602v1)
Where the authors used the method to generate 216 new entropy inequalities
listed in [DFZ/orig.txt](../DFZ/orig.txt).

In nutshell, the method can be described as follows. Start with four variables
denoted as *a, b, c, d*, and create iteratively identical copies of some 
existing variables (or groups of variables) which are independent given 
another subset of the variables. This procedure is described by 
the **copy string**, such as

    rs=cd:ab;tu=cr:ab;v=(tu):ad

This string describes three iterations: first, *r* and *s* are identical 
copies of *c* 
and *d*, respectively, such that *rs* and *cd* are independent over *ab*. Next,
*t* and *u* are copies of *c* and *r* such that *tu* and *cr* are independent
over *ab*. Finally, *v* is a copy of the group *tu*, and *v* and *tu* are 
independent given *ad*.

The independence and symmetries in the copy string gives several equalities
among the entropies of the final set of random variables. These together with
all Shannon inequalities have consequences on the entropies of the original
four variables. The consequences are extracted using the MOLP solver 
[inner](https://github.com/lcsirmaz/inner). Finally, from the set of
extremal vertices we extract those new inequalities which have
coefficients below 1000. To this we use perl utilities from the
[utils](../utils/) directory:

    # create the MOLP problem from a copy string
    mkvlp.pl <copystring> vlp/NN.vlp
    # solve the MOLP problem storing the result in vlp/NN.res
    inner vlp/NN.vlp -o vlp/NN.res
    # extract inequalities not following from those in base.new
    downgrade.pl -t 1000 vlp/NN.res base.new > result/NN.new
    # determine which inequalities are superseded by others
    purge.pl base.new result/*.new > supd.new
    # generate the list of all new inequalities into ineq.txt
    genlist.pl -s supd.new ineq.txt base.new result/*.new

####  Content

* [copy.txt](copy.txt) &nbsp;&ndash; description of copy strings
* [ineq.txt](ineq.txt) &nbsp;&ndash; new inequalities from all copy strings
* [base.new](base.new) &nbsp;&ndash; original DFZ inequalities
* [vlp](vlp) &nbsp;&ndash; vlp files and solutions of the MOLP problems
* [result](result) &nbsp;&ndash; new inequalities from the given copy string which are not consequences of those in `base.new`
* [supd.new](supd.new) &nbsp;&ndash; labels of inequalities superseded by others.

