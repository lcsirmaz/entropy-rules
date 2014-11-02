#!/usr/bin/perl -W -I /home/matus/perl_lib
# handling rules

## coeffs of a rule:
##    0      1       2      3        4      5       6       7      8       9
## -(a,b) (a,b|c) (a,c|b) (b,c|a) (a,b|d) (a.d|b) (b,d|a) (c,d) (c,d|a) (c,d|b)
##

use strict;

my $maxvar = 64;

###############################################################
sub cv { #convert a substring of "abcdrstuvw" to a number 0--1023
    my $v=shift;
    my $r=0;
    $r+=1 if($v=~/a/);
    $r+=2 if($v=~/b/);
    $r+=4 if($v=~/c/);
    $r+=8 if($v=~/d/);
    $r+=16 if($v=~/r/);
    $r+=32 if($v=~/s/);
    $r+=64 if($v=~/t/);
    return $r;
}

sub name { # number --> abcdrstuvw
    my $s=shift || 0;
    my $v="";
    $v .= "a" if($s&1);
    $v .= "b" if($s&2);
    $v .= "c" if($s&4);
    $v .= "d" if($s&8);
    $v .= "r" if($s&16);
    $v .= "s" if($s&32);
    $v .= "t" if($s&64);
    return $v;
}

sub zero_eqs {
    my($e,$len)=@_;
    if(!$len){ $len = scalar @$e; }
    for my $i(0..$len-1){ $e->[$i]=0; }
}

