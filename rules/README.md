New entropy inequalities by rules
=================================

A *simple rule* is a (relatively simple) copy string followed by four
variables. In a *double rule* two sets of four random variables are present.

Given a rule, use `rulemk.pl` to generate the vlp file for maximal set of
inequalities. From the result `minrule.pl` extracts basic inequalities
representing that rule; the result is stored in the &lt;rulenumber&gt;.txt
file. Finally, `dorule.pl` applies a particular rule to known inequalities,
and generates a vlp file which then gives the minimal set of bootstrapped
inequalities. Check for not superseded inequalities by `checkall.pl`.

    utils/rulemk.pl <copystring> <base> rules/vlp/NN.vlp      #create vlp for rules
    inner rules/vlp/NN.vlp -o rule/vlp/NN.res                 #solve
    utils/minrule.pl rules/vlp/NN.vlp rule/NN.txt             #generate the rules
    utils/dorule.pl <ineqfile> rule/NN.txt rule/vlp/rNN.vlp   #apply the rules
    inner rules/vlp/rNN.vlp -o rule/vlp/rNN.res               #solve
    utils/checkall.pl rule/vlp/rNN.res <known-ineqs>          #check for new inequalities

#### Content

* [rules.txt](rules.txt) &nbsp;&ndash; the description of the rules
* NN.txt &nbsp;&ndash; the rules themselves
* rNN.txt &nbsp;&ndash; result of applying a rule to the most recent set
* [vlp](vlp)vlp &nbsp;&ndash; vlp files and solutions
