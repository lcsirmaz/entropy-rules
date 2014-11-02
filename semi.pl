#!/usr/bin/perl -W 
# trying to generate rules for semialgebraicity
# Paste string:  'r=c:ab;s=r:bcd;t=s:abcr' 
# two strings:    a,b,s,d 0001000000 
#                 a,b,t,d 0000001000
# and we try to go over all combionations of the first and the second;
# generating all possible replacements.

# handling rules
# arguments: paste ar,br,c,dr 000100010 a,b,c,r 010001000
# computes the best upper bound on that combination

## coeff 0 is the Ingleton rather than what is below

## coeffs of a rule:
##    0      1       2      3        4      5       6       7      8       9
## -(a,b) (a,b|c) (a,c|b) (b,c|a) (a,b|d) (a.d|b) (b,d|a) (c,d) (c,d|a) (c,d|b)
##  
##

use strict;

my $maxvar = 128;

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
    my @M=(); my @C=();
    for my $j(0..$rows-1){ 
        $C[$j]=$goal->[$j]; $M[$j]=();
        for my $i(0..$cols-1){ $M[$j][$i]=$Q->[$i]->{coeffs}->[$j]; }
    }
    ## add 10 more columns for the 10 RHS coeffs
    my $ocols=$cols; 
    my $e=[]; my $ncol=[]; my $zero=[];
    for my $i(0..9){
        zero_eqs($e,$maxvar); zero_eqs($zero,10); $zero->[$i]=1;
        mkgoal($info,$e,-1,$zero,"a,b,c,d");
        zero_eqs($ncol,$rows);
        for my $j(0..$maxvar-1){
            next if(!$e->[$j]);
            my $idx=$info->{vidx}[$j];
            if($idx<0){ die "preparing column $i: non-existent var ($j)\n"; }
            $ncol->[$idx] = $e->[$j];
        }
        for my $j(0..$rows-1){
            $M[$j][$cols]=$ncol->[$j];
        }
        $cols++;
    }
    my @B=(0.0) x $cols; my @BASE=(-1) x $rows;
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
    for my $i($ocols..$cols-1){$B[$i]=-1; } ## these are to be minimized
    my $V=0.0;
    for my $r(0..$rows-1){
        if($BASE[$r]==-1 ){ ## add two new dummy variables
            for my $i(0..$rows-1){
                $M[$i][$cols]=0.0; $M[$i][$cols+1]=0.0;
            }
            $BASE[$r]=$cols; $M[$r][$cols]=1.0;
            $M[$r][$cols+1]=-1.0;
            ## add some large penalty
            $B[$cols]=-4096.0; $B[$cols+1]=-4096.0;
            $cols+=2;
#            $V += 4096*$C[$r];
        }
        if($BASE[$r]>=0 ){ # correct B[]
            my $p=$B[$BASE[$r]];
            for my $j(0..$cols-1){
                $B[$j] -= $p*$M[$r][$j];
            }
            $V -= $p*$C[$r];
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
}

sub execute_simplex {
    my($info,$fname)=@_;
#    my $Q=$info->{ineq};
    my $ocols=scalar @{$info->{ineq}};
    system("/home/matus/progs/mspx","/tmp/$fname.lp","/tmp/$fname.lp.base","/tmp/$fname.base","/tmp/$fname.newbase");
    my ($res1,$res2)=("","");
    if(open(FILE,"/tmp/$fname.base")){
        $res1=<FILE>; $res2=<FILE>; close(FILE);
        chomp $res1; chomp $res2;
    }
    unlink("/tmp/$fname.base","/tmp/$fname.lp.base","/tmp/$fname.newbase");
#    print "LP result: $res1\n";
    print ".";
    if($res1 !~ /V=(.*)$/ ){
       die "LP terminated wrongly\n";
    }
    my $V=$1; if($V =~ /^(\d+)\/(\d+)$/ ){$V=(0.0+$1)/(0.0+$2); } else {$V=0.0+$V; }
    if($V>1000){
##        print "No solution\n"; return;
         return "";
    }
    my $e=[]; zero_eqs($e,10);
    foreach(split(',',$res2)){
        next if(!m/^(\d+):(.+)$/ );
        my ($idx,$v)=($1,$2);
        next if($idx<$ocols);
        $e->[$idx-$ocols]=$v;
#        if(!defined($Q->[$idx])){
#             print "($idx:$v), $idx not defined\n";
#             next;
#        }
#        print "+$v*(",$Q->[$idx]->{desc},")";
#        if($v =~ /^(\d+)\/(\d+)$/ ){$v=(0.0+$1)/(0.0+$2); } else {$v=0.0+$v; }
#        foreach my $jj(0..$rows-1){
#            $e->[$jj] += $v*$Q->[$idx]->{coeffs}->[$jj];
#        }
    }
    my $res=$e->[0]; for my $i(1..9){ $res .= ",".$e->[$i]; }
    return $res;
##    print "result: "; for my $i(0..9){ print $e->[$i],","; }
##    print "\n";
##    print "RHS: "; for my $i(0..9){
##         next if(!$e->[$i]); print "($i,",$e->[$i],")";
##    }
#    print "\n got: "; for my $i(0..$rows){
#         next if(!$e->[$i]); print "($i,",$e->[$i],")";
#    }
#    print "\n";
#    exit 27;
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
my $info = make_paste("r=c:ab;s=r:bcd;t=s:abcr"); # this is the paste string
generate_shannon($info);
my $e; my $goal;

# go over all 1's 
for my $ii(0..6){for my $jj(0..6){
   print "\n--------------------\n";
   $e=[]; zero_eqs($e,$maxvar);
   my @m=(0,0,0,0,0,0,0,0,0,0); $m[$ii]=1;
   mkgoal($info,$e,-1,\@m,"a,b,s,d"); # first string
   print "",join('',@m),";  ";
   $m[$ii]=0; $m[$jj]=1;
   mkgoal($info,$e,-1,\@m,"a,b,t,d"); # second string
   print "",join('',@m),":  ";
   $goal=[]; zero_eqs($goal,$info->{rows});
   for my $i(0..$maxvar-1){
       next if(!$e->[$i]);
       my $idx=$info->{vidx}[$i];
       if($idx<0){ die "preparing goal: non-existent var ($i)\n"; }
       $goal->[$idx] = $e->[$i];
   }
   generate_simplex($info,"semi",$goal);
   my %result=();
   for(1..20){
       sleep 1;
       my $res=execute_simplex($info,"semi");
       next if(!$res);
       $result{$res}=1;
   }
   print "\n";
   foreach my $key(keys %result){
       print "   $key\n";
   }
}}

__END__

if(scalar @ARGV<3){ 
     print "args: <paste> <first base> <first goal> <2nd base> <2nd goal> ...\n
     base: four variable (ax,bx,cx,d)\n
     goal: string of ten 0/1\n"; 
     exit 0;
}

my $info=make_paste($ARGV[0]); # give error message if it is wrong
generate_shannon($info);
my $e=[]; zero_eqs($e,$maxvar);
my $argc=1; while($argc<scalar @ARGV){
    if($ARGV[$argc] !~ /^[a-z]+,[a-z]+,[a-z]+,[a-z]+$/ ){
         die "arg $argc is of wrong format ($ARGV[$argc]\n";
    }
    if($ARGV[$argc+1] !~ /^\d{10}$/ ){
         die "arg ".($argc+1)." is of wrong format (".$ARGV[$argc+1].")\n";
    }
    my @m=split('',$ARGV[$argc+1]);
    mkgoal($info,$e,-1,\@m,$ARGV[$argc]);
    $argc+=2;
}

print "args are read, ($argc)\n";
my $goal=[]; zero_eqs($goal,$info->{rows});
for my $i(0..$maxvar-1){
    next if(!$e->[$i]);
    my $idx=$info->{vidx}[$i];
    if($idx<0){ die "preparing goal: non-existent var ($i)\n"; }
    $goal->[$idx] = $e->[$i];
}

generate_simplex($info,"best",$goal);
for(1..10){ execute_simplex($info,"best");sleep 1;}
