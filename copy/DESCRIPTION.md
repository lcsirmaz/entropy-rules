Entropy inequalities by copy strings
=====================================

The *copy method*, invented by Z. Zhang and R. W. Yeung, lead to the first
non-Shannon entropy inequality. The method has been described in details in
R. Dougherty, C. Freiling and K. Zeger:
[Non-Shannon information inequalities in four random variables](http://arxiv.org/pdf/1104.3602v1)
where the authors used the method to generate 214 new entropy inequalities
listed in [DFZ/orig.txt](../DFZ/orig.txt).

In nutshell, the method can be described as follows. Start with four variables
(denoted here by *a, b, c, d*) as the initial pool of random variables. Create
iteratively 
identical copies of some existing variables (or groups of variables) from
the pool such that these copies are independent given another subset of the 
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
among the entropies of the final set of random variables. As an example,
consider the copy string

    rs=cd:ab

which says that *r* and *s* are copies of *c* and *d*, respectively, such
that *rs* and *cd* are independent over *ab*. Then

> **I**(rs,cd | ab) = 0, that is, **H**(abcd) + **H**(abrs) = **H**(ab) +
> **H**(abcdrs) .

Moreover, *cd* and *rs* are totally symmetric, thus if in any subset *X* of
random variables we replace *c* by *r*, *r* by *c*, *d* by *s* and *s* by
*d*, then the entropy does not change. For example,

> **H**(c) = **H**(r), **H**(cd) = **H**(rs), **H**(abcd) = **H**(abrs),
> **H**(ard) = **H**(acs),

and many others. (Note that all occurrences of *c*, *d*, *r*, *s* in the 
string must be changed to their corresponding values.) 
These equalities together with
all Shannon inequalities have consequences on the 15 entropies of the original
four variables. The consequences are extracted using the MOLP solver 
[inner](https://github.com/lcsirmaz/inner). Finally, from the set of
extremal vertices we extract those entropy inequalities which are not 
consequences of the ones in the DFZ list. This is achieved by using perl
utilities from [utils](../utils/) as follows:

    # create the MOLP problem from a copy string to NN.vlp
    utils/mkvlp.pl <copystring> vlp/NN.vlp
    # solve the MOLP problem and store the result in vlp/NN.res
    inner vlp/NN.vlp -o vlp/NN.res > vlp/NN.out
    # extract inequalities which do not follow from those in base.new
    utils/checkall.pl vlp/NN.res base.new > result/NN.new

The file [base.new](base.new) contains the DFZ inequalities in machine
readable form. The applied
copy strings are listed in [copy.txt](copy.txt) indicating which string
yields no new additional inequality. As a final step, the
minimal set of inequalities is extracted to [ineq.txt](ineq.txt).

    # determine which inequalities are superseded by others
    utils/purge.pl base.new result/*.new > supd.new
    # generate the list of all new inequalities into ineq.txt and ineq-normalized.txt
    utils/genlist.pl -s supd.new ineq.txt base.new result/*.new

#### How the MOLP problem is generated

The `mkvlp.pl` utility creates the MOLP problem from the description of a
copy string. The original variables are *a,b,c,* and *d*, and *r,s,t,u,v,w*
can be used as auxiliary variables. All variables used in the copy string
are collected. The conditional independence(s) stipulated by the copy string
is written as (possibly several) equality among the entropies of the subsets
of the variables. Indeed, if *aX* and *Y* are independent given *Z*, that
is, **I**(*aX*;*Y*|*Z*)=0, then we also have **I**(*X*;*Y*|*Z*)=0. Also, all
equality among these entropies are considered which are consequences of the
above discussed symmetry. Each equality allows eliminating one entropy from
the whole set of inequalities; this is done in order to reduce the
complexity of the problem.

As a next step, &quot;minimal&quot; Shannon inequalities are collected,
namely those which imply all other Shannon inequalities. They are the ones
of the form **I**(*x*;*y*|*Z*)&ge;0 where *x* and *y* are single variables,
and *Z* is a subset of variables not containing *x* or *y*. From a remark
of *F. Matus* it follows that inequalities describing monotonicity are
superfluous, so they can be omitted.

As a last step, each inequality is rewritten using entropy expressions
which define the natural coordinates of *a,b,c,d* rather than the entropies
of the subsets of *a,b,c,d*. The final collection is a set of (homogeneous)
inequalities of the form

> *a*<sub>i,1</sub>**N**<sub>1</sub> + *a*<sub>i,2</sub>**N**<sub>2</sub>
> + ... + *a*<sub>i,15</sub>**N**<sub>15</sub> +
> *a*<sub>i,16</sub>**H**(*X*<sub>16</sub>) +
> *a*<sub>i,17</sub>**H**(*X*<sub>17</sub>) + ... +
> *a*<sub>i,n</sub>**H**(*X*<sub>n</sub>) &ge; 0,

where **N**<sub>1</sub>, ..., **N**<sub>15</sub> are the entropy expressions
corresponding to the natural coordinates; moreover *X*<sub>16</sub>, ...
*X*<sub>17</sub> are subsets random variables containing some auxiliary
variable (those ones whch remained after the elimination step). 


#### Limitations

On a decent personal computer the outlined method can handle copy strings with up to
five auxiliary variables (*r, s, t, u, v*) easily, independently the number of
iterations. Handling copy strings with six auxiliary variables requires significantly
more resources, and occasionally the MOLP solver aborts due to numerical errors. It
might need special parametrization and several trials.
Copy strings with seven auxiliary variables seem to be beyond the capabilities of the
applied technology. Due to the low rank of the constraint matrix, it is numerically
ill-conditioned, and the solution returned by any scalar LP solver (if it does not
fail at all) can be off by such a large amount that messes up the rest of the
MOLP algorithm.


