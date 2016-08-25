Dougherty - Freiling - Zeger inequalities
=================

The inequalities from *R. Dougherty, C. 
Freiling, and K.  Zeger:* [Non-Shannon information inequalities in four
random variables](http://arxiv.org/pdf/1104.3602v1) are
listed in [main.txt](main.txt) following their original numbering from 1 to 214. 
The [Zhang-Yeung inequality](http://www.cs.cornell.edu/courses/cs783/2007fa/papers/ZYnonShannon.pdf)
has been added as inequality number 0. Inequalities are rewritten using natural
coordinates, and the reported *copy string* has been normalized by using the
perl utility [simp.pl](../utils/simp.pl).
DFZ inequalities superseded by other inequalities found in this site are 
marked by a * symbol.

#### Interpreting the MOLP solutions

The directory [vlp](vlp) contains the MOLP problems and solutions associated
with the copy strings in the DFZ list.

    # generate the vlp file for a copy string
    utils/mkvlp.pl <copy-string> vlp/NNN.vlp
    # and solve the MOLP problem
    inner vlp/NNN.vlp -o vlp/NNN.res > vlp/NNN.out

The vertices of the solution in NNN.res is just the collection of those 
10-dimensional vectors &lt; *x*<sub>2</sub>, ..., *x*<sub>11</sub>&gt; such
that the non-Shannon inequalities with coefficients

>  1, *x*<sub>2</sub>, ..., *x*<sub>11</sub>

are the minimal (not superseded) ones among all consequences yielded by the
copy string. For more information see the
[description](../copy/DESCRIPTION.md) in the [copy](../copy) section.

#### Content

* [main.txt](main.txt) &nbsp;&ndash; the list of DFZ inequalities.
* [orig.txt](orig.txt) &nbsp;&ndash; raw file of original DFZ inequalities.
* [vlp](vlp) &nbsp;&ndash; MOLP problems and solutions associated with DFZ
  inequality number.


