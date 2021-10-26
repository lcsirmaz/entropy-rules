Dougherty - Freiling - Zeger inequalities
=================

The inequalities from *R. Dougherty, C. 
Freiling, and K.  Zeger:* [Non-Shannon information inequalities in four random variables](http://arxiv.org/pdf/1104.3602v1) are
listed in [orig.txt](orig.txt) following their original numbering from 1 to 214. 
The [Zhang-Yeung inequality](http://www.cs.cornell.edu/courses/cs783/2007fa/papers/ZYnonShannon.pdf)
has been added as inequality number 0. Inequalities rewritten using natural
coordinates and the *copy string* normalized and extended so that the &quot;over&quot;
sets are flats (i.e., closed for direct consequences) are listed in [ineq.txt](ineq.txt).
Observe that the initial *abcd* distribution can be assumed to have the
property that each variable is determined by the other three.

#### Interpreting the MOLP solutions

The directory [vlp](vlp) contains the MOLP problems and solutions associated
with the copy strings in the DFZ list.

    # generate the vlp file for a copy string
    utils/mkvlp.pl <copy-string> vlp/NNN.vlp
    # and solve the MOLP problem
    inner vlp/NNN.vlp -ov vlp/NNN.res -y- --PrintVertices=0 > vlp/NNN.out

The vertices of the solution in NNN.res are those 
10-dimensional vectors &lt;*x*<sub>2</sub>, ..., *x*<sub>11</sub>&gt; for
which the non-Shannon inequalities with coefficients

>  1, *x*<sub>2</sub>, ..., *x*<sub>11</sub>

(that is, the Ingleton cooefficient is 1, and the other coefficients are
supplied by the vertex coordinates) are the minimal (not superseded) ones
among all consequences yielded by the copy string. For more information 
see the [description](../copy/DESCRIPTION.md) in the [copy](../copy) section.
To get a readable list of the generated inequalities, use

    # generate a readable list of the vertices in NNN.res
    utils/checkall.pl vlp/NNN.res

#### Content

* [orig.txt](orig.txt) &nbsp;&ndash; raw file of original DFZ inequalities.
* [ineq.txt](inex.txt) &nbsp;&ndash; DFZ inequalities in natural coordinates with normalized copy strings.
* [vlp](vlp) &nbsp;&ndash; MOLP problems and solutions associated with DFZ inequality numbers.