sub paste { # rst = (ab)cd : uv
    my($info,$dsc)=@_;
    if(! defined $info->{vars} ){$info->{vars} = 0xf; } # abcd
    if(! defined $info->{trans} ){$info->{trans} = (); }
    if(! defined $info->{paste} ){$info->{paste} = (); }
    if($dsc !~ /^\s*([rst]+)=([[abcdrst\(\)]+):([abcdrst]*)\s*$/ ){
        return "paste: wrong syntax ($dsc)";
    }
    my ($new,$old,$X,$vars)=($1,$2,cv($3),$info->{vars});
    my $Z=$vars; # this is the set of NOT copied variables
    if(cv($new) & $vars){
        return "paste: new variable in \"$new\" already defined ($dsc)";
    }
    if(($X&$vars)!=$X){
        return "paste: over variable in \"".name($X)."\" not defined ($dsc)";
    }
    push @{$info->{paste}},{ new => $new, over => $vars, by => "$old:".name($X) };
    my @defs=(); # $defs[]={v=> 32, r=>"16|1"};
    my $newvars=0;
    while($new){
        $new =~ s/^(.)//; my $v=cv($1);
        if($v==0 || ($v&$newvars)){
            return "paste: new variable is doubly defined ($dsc)";
        }
        $newvars |= $v;
        my $r=0;
        if( $old =~ s/^([abcdrst])// ){
            $r=cv($1);
        } elsif( $old =~ s/^\(([abcdrst]+)\)// ){
            $r=cv($1);
        } else {
           return "paste: syntax of copy variable ($dsc)";
        }
        if(($r&$vars)!=$r){
            return "paste: copy variable in \"".name($r). "\"not defined ($dsc)";
        }
        if($r&$X){
            return "paste: copy variable \"".name($r)."\" and over variables overlap ($dsc)";
        }
        $Z = $Z & ~$r; # erase copied variable(s)
        push @defs, {v=>$v, r=> $r };
    }
    if($old){
        return "paste: extra copy variable \"$old\" ($dsc)";
    }
    $info->{vars} |= $newvars;
    ## we have: I(A,B|X)=0 where A
    ##
    my $NN=scalar @defs; my $Y= $vars & ~$X;
    for my $A (1..((1<<$NN)-1)){
        my ($i,$v,$r,$vv,$rr)=(1,0,0,0,0);
        for my $d(@defs){
           if($A&$i){
               $v |= $d->{v}; $r |= $d->{r};
           }
           $i<<=1;
        }
        for my $AA (0..$A-1){
           ($i,$vv,$rr)=(1,$r,$v);
           for my $d(@defs){
                if($AA&$i){
                    $vv |= $d->{v}; $rr |= $d->{r};
                }
                $i<<=1;
           }
           if($vv<$rr){ my $t=$vv; $vv=$rr; $rr=$t; }
           for my $B(0..$X){
              next if(($B & ~$X) || ($vv|$B)==($rr|$B) ); ## $B is not a subset of $X
              $info->{trans}[$vv|$B] = { $rr|$B => 1 };
           }
        }
        for my $B(1..$Y){
            next if($B & ~$Y); ## $B is not a subset of $Y
            $info->{trans}[$v|$B|$X] =
              {$X=>-1, $v|$X =>1, $B|$X =>1 };
        }
    }
    return "";
}

sub make_paste {
    my($paste)=@_;
    $paste="" if(!defined $paste);
    $paste =~ s/\s//g;
    my $info={pastestr=>$paste }; my $err=""; my $nopaste=1;
    foreach (split(';',$paste)){
        next if( /^$/ || $err );
        $nopaste=0;
        $err=paste($info,$_);
        if($err){ die "paste: $err\n"; }
    }
    if($nopaste){ die "paste: missing paste string\n"; }
    return $info;
}

sub add_eqs {
    my($info,$e,$var,$d)=@_;
    return if($var==0);
    my $idx = $info->{trans}[$var];
    if(defined $idx){
        foreach my $sss (keys %$idx ){
            add_eqs($info,$e,$sss,$d*$idx->{$sss});
        }
        return;
    }
    $e->[$var] += $d;
}

sub _collapse_vars {
    my($info)=@_;
    $info->{vidx}=();
    my $tr=$info->{trans}; my $vars=$info->{vars};
    $info->{vidx}[0]=-1; # no actual variable with index zero
    my $j=0; for my $i(1..$maxvar-1){
        if(($i&$vars)==$i && !defined $tr->[$i]){
           $info->{vidx}[$i]=$j; $j++;
        } else {
           $info->{vidx}[$i]=-1;
        }
    }
    $info->{rows}=$j;  # that many actual variables are there
}

sub _hash_ineq {
    my $e=shift; my $hash="";
    for my $v (@$e){
         $hash .= ",".($v||"");
    }
    $hash;
}

sub _store_ineq {
    my($info,$e,$desc)=@_;
    my $cf=[]; zero_eqs($cf,$info->{rows});
    for my $i(0..-1+scalar@$e){
        next if(!$e->[$i]);
        my $idx=$info->{vidx}[$i];
        if($idx<0){ die "store_ineq: non-existent var ($i)\n"; }
        $cf->[$idx] = $e->[$i];
    }
    push @{$info->{ineq}}, { coeffs => $cf, desc => $desc };
}

sub generate_shannon { # generate all Shannon inequalities
    my ($info) = @_;
    _collapse_vars($info); # fill out $info->{vidx}
    $info->{ineq}=[]; $info->{hash}={};
    my $vars = $info->{vars};
    my $eqs=[]; # don't store the same ineq twice
    zero_eqs($eqs,$maxvar); $info->{hash}->{_hash_ineq($eqs)}="empty";
    for my $A (0..$maxvar-1){
         next if( ($A&$vars)!=$A );
         for (my $i=1; $i<$maxvar; $i<<= 1 ){
             my $Ai=$A|$i;
             next if(($i&$vars)==0 || $A==$Ai );
             for (my $j=$i; $j<$maxvar; $j <<= 1 ){
                 my $Aj=$A|$j;
                 next if(($j&$vars)==0 || $j==$i || $A==$Aj);
                 zero_eqs($eqs,$maxvar);
                 add_eqs($info,$eqs,$Ai,1); add_eqs($info,$eqs,$Aj,1);
                 add_eqs($info,$eqs,$A,-1); add_eqs($info,$eqs,$Ai|$j,-1);
                 my $h=_hash_ineq($eqs);
                 next if(defined $info->{hash}->{$h}); 
                 $info->{hash}->{$h}= name($i).",".name($j)."|".name($A);
                 _store_ineq($info,$eqs,$info->{hash}->{$h});
             }
         }
    }
#    print "Shannon generated, items = ",scalar @{$info->{ineq}},
#    ", vars=",scalar @{$info->{ineq}->[0]->{coeffs}},
#    ", rows=$info->{rows}","\n";
}

################################################################
##   make the LP program
##

sub generate_simplex {
    my($info,$fname,$goal)=@_;
    my $Q=$info->{ineq};
    my $rows=$info->{rows}; ## scalar @{$Q->[0]->{coeffs}}
    my $cols=scalar @$Q;
    if( scalar @$goal != $rows ){
         die "size of goal != number of rows ($rows)\n";
    }
    my @B=(0.0) x $cols; my @BASE=(-1) x $rows;
    my @M=(); my @C=();
    for my $j(0..$rows-1){ 
        $C[$j]=$goal->[$j]; $M[$j]=();
        for my $i(0..$cols-1){ $M[$j][$i]=$Q->[$i]->{coeffs}->[$j]; }
    }
    ## get a random permutation of the columns
    my @perm=(); for my $i(0..$cols-1){$perm[$i]=$i; }
    for my $i(0..$cols-2){
       my $j=$i+int(rand($cols-$i)); my $t=$perm[$i];
       $perm[$i]=$perm[$j];$perm[$j]=$t;
    }
    for my $r(0..$rows-1){ # change negative goals to positive
         next if($C[$r] > -1e-10); # positive
         for my $c(0..$cols-1){ $M[$r][$c]=-$M[$r][$c]; }
         $C[$r]=-$C[$r];
    }
    for my $r(0..$rows-1){ # zero goals
         next if($C[$r]>1e-10);
         $C[$r]=0;
         my($found,$c,$qmax,$qmin,$maxc,$minc,$v)=(-1,-1,0.0,0.0,-1,-1,0.0);
         for my $idx(0..$cols-1){
            $c=$perm[$idx];
            $v=$M[$r][$c];
            if( $v>1.0-1e-9 && $v<1.0+1e-9){ ## +1
                 $found=1; last;
            }
            if($v<-1.0+1e-9 && $v>-1.0-1e-9){## -1 coeff
                 for my $j(0..$cols-1){ $M[$r][$j]=-$M[$r][$j]; }
                 $found=1; last;
            }
            if($v<$qmin){$minc=$c; $qmin=$v; }
            if($v>$qmax){$maxc=$c; $qmax=$v; }
         }
         if($found<0){ ## no +1 coeff
            if($qmin>-1e-9 && $qmax<1e-9){ ## all zero row
                $BASE[$r]=-2; next;
            }
            $c=$maxc;
            if($qmax+$qmin<0 ){
                for my $j(0..$cols-1){ $M[$r][$j]= -$M[$r][$j]; }
                $c=$minc;
            }
            $v=1.0/$M[$r][$c];
            for my $j(0..$cols-1){ $M[$r][$j] *= $v; }
         }
         # normalized
         $M[$r][$c]=1.0;
         for my $i(0..$rows-1){
             next if($i==$r);
             my $p=$M[$i][$c];
             if($p>1e-9 || $p<-1e-9){
                for my $j(0..$cols-1){ $M[$i][$j] -= $p*$M[$r][$j]; }
             }
             $M[$i][$c]=0.0;
         }
         $BASE[$r]=$c;
    }
    # next find the base for rows where $C[$r]>0
    for my $r(0..$rows-1){
        next if($BASE[$r]!=-1);
        my($found,$c,$OK,$p,$v)=(-1,-1,-1,0.0,0.0);
        for my $idx(0..$cols-1){
            $c=$perm[$idx]; $v=$M[$r][$c];
            next if($v<1e-9); # should be positive
            $OK=1;
            for my $i(0..$rows-1){
               next if($i==$r);
               $p=$M[$i][$c];
               next if($p<1e-9);
               next if($C[$i]*$v - $C[$r]*$p >= 1e-9);
               $OK=0; last;
            }
            next if(!$OK); # wrong column
            $found=1; last;
        }
        if($found>0){ ## $c, $v=$M[$r][$c]
            $BASE[$r]=$c;
            $v=1.0/$M[$r][$c];
            for my $j(0..$cols-1){ $M[$r][$j] *= $v; }
            $C[$r] *= $v;
            $M[$r][$c]=1.0;
            for my $i(0..$rows-1){
                 next if($i==$r);
                 my $p=$M[$i][$c];
                 if($p<1e-9 && $p>-1e-9){
                      $M[$i][$c]=0.0; next;
                 }
                 for my $j(0..$cols-1){$M[$i][$j] -= $p*$M[$r][$j]; }
                 $M[$i][$c]=0.0;
                 $C[$i] -= $p*$C[$r];
                 if($C[$i]<1e-9){
                     if($C[$i]<-1e-9){ die "C at row $i is negative...\n"; }
                     $C[$i]=0.0;
                 }
            }
        }
    }
    # now check how many columns are left out
    my $V=0.0;
    for my $r(0..$rows-1){
        if($BASE[$r]==-1 ){ ## add two new dummy variables
            for my $i(0..$rows-1){
                $M[$i][$cols]=0.0; $M[$i][$cols+1]=0.0;
            }
            $BASE[$r]=$cols; $M[$r][$cols]=1.0;
            $M[$r][$cols+1]=-1.0;
            $B[$cols]=-1.0; $B[$cols+1]=-1.0;
            $cols+=2;
            $V += $C[$r];
        }
        if($BASE[$r]>=0 ){ # correct B[]
            my $p=$B[$BASE[$r]];
            for my $j(0..$cols-1){
                $B[$j] -= $p*$M[$r][$j];
            }
        }
    }
    # calculate the remaining rows
    my $db=0;
    for my $r(0..$rows-1){
        $db++ if($BASE[$r]>=0);
    }
    open(SPX, ">/tmp/$fname.lp") || die "Cannot create /tmp/$fname\n";
      print SPX $cols,"\n",$db,"\n",$V,"\n";
      for my $r(0..$rows-1){
         next if($BASE[$r]<0);
         for my $c(0..$cols-1){
             print SPX $M[$r][$c],"\n";
         }
      }
      for my $r(0..$rows-1){
          next if($BASE[$r]<0);
          print SPX $C[$r],"\n";
      }
      for my $c(0..$cols-1){
          print SPX $B[$c],"\n";
      }
      for my $r(0..$rows-1){
          next if($BASE[$r]<0);
          print SPX $BASE[$r],"\n";
      }
    close(SPX);
    system("/home/matus/progs/mspx","/tmp/$fname.lp","/tmp/$fname.lp.base","/tmp/$fname.base","/tmp/$fname.newbase");
    my ($res1,$res2)=("","");
    if(open(FILE,"/tmp/$fname.base")){
        $res1=<FILE>; $res2=<FILE>; close(FILE);
        chomp $res1; chomp $res2;
    }
    unlink("/tmp/$fname.lp","/tmp/$fname.base","/tmp/$fname.newbase");
    if($res1 =~ /V=0$/ ){
        return;
    }
    print "\nNext inequality is NOT true; LP result: $res1\n";
#    my $e=[]; zero_eqs($e,$rows);
#    foreach(split(',',$res2)){
#        next if(!m/^(\d+):(.+)$/ );
#        my ($idx,$v)=($1,$2);
#        if(!defined($Q->[$idx])){
#             print "($idx:$v), $idx not defined\n";
#             next;
#        }
#        print "+$v*(",$Q->[$idx]->{desc},")";
#        if($v =~ /^(\d+)\/(\d+)$/ ){$v=(0.0+$1)/(0.0+$2); } else {$v=0.0+$v; }
#        foreach my $jj(0..$rows-1){
#            $e->[$jj] += $v*$Q->[$idx]->{coeffs}->[$jj];
#        }
#    }
#    print "\n";
#    print "goal: "; for my $i(0..$rows){
#         next if(!$goal->[$i]); print "($i,",$goal->[$i],")";
#    }
#    print "\n got: "; for my $i(0..$rows){
#         next if(!$e->[$i]); print "($i,",$e->[$i],")";
#    }
#    print "\n";
#    exit 27;
}

########################################################################
my @ocords = qw( a  b  c  d  ab ac ad bc bd cd  abc abd acd bcd abcd );

## Matus coordinates, [] <= ingleton
my $macoord = [
["[]",            -1,-1, 0, 0,  1, 1, 1, 1, 1,-1,  -1, -1,  0,  0,  0  ],
["(a,b|c)",        0, 0,-1, 0,  0, 1, 0, 1, 0, 0,  -1,  0,  0,  0,  0  ],
["(a,c|b)",        0,-1, 0, 0,  1, 0, 0, 1, 0, 0,  -1,  0,  0,  0,  0  ],
["(b,c|a)",       -1, 0, 0, 0,  1, 1, 0, 0, 0, 0,  -1,  0,  0,  0,  0  ],
["(a,b|d)",        0, 0, 0,-1,  0, 0, 1, 0, 1, 0,   0, -1,  0,  0,  0  ],
["(a,d|b)",        0,-1, 0, 0,  1, 0, 0, 0, 1, 0,   0, -1,  0,  0,  0  ],
["(b,d|a)",       -1, 0, 0, 0,  1, 0, 1, 0, 0, 0,   0, -1,  0,  0,  0  ],
#
["(c,d)",          0, 0, 1, 1,  0, 0, 0, 0, 0,-1,   0,  0,  0,  0,  0  ],
["(c,d|a)",       -1, 0, 0, 0,  0, 1, 1, 0, 0, 0,   0,  0, -1,  0,  0  ],
["(c,d|b)",        0,-1, 0, 0,  0, 0, 0, 1, 1, 0,   0,  0,  0, -1,  0  ] ];
#

sub mkgoal {
    my ($info,$e,$sign,$m,$str)=@_;
    if(!$str){ return $e; }
    my @vars=split(',',$str);
    for my $i(0..3){
       my $t=cv($vars[$i]);
       if(!$t){ die "var string [$str] is wrong\n"; }
       $vars[$i]=$t;
    }
    for my $i(0..9){
        my $v=$m->[$i];
        next if(!$v); # nothing to do
        $v *= $sign;
        my $idx=0;
        foreach my $l(@ocords){
           $idx++; my $vv=0;
           if($l =~ /a/ ){ $vv |= $vars[0]; }
           if($l =~ /b/ ){ $vv |= $vars[1]; }
           if($l =~ /c/ ){ $vv |= $vars[2]; }
           if($l =~ /d/ ){ $vv |= $vars[3]; }
           add_eqs($info,$e,$vv,$v*$macoord->[$i]->[$idx]);
        }
    }
}

sub check_inequality {
    my($info,$rule,$label,$m1,$m2,$m3)=@_;
    my $e=[]; zero_eqs($e,$maxvar);
    mkgoal($info,$e,-1,$m1,$rule->[5]);
    mkgoal($info,$e,-1,$m2,$rule->[6]);
    mkgoal($info,$e, 1,$m3,"a,b,c,d");
## we want to show $e[] >= 0 is ## a consequence of Shannon 
## inequalities collected so far in $info->{ineq} .
## 
    my $hash = $info->{hash}->{_hash_ineq($e)};
    if (defined $hash ){
#        print "checked: ... ($hash)\n";
         return;
    }
## so it is not a simple (x,y|z)>=0. Prepare the LP
## First, make it to use the same variables as the inequalities
##
    my $goal=[]; zero_eqs($goal,$info->{rows});
    for my $i(0..$maxvar-1){
         next if(!$e->[$i]);
         my $idx=$info->{vidx}[$i];
         if($idx<0){ die "preparing goal, non-existent var ($i)\n"; }
         $goal->[$idx] = $e->[$i];
    }
    generate_simplex($info,"rule".$rule->[0].$label,$goal);
#    print "goal: ";
#    for my $i(0..-1+scalar@$e){ next if(!$e->[$i]);
#       my $ei=$e->[$i]; if($ei<0){print "-"; $ei=-$ei; } else {print "+";}
#       if($ei!=1){print $ei; } print name($i); } print "\n";
}


# I am interested in the following pattern (and its permuted versions);
##
##  A  A  0  0  A  0  0  A  0  0      Ingleton

## [0]--[9] is a linear combination

## a linear form is stored as a hash of  { "var" -> value }

sub make_form_from {
    my $str=shift; # the string "-a+b+3c"
    my %form=();
    if($str eq "0"){ return \%form; } # empty 
    my $v=$str; my $coeff=1; my $sign=1; my $tag;
    $v =~ s/\s//g; # no spaces
    while($v){
        if($v =~ s/^\+//){ next; } # jump over + sign
        if( $v=~ s/^\-//){ $sign=-1; next; }
        if($v =~ s/^(\d+(\.\d+)?)//){ $coeff=$1; next; } # digits
        if($v=~ s/^([a-zA-Z][a-zA-Z0-9]*)//){
            $tag=$1; if(!$form{$tag}){$form{$tag}=0; }
            $form{$tag}+=$sign*$coeff;
            $sign=1; $coeff=1;
            next;
        }
        die "Syntax error in formula [$str]\n remaining part: [$v]\n";
    }
    return \%form;
}

sub split_rule_string {
    my $str=shift;
    my $rule=[]; my $i=0;
    for my $part(split(',',$str)){
        $rule->[$i]=make_form_from($part); $i++;
    }
    if($i!=10){ die "rule has not enough parts (only $i):\n[$str]\n"; }
    return $rule;
}

sub frac {
    my $v=shift;
    my $sign=""; if($v<-1e-9){ $sign="-"; $v=-$v; }
    elsif($v<1e-9){ return "0";}
    my $vi=int($v+0.5);
    if($v<$vi+1e-9 && $v>$vi-1e-9){
         if($vi==1){ return $sign ? "-1" : ""; }
         return "$sign$vi*";
    }
    for my $i(2..100){
        my $vv=$v*$i;
        my $vi=int($vv+0.5);
        if($vv<$vi+1e-9 && $vv>$vi-1e-9){
            return "$sign$vi/$i*";
        }
    }
    for my $i(101..1000){
        my $vv=$v*$i;
        my $vi=int($vv+0.5);
        if($vv<$vi+1e-7 && $vv>$vi-1e-7){
            return "$sign$vi/$i*";
        }
    }
    return "$sign$v*";
}

###############################################################

sub find_vars {
     my($vars,$form)=@_;
     foreach my $r(@$form){
         foreach my $var(keys %$r){
             $vars->{$var}=1;
         }
     }
}

sub coeffs_with_var {
    my($r,$v)=@_;
    my @arr=(); my $nonzero=0;
    for my $i(0..9){
       my $h=$r->[$i]->{$v};
       if($h){ push @arr, $h; $nonzero=1; }
       else { push @arr," "; }
    }
    if($nonzero){ return "[".join(',',@arr)."]"; }
    return " ".join(' ',@arr)." ";
}

sub printrow {
    my $row=shift;
    my $nonzero=0;
    my @arr;
    foreach my $z (@$row){ $nonzero=1 if($z); push @arr, $z?$z : " ";}
    if($nonzero){ return "[",join(',',@arr)."]"; }
    return " ".join(' ',@arr)." ";
    
}

sub rule_by_vars {
    my ($rule,$label)=@_;
    my $allvars={};
    print "$label:\n";
    my $r1=split_rule_string($rule->[0]);
    my $r2=[]; if($rule->[1]){$r2=split_rule_string($rule->[1]); }
    my $r3=split_rule_string($rule->[2]);
    find_vars($allvars,$r1); find_vars($allvars,$r2); find_vars($allvars,$r3);
#    print "vars found: ",join(',',sort keys %$allvars),"\n";
    foreach my $v(sort keys %$allvars){
        ## this var is uninterensting, if in $r3->[8,9]!=0; and
        ## eithre in $r1 or in $r2 the same index in nonzero as well
        printf "%3s: ",$v;
        print coeffs_with_var($r1,$v);
        if($rule->[1]){
           print " + ";
           print coeffs_with_var($r2,$v);
        }
        print " <= ";
        print coeffs_with_var($r3,$v);
        print "\n";
    }
}

## given a rule, we create three (two) matrices, with 10 columns each
## such that for each row there is a single var determining that row
sub rule_to_matrix {
    my($rule)=@_;
    my $allvars={};
    my $r1=split_rule_string($rule->[1]);
    my $r2=[]; 
    if($rule->[2]){$r2=split_rule_string($rule->[2]); }
    else {
        for my $i(0..9){$r2->[$i]={}; } # empty string
    }
    my $r3=split_rule_string($rule->[3]);
    find_vars($allvars,$r1); find_vars($allvars,$r2); find_vars($allvars,$r3);
#    print "vars found: ",join(',',sort keys %$allvars),"\n";
    my(@m1,@m2,@m3); my @sortedv;
    foreach my $v(sort { length($a)<=>length($b) || $a cmp $b }keys %$allvars){
        push @sortedv, $v;
        my ($w1,$w2,$w3)=([],[],[]); # the rows
        for my $i(0..9){
             $w1->[$i]=$r1->[$i]->{$v}||0;
             $w2->[$i]=$r2->[$i]->{$v}||0;
             $w3->[$i]=$r3->[$i]->{$v}||0;
        }
        #$w3->[0]= ingleton (subtract form cols 1, 4, 7
        my $v;
        $v=$w1->[0]; $w1->[1]-=$v; $w1->[4]-=$v; $w1->[7]-=$v;
        $v=$w2->[0]; $w2->[1]-=$v; $w2->[4]-=$v; $w2->[7]-=$v;
        $v=$w3->[0]; $w3->[1]-=$v; $w3->[4]-=$v; $w3->[7]-=$v;
        push @m1, $w1; push @m2, $w2; push @m3, $w3;
    }
    my $idx=0; # go over all rows, if negative and there is a single
    # row with this value >0, add that line to make it zero
    foreach (keys %$allvars){
#        next;
        # is a negative value in m1
        for my $i(1..9){
            next if($m1[$idx]->[$i]>=0);
            my $pivot=-$m1[$idx]->[$i]; my $f=-1; my $idx2=-1;
            foreach (keys %$allvars){
                $idx2++;
                next if($idx==$idx2);
                next if($m1[$idx2]->[$i]<=0);
                if($f==-1){$f=$idx2; next; }
                $f=-2; last;
            }
            if($f>=0){
               $pivot = $m1[$f]->[$i]/$pivot;
               for my $j(0..9){
                   $m1[$idx]->[$j] += $m1[$f]->[$j]*$pivot;
                   $m2[$idx]->[$j] += $m2[$f]->[$j]*$pivot;
                   $m3[$idx]->[$j] += $m3[$f]->[$j]*$pivot;
               }
            }
        }
        for my $i(1..9){
            next if($m2[$idx]->[$i]>=0);
            my $pivot=-$m2[$idx]->[$i]; my $f=-1; my $idx2=-1;
            foreach (keys %$allvars){
                $idx2++;
                next if($idx==$idx2);
                next if($m2[$idx2]->[$i]<=0);
                if($f==-1){$f=$idx2; next; }
                $f=-2; last;
            }
            if($f>=0){
               $pivot = $m2[$f]->[$i]/$pivot;
               for my $j(0..9){
                   $m1[$idx]->[$j] += $m1[$f]->[$j]*$pivot;
                   $m2[$idx]->[$j] += $m2[$f]->[$j]*$pivot;
                   $m3[$idx]->[$j] += $m3[$f]->[$j]*$pivot;
               }
            }
        }
        $idx++;
    }
    # now we have m1,m2,m3.
    my $info=make_paste($rule->[4]); generate_shannon($info);
    $idx=0;
    foreach my $v(@sortedv){
        check_inequality($info,$rule,$v,$m1[$idx],$m2[$idx],$m3[$idx]);
        printf "%3s: ",$v;
        print printrow($m1[$idx]), " + ", printrow($m2[$idx]),
        " <= ", printrow($m3[$idx]), "\n";
        $idx++;
    }
}

###############################################################

do "rulelist.pm";

my $rulelist=rules();

foreach my $r (@$rulelist){
    print "-------------------\n";
    print "$r->[0] ($r->[4], $r->[5], $r->[6])\n";
    rule_to_matrix($r);
#    exit 20;
}

