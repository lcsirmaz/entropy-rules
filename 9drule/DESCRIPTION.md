Entropy inequalities by &quot;Double Rules&quot;
========================================

About one half of the [rules](../rules/DESCRIPTION.md) defined in
[Dougherty et al](http://arxiv.org/pdf/1104.3602v1) generates a new entropy
inequality from *two* existing ones. Similarly to the 
[single rule](../rules/DESCRIPTION.md) description, Rule [6] from 
[Dougherty et al](http://arxiv.org/pdf/1104.3602v1) can be rewritten as the
following ruleset:

    [1, , , , , , , , , , ] + [ , , , , , , , , , , ] <= [1, ,1,1, , , , , , , ]  a
    [ , ,1, , , , , , , , ] + [ , , , , , , , , , , ] <= [ , ,1, , , , , , , , ]  c
    [ , , ,1, , , , , , , ] + [ , , , , , , , , , , ] <= [ , , ,1, , , , , , , ]  d
    [ , , , ,1, , . , ,1, ] + [ , , , , , , , , , , ] <= [ , ,1,1,1, , , , ,1, ]  h
    [ , , , . ,1, , , , , ] + [ , , , , , , , , , , ] <= [ , , , , ,1, , , , , ]  f
    [ , , , , , ,1, , , , ] + [ , , , , , , , , , , ] <= [ , , , , , ,1, , , , ]  g
    [ , , , , , , ,1, , , ] + [ , , , , , , , , , , ] <= [ , , ,1, , , ,1, , , ]  i
    [ , , , , , , , ,1, , ] + [ , , , , , , , , , , ] <= [ , ,1, , , , , ,1, , ]  j
    [ , , , , , , , , , , ] + [1, , , , , , , , , , ] <= [1, ,1,1, , , , , , , ]  a'
    [ , , , , , , . , , , ] + [ ,1, , , , , , , ,1, ] <= [ ,1,1,1, , , , , ,1, ]  h'
    [ , , , , , , , , , , ] + [ , ,1, , , , , , , , ] <= [ , ,1, , , , , , , , ]  c'
    [ , , , , , , , , , , ] + [ , , ,1, , , , , , , ] <= [ , , ,1, , , , , , , ]  d'
    [ , , , . , , , , , , ] + [ , , , , ,1, , , , , ] <= [ , , , , ,1, , , , , ]  f'
    [ , , , , , , , , , , ] + [ , , , , , ,1, , , , ] <= [ , , , , , ,1, , , , ]  g'
    [ , , , , , , , , , , ] + [ , , , , , , ,1, , , ] <= [ , , ,1, , , ,1, , , ]  i'
    [ , , , , , , , , , , ] + [ , , , , , , , ,1, , ] <= [ , ,1, , , , , ,1, , ]  j'
    [ , , , ,1, , , , , , ] + [ ,1, , , , , , , , , ] <= [1,1,1,1, , , , , , , ]  z


(For better visibility, only non-zero entries are shown.)
The meaning of such a ruleset is the following:

> If any non-negative linear combination of the left hand sides yields the
> coefficients of two valid 4-variable entropy inequality, then so does the
> same combination of the right hand side vectors.

The combining coefficients used by Dougherty and al are indicated next to
the rules.  The only rule in the above ruleset which uses both inequalities
is the last one marked by `z`. Due to its hight computational complexity,
the complete ruleset has been determined for the original
[Rule \[5\]](DFZ/05.txt), [Rule \[6\]](DFZ/06.txt), [Rule
\[8\]](DFZ/08.txt), and [Rule \[13\]](DFZ/13.txt) only. 
The complete ruleset for Rule [6] has 53 lines, out of which 17 uses both
inequalities.

### Creating a double ruleset

A double rule is specified by a *copy string* and two bases, that is, two sequences of
four (composite) random variables. For Rule [6] above the copy string is
*r*=*c*:*ab*, and the two bases are *ar, br, c, dr* and *ar, br, cr, d*.

Collect the entropies of all non-empty subsets of the random variables
occurring in the copy string and in the bases into the vector **h**. The
vectors **n**<sub>1</sub>, ..., **n**<sub>11</sub> determine the (first 11)
natural coordinates of *a, b, c, d* expressed as the inner products 
**n**<sub>1</sub>&#183;**h**, ..., **n**<sub>11</sub>&#183;**h**.
Additionally, the vectors **b1**<sub>1</sub>, ..., **b1**<sub>11</sub> and
**b2**<sub>1</sub>, ..., **b2**<sub>11</sub> determine the natural
coordinates of the first and second base, respectively, as **b1**<sub>1</sub>&#183;**h**, ...,
**b1**<sub>11</sub>&#183;**h**, 
and **b2**<sub>1</sub>&#183;**h**, ..., **b2**<sub>11</sub>&#183;**h**.
A rule line

> (1) &nbsp; &nbsp; [*x*<sub>1</sub>, ..., *x*<sub>11</sub>] +
>  [*y*<sub>1</sub>, ..., *y*<sub>11</sub>] &le; [ *z*<sub>1</sub>, ...,
> *z*<sub>11</sub> ]

is *valid* if the following inequality can be proved for all vectors **h**
satisfying the equalities imposed by the copy string and all Shannon
inequalities:

> (2) &nbsp; &nbsp; (*x*<sub>1</sub>**b1**<sub>1</sub> + ... +
>        *x*<sub>11</sub>**b1**<sub>11</sub>)&#183;**h** + <br>
>  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
>     (*y*<sub>1</sub>**b2**<sub>1</sub> + ... +
> *y*<sub>11</sub>**b2**<sub>11</sub>)&#183;**h** &le;
>    (*z*<sub>1</sub>**n**<sub>1</sub> + ... +
> *z*<sub>11</sub>**n**<sub>11</sub>)&#183;**h**.

Similarly to the case of [simple rules](../rules/DESCRIPTION.md),
non-negative linear combination of valid rule lines is a valid rule line;
and any collection of valid rule lines has the &quot;generating property&quot;
quoted above. 

A collection of (valid) rule lines is *complete* if every other valid rule line (as
determined by the copy string and bases) can be superseded by
some non-negative liner combination of these lines. The complete rule set is
unique and can be computed by solving a MOLP problem with 33 objectives. To
generate, solve, and then extract the complete ruleset use the commands

    # create MOLP for the rule specified by a copy string and two bases
    utils/rulemk.pl <copystring> <base1> <base2> <vlp-file>
    # solve the MOLP problem
    inner <vlp-file> -o <vlp-result>
    # extract the complete ruleset from the result
    utils/minrule.pl <vlp-result> <ruleset>

This procedure yielded the complete rulesets for DFZ Rules reported above.

### Scaled down rulesets 

MOLP problems with 33 objectives are typically intractable and can be solved
in very special cases only. To reduce the complexity, *scaled down* rulesets
are considered, where the last two natural coordinates &ndash; coordinates
given by **I**(c;d) and **I**(a;b | c,d) &ndash; are set to
zero. Using such a ruleset means that the method is restricted to use and
generate entropy inequalities where the last two coordinates are zero. As
presently no known 4-variable entropy inequality has any of these
coefficients non-zero, this condition doesn't seem to be overly
restrictive.

The theory and methodology of such scaled down ruleset is the same as
outlined above with the additional restriction that the values
*x*<sub>10</sub>, *x*<sub>11</sub>, *y*<sub>10</sub>, *y*<sub>11</sub> and
*z*<sub>10</sub>, *z*<sub>11</sub> in the generated rule must be zero. To
compute the complete scaled down ruleset for a copy string and two bases use
the following commands:

    # create the MOLP problem
    utils/9rulemk.pl <copystring> <base1> <base2> <vlp-file>
    # solve the MOLP problem
    inner <vlp-file> -o <vlp-result>
    # extract the complete ruleset
    utils/minrule.pl <vlp-result> <reduced-ruleset>

When applying a reduced ruleset to a set of known inequalities, inequalities
with the last two coefficients equal to zero are considered only. The
utility `9dodrule.pl` creates a MOLP problem whose solutions are the minimal
(not superseded) instances of applying the rule to the given inequalities.
It allows filtering for inequalities whose coefficients below a certain
bound. From the solution of the MOLP problem inequalities that are really
new ones can be extracted by the `checkall.pl` utility.

    # apply a reduced rule to a set of inequalities
    utils/9dodrule.pl <ineq-file> <rule-file> <vlp-file>
    # same, but filter out inequalities with coefficients above <bound>
    utils/9dodrule.pl -t <bound> <ineq-file> <rule-file> <vlp-file>
    # solve the MOLP
    inner <vlp-file> -o <vlp-resfile>
    # extract inequalities not superseded by those in <full-ineq-file>
    uitils/checkall.pl <vlp-resfile> <full-ineq-file>



