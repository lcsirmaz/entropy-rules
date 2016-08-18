Entropy inequalities by copy strings
=====================================

The *copy method*, invented by Z. Zhang and R. W. Yeung, lead to the first
non-Shannon entropy inequality. The method has been described in details in
R. Dougherty, C. Freiling and K. Zeger:
[Non-Shannon information inequalities in four random variables](http://arxiv.org/pdf/1104.3602v1)
where the authors used the method to generate 214 new entropy inequalities
listed in [DFZ/orig.txt](../DFZ/orig.txt).

In nutshell, the method can be described as follows. Start with four variables
denoted as *a, b, c, d* as the initial pool of random variables. Create iteratively 
identical copies of some existing variables (or groups of variables) from
the pool such that the copies are independent given another subset of the 
variables. This procedure is described by a *copy string* like this one:

    rs=cd:ab;tu=cr:ab;v=(tu):ad

This string describes three iterations.  First, *r* and *s* are created as
identical copies of *c* and *d*, respectively, such that *rs* and *cd* are
independent over *ab*.  Next, *t* and *u* are copies of *c* and *r* such
that *tu* and *cr* are independent over *ab*.  At this point the pool of
random variables consists of *a, b, c, d, r, s, t, u*.  In the last step *v* is
created as a copy of the group *tu* such that *v* and *tu* are independent
given *ad*.

The independence and symmetries in the copy string lead to several equalities
among the entropies of the final set of random variables. These together with
all Shannon inequalities have consequences on the entropies of the original
four variables. The consequences are extracted using the MOLP solver 
[inner](https://github.com/lcsirmaz/inner). Finally, from the set of
extremal vertices we extract entropy inequalities which are not consequences
of the ones in the DFZ list. This is achieved by using perl utilities from
[utils](../utils/) as follows:

    # create the MOLP problem from a copy string to NN.vlp:
    mkvlp.pl <copystring> vlp/NN.vlp
    # solve the MOLP problem storing the result in vlp/NN.res
    inner vlp/NN.vlp -o vlp/NN.res > vlp/NN.out
    # extract inequalities which do not follow from those in base.new
    downgrade.pl vlp/NN.res base.new > result/NN.new

The file [base.new](base.new) contains the DFZ inequalities in machine
readable form. The applied
copy strings are listed in [copy.txt](copy.txt) indicating which strings
yield no new inequality beyond the ones in the DFZ list. As a final step,
minimal inequalities are extracted to [ineq.txt](ineq.txt) upgraded whenever
a new copy string is added:

    # determine which inequalities are superseded by others
    purge.pl base.new result/*.new > supd.new
    # generate the list of all new inequalities into ineq.txt and ineq-normalized.txt
    genlist.pl -s supd.new ineq.txt base.new result/*.new

#### Limitations

On a decent personal computer the outlined method can handle copy strings with up to
five auxiliary variables (*r, s, t, u, v*) easily, independently the number of
iterations. Handling copy strings with six auxiliary variables requires significantly
more resources, and occasionally the MOLP solver aborts due to numerical errors. It
might need special parametrization and several trials.
Copy strings with *seven* auxiliary variables are beyond the capabilities of the
present technology. Due to the low rank of the constraint matrix, it is numerically
ill-conditioned, and the solution returned by any scalar LP solver (if it does not
fail at all) can be off by such a large value that messes up the rest of the
algorithm.

####  Content

* [copy.txt](copy.txt) &nbsp;&ndash; description of copy strings
* [ineq.txt](ineq.txt) &nbsp;&ndash; new inequalities from all copy strings
* [ineq-normalized.txt](ineq-normalized.txt) &nbsp;&ndash; new inequalities in normalized form 
* [base.new](base.new) &nbsp;&ndash; original DFZ inequalities
* [vlp](vlp) &nbsp;&ndash; vlp files and solutions of the MOLP problems
* [result](result) &nbsp;&ndash; new inequalities from the given copy string which are not consequences of those in `base.new`
* [supd.new](supd.new) &nbsp;&ndash; labels of superseded inequalities.


