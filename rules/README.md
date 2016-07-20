New entropy inequalities by rules
=================================

A *simple rule* is a (relatively simple) copy string followed by four
variables. In a *double rule* two sets of four random variables are present.

Given a rule, use `rulemk.pl` to generate the vlp file for maximal set of
inequalities. From the result `minrule.pl` extracts basic inequalities
representing that rule; the result is stored in the NN.txt file.

    utils/rulemk.pl <copystring> <base> rules/vlp/NN.vlp      #create MOLP for a rule
    inner rules/vlp/NN.vlp -o rule/vlp/NN.res                 #solve
    utils/minrule.pl rules/vlp/NN.vlp rule/ineq/NN.txt        #generate the rule file

The utility `dorule.pl` applies a particular rule to a set of known inequalities.
It generates a vlp file whose solution gives the minimal set of bootstrapped
inequalities. The procedure can be iterated using the new set of inequalities.

    utils/dorule.pl <ineqfile> <rule> <vlpfile>      #apply the rule
    inner <vlpfile> -o <solution>                    #solve
    utils/downgrade.pl <solution> <known-ineqs>       #check for new inequalities

#### Content

* [rules.txt](rules.txt) &nbsp;&ndash; description of rules
* [ineq](ineq) &nbsp;&ndash; the rules themselves
* [vlp](vlp) &nbsp;&ndash; vlp files and solutions for the rules
* [result](result) &nbsp;&ndash; results of first iteration
