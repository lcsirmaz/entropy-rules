Dougherty - Freiling - Zeger inequalities
=================

The inequalities from *R. Dougherty, C. 
Freiling, and K.  Zeger:* [Non-Shannon information inequalities in four
random variables](http://arxiv.org/pdf/1104.3602v1) are
listed in [main.txt](main.txt) following their original numbering from 1 to 214. 
The [Zhang-Yeung inequality](http://www.cs.cornell.edu/courses/cs783/2007fa/papers/ZYnonShannon.pdf)
has been added as inequality number 0. Inequalities are rewritten using natural
coordinates. [orig](orig.txt) lists the original copy strings. The list in [DFZ](DFZ.txt)
follows the convention of the [copy](../copy) section. Copy strings are normalized by using the
perl utility [simp.pl](../utils/simp.pl), and extended to flats when necessary. Only a minimal
set of 87 copy strings are retained. (The very first copy string yielding the Zhang-Yeung
inequality is an exception). The last column indicates the file name handling the copy string.

#### Interpreting the MOLP solutions

The directory [vlp](vlp) contains the MOLP problems and solutions associated
with the copy strings in the [DFZ](DFZ.txt) list.

    # generate the vlp file for a copy string
    utils/mkvlp.pl <copy-string> vlp/NN.vlp
    # and solve the MOLP problem
    inner vlp/NN.vlp -ov vlp/NN.res -y- --PrintVertices=0

The vertices of the solution in NN.res are just the collection of those 
10-dimensional vectors &lt;*x*<sub>2</sub>, ..., *x*<sub>11</sub>&gt; such
that the non-Shannon inequalities with coefficients

>  1, *x*<sub>2</sub>, ..., *x*<sub>11</sub>

(that is, the Ingleton cooefficient is 1, and the other coefficients are
supplied by the vertex coordinates) are the minimal (not superseded) ones
among all consequences yielded by the specified copy string. For more information
see the [description](../copy/DESCRIPTION.md) in the [copy](../copy) section.

#### Content

* [orig](orig.txt) &nbsp;&ndash; original DFZ inequalities and copy strings
* [DFZ](DFZ.txt) &nbsp;&ndash; inequalities in lexicographic order, normalized and fitered copy strings
* [vlp](vlp) &nbsp;&ndash; MOLP problems and solutions associated with DFZ
  inequality numbers.


