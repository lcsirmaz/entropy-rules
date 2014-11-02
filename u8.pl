#!/usr/bin/perl -W 
# handling rules
# arguments: paste ar,br,c,dr 000100010 a,b,c,r 010001000
# computes the best upper bound on that combination

## coeff 0 is the Ingleton rather than what is below

## coeffs of a rule:
##    0      1       2      3        4      5       6       7      8       9
## -(a,b) (a,b|c) (a,c|b) (b,c|a) (a,b|d) (a.d|b) (b,d|a) (c,d) (c,d|a) (c,d|b)
##  
##
## improvement for the simplex: find out a base before doing optimization
## keep last three coeffs (7,8,9) zero

use strict;

my $maxvar = 128;
my $D=7;              ## the dimension

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
    for my $i(0..$D-1){ ## was: 9
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

#################################################################
##   make the LP program
##
## the consitutents of the LP
my $rows=0; my $cols=0;
my @M=(); # the matrix; $M[0..$rows-1][0..$cols-1]
my @C=(); # the right hand side: $C[0..$rows-1] >= 0.0;
my @B=(); # the goal vector, $B[0..$cols-1]
my @BASE=(); # the base $BASE[0..$rows-1]; $BASE[row]<0 if the row is all zero
my $V;  # the final value to be optimized
my @colsperm=();
#################################################################
##
## simplex method to solve the problem
## 

# find the pivot element (col,row); col=-1 if there is no pivot
my $TIE_EPS = 5e-10;

# return (col,row) or (-1,0) if no pivot can be found.
#  
sub find_pivot {
    if(shift == 0){ # fill permutation matrix
       for my $i(0..$cols-1){$colsperm[$i]=$i; }
       for my $i(0..$cols-2){
          my $j=$i+int(rand($cols-$i)); my $t=$colsperm[$i];
          $colsperm[$i]=$colsperm[$j]; $colsperm[$j]=$t;
       }
    }
    my $maxi=-1; my $maxj=-1; my $smax=-1.0; # the maximal value so far
    for my $iii(0..$cols-1){
        my $i=$colsperm[$iii];
        my $bi=$B[$i];
        next if($bi<$TIE_EPS); # only these columns
        # find $j for which $M[$j][$i] > 0 && $C[$j]/$M[$j][$i] is minimal
        #  find $i, for which ($C[j]/$M[$j][$i])*$B[$i] is maximal
        #  $smax contains the maximal value so far
        my $MIN=0.0; my @t=(); my $MAX=-1.0;
        for my $j(0..$rows-1){
            next if($BASE[$j]<0); # all zero row
#            if($smax > $TIE_EPS && $C[$j]<$TIE_EPS){  # cannot improve
#               @t=(); last;
#            }
            my $p=$M[$j][$i];
            next if($p<$TIE_EPS);  # it's not positive
            my $pp=$C[$j]/$p;
            if($pp*$bi<$smax-$TIE_EPS){ # this column does not give improvement or tie
               @t=(); last; 
            }
            if($MIN==0.0 && $pp<$TIE_EPS){ # zero increment
                if($MAX<0 || $p>$MAX+$TIE_EPS){
                    $MAX=$p; @t=($j); 
                } elsif ($p>$MAX-$TIE_EPS){
                    push @t,$j;
                }
            } elsif (scalar @t==0 || $pp<$MIN-$TIE_EPS) {
                $MIN=$pp; @t=($j);
            } elsif ($pp<$MIN+$TIE_EPS) {
                push @t,$j;
            }
        }
        my $tidx=scalar @t; my $mj=-1;
        if($tidx==1){$mj=$t[0]; }
        elsif($tidx>1){ $mj=$t[int(rand($tidx))]; }
        next if($mj<0); # this is a wrong column
        my $sm=$C[$mj]*$bi/$M[$mj][$i];
        if($sm<$smax - $TIE_EPS){
            die "new smax is too small\n";
        } elsif($sm < $smax+$TIE_EPS){ # same value
            if($bi/$M[$mj][$i] > $B[$maxi]/$M[$maxj][$maxi]){
                $maxj=$mj; $maxi=$i; $smax=$sm;
            }
        } else { # bigger
            $maxi=$i; $maxj=$mj; $smax=$sm;
        }
    }
## print "smax=$smax; ($maxi,$maxj)\n";
    return ($maxi,$maxj);
}

sub eliminate { #args: (col,row)
    my($MAXI,$MAXJ)=@_;
if($BASE[$MAXJ]==$MAXI || $BASE[$MAXJ]<0){ die "na ne...\n"; }
    my $p=1.0/$M[$MAXJ][$MAXI];
    if($p!=1.0){
         for my $i(0..$cols-1){$M[$MAXJ][$i]*=$p; }
         $C[$MAXJ] *= $p;
    }
    $M[$MAXJ][$MAXI]=1.0; # now it is 1.0
    for my $j(0..$rows-1){
         next if($j==$MAXJ || $BASE[$j]<0);
         $p= $M[$j][$MAXI];
         next if($p==0);
         for my $i(0..$cols-1){ $M[$j][$i] -= $p*$M[$MAXJ][$i]; }
#         if($M[$j][$MAXI]<-$TIE_EPS || $M[$j][$MAXI]>$TIE_EPS){
#             die "eliminate: ($MAXI,$MAXJ), row $j is wrong\n";
#         }
         $M[$j][$MAXI]=0.0;
         $C[$j] -= $C[$MAXJ]*$p;
         if($C[$j]<$TIE_EPS){
              die "RHS got negative ($C[$j]) at row $j\n" if($C[$j]<-$TIE_EPS);
              $C[$j]=0.0;
         }
    }
    $p=$B[$MAXI];
    for my $i(0..$cols-1){$B[$i] -= $p*$M[$MAXJ][$i]; }
#    if($B[$MAXI]<-$TIE_EPS || $B[$MAXI]>$TIE_EPS){ die "B[$MAXI]=$B[$MAXI] != 0\n"; }
    $B[$MAXI]=0.0;
    $V -= $C[$MAXJ]*$p;
    $BASE[$MAXJ]=$MAXI;
}

sub do_simplex {
    my $do=1; my $doperm=-1;
    while($do){
        $doperm++;
        if($doperm%30 == 0){$doperm=0;}
        my($c,$r)=find_pivot($doperm);
## print "pivot: ($c,$r), V=$V\n";
        if($c>=0){
            eliminate($c,$r);
            $do=0 if($V<$TIE_EPS); # stop when the goal is reached
        } else {
            $do=0;
        }
    }
}

#################################################################

sub prepare_simplex {
    my($info,$goal)=@_;
    ## facet is an array [0..$D-1]; the direction to be minimized.
    my $Q=$info->{ineq};
    $rows=$info->{rows}; ## scalar @{$Q->[0]->{coeffs}}
    $cols=scalar @$Q;
## print "generating simplex: $rows times $cols\n";
    if( scalar @$goal != $rows ){
         die "size of goal != number of rows ($rows)\n";
    }
    @M=(); @C=(); # set them to empty string
    for my $j(0..$rows-1){ 
        $C[$j]=$goal->[$j]; $M[$j]=();
        for my $i(0..$cols-1){ $M[$j][$i]=$Q->[$i]->{coeffs}->[$j]; }
    }
    ## add $D more columns for the $D RHS coeffs
    $info->{ocols}=$cols;
    my $e=[]; my $ncol=[]; my $zero=[];
    for my $i(0..$D-1){ ## was: 9
        zero_eqs($e,$maxvar); zero_eqs($zero,$D); $zero->[$i]=1;
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
    @B=(0.0) x $cols; @BASE=(-1) x $rows;
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
## print "zero goals ...\n";
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
## print "positive goals...\n";
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
    # if no full base found, then call the first phase of SPX
    $V=0.0; my $lastcols=$cols;
    for my $r(0..$rows-1){
        if($BASE[$r]==-1){ ## $C[$r]>0 not in base; add two new dummy variables
            for my $i(0..$rows-1){
                $M[$i][$cols]=0.0; $M[$i][$cols+1]=0.0;
            }
            $BASE[$r]=$cols; $M[$r][$cols]=1.0; $M[$r][$cols+1]=-1.0;
            ## add the penalty
            $B[$cols]=-1.0; $B[$cols+1]=-1.0;
            $cols+=2; ## two more columns
            for my $j(0..$cols-1){ ## this makes $B[base]=0
                $B[$j] += $M[$r][$j]; 
            }
            $V += $C[$r];
        }
    }
    if($V>0){ # use simplex to find out the base
        do_simplex();
        if($V>$TIE_EPS){ return 1; } # no solution
        $cols=$lastcols;
        for my $r(0..$rows-1){
           next if($BASE[$r]<$cols);
           die "row $r has non-zero c=C[$r]\n" if($C[$r] > $TIE_EPS);
           $C[$r]=0.0;
           ## search for a non-zero entry, if none, discard the line
           my($plus,$minus,$qmax,$qmin,$maxc,$minc,$v)=(-1,-1,0.0,0.0,-1,-1,0.0);
           for my $i(0..$cols-1){
              $v=$M[$r][$i];
              if($v>1.0-1e-9 && $v<1.0+1e-9){ # +1
                  $minus=-1;
                  $plus=$i; last; 
              }
              if($v<-1.0+1e-9 && $v>=-1.0-1e-9){# -1
                  $minus=$i;
              }
              if($v<$qmin){$qmin=$v; $minc=$i; }
              if($v>$qmax){$qmax=$v; $maxc=$i; }
           }
           if($minus>=0){
               for my $i(0..$cols-1){ $M[$r][$i]=-$M[$r][$i]; }
               $plus=$minus;
           }
           if($plus<0){
                if($qmin>-1e-9 && $qmax<1e-9){ # all zero row
                     $BASE[$r]=-2;
                } else {
                    $plus=$maxc;
                    if($qmax+$qmin<0){
                       for my $i(0..$cols-1){$M[$r][$i]=-$M[$r][$i]; }
                       $plus=$minc;
                    }
                    $v=1.0/$M[$r][$plus];
                    for my $i(0..$cols-1){ $M[$r][$i] *= $v; }
                }
           }
           if($plus>=0){
                $M[$r][$plus]=1.0;
                for my $i(0..$rows-1){
                    next if($i==$r);
                    my $p=$M[$i][$plus];
                    if($p>1e-9 || $p<-1e-9){
                       for my $j(0..$cols-1){ $M[$i][$j] -= $p*$M[$r][$j]; }
                    }
                    $M[$i][$plus]=0.0;
                }
                $BASE[$r]=$plus;
           }
        }
    }
    return 0;
}

sub generate_simplex {
    my($info,$fname,$facet)=@_;
## print "base found, calling LP\n";
    # set up the goal to be minimized: this is the sum of all coeffs
    @B=(0.0) x $cols;
    my $ocols = $info->{ocols};
##    for my $i($ocols..$cols-1){$B[$i]=-1; } ## these are to be minimized
    for my $i(0..$D-1){ $B[$ocols+$i]=-$facet->[$i]; } ## was: 9
    $V=0.0;
    for my $r(0..$rows-1){
        my $i=$BASE[$r];
        if($i>=$cols){ die "base[$r]>cols=$cols\n"; }
        next if($i<0); ##  all empty row
        my $bi=$B[$i];
        if($bi>$TIE_EPS || $bi<-$TIE_EPS){
            for my $c(0..$cols-1){
               $B[$c] -= $bi*$M[$r][$c];
            }
            $V -= $bi*$C[$r];
        }
        $B[$i]=0.0;
    }
    # calculate how many rows we have
    my $db=0;
    for my $r(0..$rows-1){
        $db++ if($BASE[$r]>=0);
    }
    # and print out the LP problem: M[rows][cols], C[rows], B[cols], BASE[rows]
    open(SPX, ">/tmp/$fname.lp") || die "Cannot create /tmp/$fname\n";
      if($info->{uselex}){
           print SPX $ocols,"\n";
      }
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
## print "simplex written, calling LP next\n";
    return 0;
}

sub value {
    my $str=shift;
    $str =~ s/\s//g;
    if( $str =~ /^(\d+)\/(\d+)$/ ){
       return (0.0+$1)/(0.0+$2);
    }
    return 0.0+$str;
}
                            
sub execute_simplex {
    my($info,$fname,$results)=@_;
#    my $Q=$info->{ineq};
    my $ocols=scalar @{$info->{ineq}};
    if($info->{uselex}){
        system("/home/matus/progs/lexmin","/tmp/$fname.lp","/tmp/$fname.base");
    } else {
        system("/home/matus/progs/mspx","/tmp/$fname.lp","/tmp/$fname.lp.base","/tmp/$fname.base","/tmp/$fname.newbase");
    }
    my ($res1,$res2)=("","");
    if(open(FILE,"/tmp/$fname.base")){
        $res1=<FILE>; $res2=<FILE>; close(FILE);
        chomp $res1; chomp $res2;
    }
##    unlink("/tmp/$fname.base","/tmp/$fname.lp.base","/tmp/$fname.newbase");
    unlink("/tmp/$fname.lp.base","/tmp/$fname.newbase");
    if($res1 !~ /V=(.*)$/ ){
       print "LP result: $res1\n";
       print "LP terminated wrongly\n"; return (-1,undef);
    }
    my $V=$1; if($V =~ /^(\d+)\/(\d+)$/ ){$V=(0.0+$1)/(0.0+$2); } else {$V=0.0+$V; }
    if(0 && $V>1000){ ## now it can be ...
        my $rsl="No solution\n";
        if(!$results->{$rsl}){
             $results->{$rsl}=1;
             print "LP result: $res1\n";
             print "$rsl\n";
        }
        return (-1,undef);
    }
    my $e=[]; zero_eqs($e,$D);
    my @f=("0")x$D;
    foreach(split(',',$res2)){
        next if(!m/^(\d+):(.+)$/ );
        my ($idx,$v)=($1,$2);
        next if($idx<$ocols);
        $f[$idx-$ocols]=$v;
        $e->[$idx-$ocols]=value($v);
    }
    my $sum=0; my $rsl=""; for my $i(0..$D-1){ $rsl.=",$e->[$i]"; $sum += $e->[$i]; }
    return (0,$e)  if($results->{$rsl});
    $results->{$rsl}=1;
#### printing the result: this is a new vertex
    print "result: S=$sum;  $e->[0]"; for my $i(1..$D-1){ 
        print ",",($i==1||$i==4?" ":""),$f[$i];
    }
    print "\n";
####
    return (1,$e);
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
## dual algorithm to find out all vertices
## $D = dimension
##
## vertex -- homogeneous coordinates: last coordinate
##       0 for the first $D$ ideal points; otherwise -1
##    [$D+1] ->  list of facets incident to this vertex
## facet  -- $D+1 coordinates, should add up to 1, all >=0 
##    list of vertices incident to the facet

## the number of ones in $v:   unpack('%32b*',$v)
## checking if $v is empty:    unpack('%32C*',$v)==0
##

## $living_facets = list of facets living
##   $posf, $negf, $zerof: facets positive, negative, and zero values
##   for the new vertex we add facets it is on, and add to facets later
## facet (f1,f2) is a ridge iff
##    a) there are at least $D-1 vertices adjacent to both
##    b) intersection of { list(vertex): vertex\in f1\cap f2 } with
##       living - {f1,f2} is empty
## the ridge plus the new vertex determines a new facet
##

my $D_EPS=5e-9;       ## tolerance for this part
my $living_facets=""; ## bitmap of living facets
my @facets=();        ## array of facets
my @vertices=();      ## array of vertices

sub is_incident { # a facet and a vertex; +1, -1, 0
    my($if,$iv)=@_;
    my $f=$facets[$if]; my $v=$vertices[$iv];
    my $s=0.0;
    for my $i(0..$D){ $s += $f->[$i]*$v->[$i]; }
    if($s>$D_EPS){ return +1; }
    if($s<-$D_EPS){ return -1; }
    return 0;
}

sub is_ridge {
    my($if1,$if2)=@_; ## indices of the facets
    use integer;
    my $f1=$facets[$if1]; my $f2=$facets[$if2];
    my $adjvert=$f1->[$D+1] & $f2->[$D+1]; # intersection of adjacency lists
    # we need at least $D-1 adjacent vertices
    if(unpack('%32b*',$adjvert)<$D-1){ return 0; } # no
    # prepare the set which will be intersected; all but f1 and f2:
    my $ints=$living_facets; vec($ints,$if1,1)=0; vec($ints,$if2,1)=0;
    my $len=-1+8*length($adjvert);
    for my $i (0..$len){
        next if(vec($adjvert,$i,1)==0);
        $ints &= $vertices[$i]->[$D+1];
    }
    unpack('%32C*',$ints)==0;
}

sub solve_M {
    my $M=shift; ## columns: 0..$D; 
    my $rows=scalar @$M;
    my @base=(-1)x$rows; my $g=-1;
#print "Matrix, orig: ===========\n";
#for my $j(0..$rows-1){print join(',',@{$M->[$j]}),"\n";} print "===============\n";
    for my $i(0..$D){
        my $MAXJ=-1; my $MAX=-1.0;
        for my $j(0..$rows-1){
           next if($base[$j]>=0);
           my $p=$M->[$j]->[$i]; if($p<0){ $p=-$p; }
           next if($p<$D_EPS); # this value is zero
           if($MAX<$p){$MAX=$p; $MAXJ=$j; }
        }
        if($MAXJ<0){ ## all is zero, this should be the base
            if($g>=0){
#print "column=$i, MAXJ=$MAXJ, g=$g, matrix:===========\n";
#for my $j(0..$rows-1){print $base[$j],": ",join(',',@{$M->[$j]}),"\n";} print "===============\n";
                die "solve_M: the system has more than two degrees of freedom\n";
            }
            $g=$i;
            next;
        }
        $base[$MAXJ]=$i; $MAX=1.0/$M->[$MAXJ]->[$i];
        for my $ii(0..$D){ $M->[$MAXJ]->[$ii] *= $MAX; }
        for my $j(0..$rows-1){
            next if($j==$MAXJ);
            my $p=$M->[$j]->[$i]; next if($p==0.0);
            for my $ii(0..$D){ $M->[$j]->[$ii] -= $M->[$MAXJ]->[$ii]*$p; }
            $M->[$j]->[$i]=0.0;
        }
#print "column=$i, MAXJ=$MAXJ, res:================\n";
#for my $j(0..$rows-1){print join(',',@{$M->[$j]}),"\n";} print "==============\n";
    }
    if($g<0){ die "solve_M: the system is all zero\n"; }
    my @f=();
    $f[$g]=1.0;
    for my $j(0..$rows-1){
        next if($base[$j]<0);
        $f[$base[$j]]= -$M->[$j]->[$g];
        if($f[$base[$j]]<-$D_EPS){
#            print "g=$g (column)\n=======\n";
#            for my $j(0..$rows-1){ print join(',',@{$M->[$j]}),"\n";} print "===\n";
            die "solve_M: var $base[$j] is negative: $f[$base[$j]]\n";
        }
    }
#print "new facet: [",join(',',@f),"]\n";
    return \@f;
}

sub make_facet { # new facet from ridge f1\cap f2 and vertex v
    my($if1,$if2,$iv)=@_;
    my $facetno=scalar @facets;
# print "making facet $facetno from facets ($if1,$if2) and vertex $iv\n";
    my $vert=$vertices[$iv];
    vec($vert->[$D+1],$facetno,1)=1; ## this is adjacent to it
    my @M=(); $M[0]=[]; for my $i(0..$D){ $M[0]->[$i]= $vert->[$i]; }
    my $adjvert=$facets[$if1]->[$D+1] & $facets[$if2]->[$D+1];
    my $len=-1+scalar @vertices;
    for my $i(0..$len){
         next if(vec($adjvert,$i,1)==0);
         my @li=(); for my $j(0..$D){ push @li,$vertices[$i]->[$j]; }
# print "adding vertex $i (",join(',',@li),")\n";
         vec($vertices[$i]->[$D+1],$facetno,1)=1;
         push @M,\@li;
    }
    ## solve the equation in @M
    my $newf=solve_M(\@M); $newf->[$D+1]=$adjvert;
    vec($newf->[$D+1],$iv,1)=1; # contains the new vertex as well
    $facets[$facetno]=$newf;
#print "facet incident to vertices: ";
#for my $i(0..-1+8*length($newf->[$D+1])){ next if(vec($newf->[$D+1],$i,1)==0); print "$i,"}
#print "\n============\n";
    return $facetno;
}

sub add_vertex {
    my($vertex)=@_;
    $vertex->[$D]=-1.0; ## to make it homogeneous
# print "adding vertex [",join(',',@$vertex),"] as ",scalar @vertices,"\n";
    $vertex->[$D+1]=""; ## no facets incident with it yet
    if(scalar @vertices==0){ ## this is the first vertex
        for my $i(0..$D-1){ ## add ideal vertices
           my @v=(0.0)x($D+1); $v[$i]=1.0; $v[$D+1]="";
           for my $if(0..$D){
              next if($if-1==$i); vec($v[$D+1],$if,1)=1;
           }
           $vertices[$i]=\@v;
        }
        ## add facets
        for my $if(0..$D){ # facet 0 is the ideal facet
           my @f=(0.0)x$D; $f[$D+1]=""; 
           vec($living_facets,$if,1)=1;
           for my $ip(0..$D-1){
               next if($ip==$if-1);
               vec($f[$D+1],$ip,1)=1;
           }
           if($if==0){ # ideal facet
               $f[$D] = -1;
           } else { # coordinate facets
               $f[$if-1]=1.0; $f[$D]=$vertex->[$if-1];
               vec($f[$D+1],$D,1)=1; ## the new vertex is on it
               vec($vertex->[$D+1],$if,1)=1; ## it is on it
           }
           $facets[$if]=\@f;
        }
        $vertices[$D]=$vertex;
# print "added first vertex as #$D\n";
        return;
    }
    ## we have old vertices, split facets into three groups
    my ($newf,$posf,$negf,$zerof)=("","","","");
    my $facetno=-1 + scalar @facets;
    my $newv= scalar @vertices; $vertices[$newv]=$vertex;
# print "sorting facets: [";
    for my $if(0..$facetno){
        next if(vec($living_facets,$if,1)==0); # not a valid facet
        my $inc=is_incident($if,$newv);
# print "($if: $inc)";
        if($inc<0){ vec($negf,$if,1)=1; }
        elsif($inc>0){ vec($posf,$if,1)=1; vec($newf,$if,1)=1; }
        else{
            vec($newf,$if,1)=1; vec($vertex->[$D+1],$if,1)=1;
            vec($facets[$if]->[$D+1],$newv,1)=1;
        }
    }
# print "]\n";
    for my $if1(0..$facetno){
        next if(vec($posf,$if1,1)==0);
        for my $if2(0..$facetno){
            next if(vec($negf,$if2,1)==0);
            next if(!is_ridge($if1,$if2));
            my $ifn=make_facet($if1,$if2,$newv);
            vec($newf,$ifn,1)=1; ## this is a new facet
        }
    }
    # adjust living fcets
    $living_facets=$newf;
}

###############################################################
## lexmin: generates the lexicographically minimal solution for
##   an LP problem.
##

if(scalar @ARGV<3){ 
     print "args: <paste> <first base> <first goal> <2nd base> <2nd goal> ...\n
     base: four variable (ax,bx,cx,d)\n
     goal: string of seven 0/1\n"; 
     exit 0;
}

my $info=make_paste($ARGV[0]); # give error message if it is wrong
generate_shannon($info);
my $e=[]; zero_eqs($e,$maxvar);
my $argc=1; while($argc<scalar @ARGV){
    if($ARGV[$argc] !~ /^[a-z]+,[a-z]+,[a-z]+,[a-z]+$/ ){
         die "arg $argc is of wrong format ($ARGV[$argc]\n";
    }
    my @m=();my $Dm1=$D-1;
    if($ARGV[$argc+1] =~ /^\d{$D}$/ ){
       @m=split('',$ARGV[$argc+1]);
    } elsif($ARGV[$argc+1] =~ /^\d+(,\d+){$Dm1}$/ ) {
       @m=split(',',$ARGV[$argc+1]);
    } else {
         die "arg ".($argc+1)." is of wrong format (".$ARGV[$argc+1].")\n";
    }
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

my $results={}; my $sres;
my @arr=();

$info->{uselex}=1;
if(prepare_simplex($info,$goal)){
    print "No solution\n"; exit;
}
for my $i(0..$D-1){ $arr[$i]=1.0; }
generate_simplex($info,"unit",\@arr);
($sres,$e)=execute_simplex($info,"unit",$results);
if($sres<0){ die "simplex returned with error\n"; }
if($sres==0){ die "first result is duplicated...\n"; }
add_vertex($e); 
my $nextfacet=1; # skip ideal facet with index=0;
while($nextfacet< scalar @facets){
    my $if=$nextfacet; $nextfacet++;
    next if(vec($living_facets,$if,1)==0);
############################
#print "incidence:\n";
#for my $i(0..-1+scalar @vertices){
#    print " == vertex $i [";
#    for my $j(0..-1+scalar @facets){
#         next if(vec($living_facets,$j,1)==0);
#         next if(vec($vertices[$i]->[$D+1],$j,1)==0);
#         print "$j,";
#    }
#    print "]\n";
#}
#for my $j(0..-1+scalar @facets){
#    next if(vec($living_facets,$j,1)==0);
#    print " -- facet $j [";
#    for my $i(0..-1+scalar @vertices){
#         next if(vec($facets[$j]->[$D+1],$i,1)==0);
#         print "$i,";
#    }
#    print "]\n";
#}
###########################
    for my $i(0..$D-1){ $arr[$i]=$facets[$if]->[$i]; }
    generate_simplex($info,"unit",\@arr);
    ($sres,$e)=execute_simplex($info,"unit",$results);
    if($sres<0){ die "simplex returned with error...\n"; }
    my $s=-$facets[$if]->[$D]; 
    for my $i(0..$D-1){ $s+=$facets[$if]->[$i]*$e->[$i]; }
    if($s>$D_EPS){
        die "new vertex is inside the inner approximation\n";
    }
    if($s>-$D_EPS){
        if($sres==0){
#print "no new vertex\n";
            next;
        }
#print "vertex is on the boundary, but outside the convex hull\n";
    }
    if($sres==0){
       die "some old vertex is outside the inner approximation\n";
    }
#    if($s<0){$s=-$s;}
#    if($s<$D_EPS){ print "got no new facet, done\n"; next; }
#    print "adding the new vertex\n";
    add_vertex($e);
}

#########################################################


