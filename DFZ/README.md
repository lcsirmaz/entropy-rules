Dougherty - Freiling - Zeger inequalities
=================

Inequalities from the paper *R. Dougherty, C. 
Freiling, and K.  Zeger:* [Non-Shannon information inequalities in four random variables](http://arxiv.org/pdf/1104.3602v1) are
listed in [DFZ.txt](DFZ.txt) following their original numbering from 1 to 214. 
The [Zhang-Yeung inequality](http://www.cs.cornell.edu/courses/cs783/2007fa/papers/ZYnonShannon.pdf)
has been added as inequality number 0. Inequalities are rewritten using natural
coordinates, occasionally permuted using the *a &harr; b* and *c &harr; d*
symmetries. The *copy strings* are the original ones followed by the index of
the corresponding normalized and extended copy string. Recall that the &quot;over&quot;
sets must be *flats* (i.e., closed for direct consequences); and in the
initial *abcd* distribution the three-element subsets are *not* flats.

#### Interpreting the MOLP solutions

The directory [vlp](vlp) contains the MOLP problems and their solutions associated
with the normalized and extended copy strings.

    # generate the vlp file for a copy string
    utils/mkvlp.pl <copy-string> vlp/NNN.vlp
    # and solve the MOLP problem
    inner vlp/NNN.vlp -ov vlp/NNN.res -y- --PrintVertices=0 > vlp/NNN.out

The vertices of the solution in NNN.res are the 10-dimensional vectors 
&lt;*x*<sub>2</sub>, ..., *x*<sub>11</sub>&gt; for which the non-Shannon
inequality with coefficients

>  1, *x*<sub>2</sub>, ..., *x*<sub>11</sub>

(that is, the Ingleton cooefficient is 1, and the other coefficients are
supplied by the vertex coordinates) are the minimal (not superseded) ones
among all consequences yielded by the copy string. For more information 
see the [description](../copy/DESCRIPTION.md) in the [copy](../copy) section.
To get a readable list of all consequences of a copy string use the command

    # generate a readable list of the vertices in NNN.res
    utils/checkall.pl vlp/NNN.res

#### Content

* [DFZ.txt](DFZ.txt) &nbsp;&ndash; list of DFZ inequalities and copy strings.
* [vlp](vlp) &nbsp;&ndash; MOLP problems and solutions associated with DFZ inequality numbers.




