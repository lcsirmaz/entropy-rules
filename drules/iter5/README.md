Bootstrap method, iteration \#5
===============================

In this iteration a small set of four-variable inequalities in 
[base](base.txt) are used for some promising copy strings and base sets.

* copy string: rs=ac:bd;t=d:abr;u=d:abrt
** 01: ar,br,cr,dr
** 02: ar,br,cr,dr as,bs,cs,ds at,bt,ct,dt
** 03: ar,br,cr,dr art,brt,crt,drt
** 04: ar,br,cr,dr at,bt,ct,dt art,brt,crt,drt
** 05: ar,br,cr,dr art,brt,ct,drt art,brt,crt,dt
** 06: art,brt,crt,drt aru,bru,cru,dru
* copy string: rs=cd:ab;t=a:bcr;u=a:bcrt
** 10: ar,br,cr,dr art,brt,crt,drt
** 11: ar,br,cr,dr as,bs,cs,ds at,bt,ct,dt
** 12: ast,bst,cst,dst
* copy string: rs=cd:ab;tu=ac:bs;v=a:bdsu
** 20: ar,br,cr,dr as,bs,cs,ds at,bt,ct,dt
** 21: ar,br,cr,dr aru,bru,cru,dru atu,btu,ctu,dtu 
** 22: ar,br,cr,dr as,bs,cs,ds at,bt,ct,dt av,bv,cv,dv
* copy string: rs=cd:ab;tu=ac:bds;v=a:bdsu
** 25: ar,br,cr,dr as,bs,cs,ds at,bt,ct,dt au,bu,cu,du

#### Contents

* [base](base.txt) &nbsp;&ndash; base file of inequalities, a really small
  set where the normalized sum of coefficients is at most four
* [it5](it5.txt) &nbsp;&ndash; new inequalities generated in this iteration
* [result](result) &nbsp;&nbsp; new inequalities one by one
* [vlp](vlp) &nbsp;&ndash' MOLP problems and their solutions

