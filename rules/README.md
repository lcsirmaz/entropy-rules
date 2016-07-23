New entropy inequalities by rules
=================================

A *simple rule* is a (relatively simple) copy string followed by four
variables. In a *double rule* two sets of four random variables are present, and
their sum is taken.

Given a rule, use `rulemk.pl` to generate the vlp file for maximal set of
inequalities. From the result `minrule.pl` extracts basic inequalities
representing that rule; the result is stored in the `ineq/NN.txt` file.

    utils/rulemk.pl <copystring> <base> rules/vlp/NN.vlp       #create MOLP for a rule
    inner rules/vlp/NN.vlp -o rule/vlp/NN.res                  #solve
    utils/minrule.pl rules/vlp/NN.vlp rules/ineq/NN.txt        #generate the rule file

The top line of a *rule file* describes what the rule was generated from.
Other lines show two vectors of 11 coefficients separated by a `<=` sign:

    c Maximal rule for r=a:bc;s=r:ab; s,b,c,d
    [0,0,0,0,0,1,0,0,0,0,1] <= [0,3,1,2,0,0,1,0,0,0,0]
    [0,0,1,0,0,1,0,0,1,0,1] <= [0,2,1,3,1,0,0,0,0,1,0]
    [0,0,1,0,0,1,0,0,1,0,1] <= [0,2,1,3,1,0,0,1,0,0,0]
    [0,0,2,0,0,2,0,0,1,0,2] <= [1,5,2,4,1,0,0,0,0,1,0]
    [0,1,0,0,0,0,0,0,0,0,0] <= [0,2,0,1,0,0,0,0,0,0,0]
    [1,0,0,0,0,0,0,0,0,0,0] <= [0,1,1,1,1,0,0,1,0,0,0]
    [1,0,0,0,0,0,0,0,0,0,0] <= [0,2,0,1,0,1,0,1,0,0,0]
    [1,0,1,0,0,0,0,0,0,0,0] <= [0,2,1,1,0,0,0,1,0,1,0]

The described rule can be phrased as follows. **If** any non-negative linear 
combination of the left hand sides gives the coeffiecients of a valied entropy
inequality, **then** so does the right hand side with the same combining values.

The utility `dorule.pl` applies a particular rule to a set of known inequalities
by generating a vlp file whose solution gives the minimal set of bootstrapped
inequalities. The procedure can be iterated using the new set of inequalities.

    utils/dorule.pl <ineqfile> <rule> <vlpfile>      #apply the rule and generate vlp 
    inner <vlpfile> -o <solution>                    #solve
    utils/downgrade.pl <solution> <known-ineqs>      #check for new inequalities

#### Content

* [rules.txt](rules.txt) &nbsp;&ndash; description of rules
* [ineq](ineq) &nbsp;&ndash; the rule files
* [vlp](vlp) &nbsp;&ndash; rule vlp files and solutions for the rules
* [iter1](iter1) &nbsp;&ndash; first iteration appliead to the set of inequalities in [iter1/ineq.dw2](iter1/ineq.dw2)
* [iter2](iter2) &nbsp;&ndash; second iteration
