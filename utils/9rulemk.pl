#!/usr/bin/perl
# generating vlp file for a rule
# arguments: <copy_string> <base1> <base2> <vlp>
#   rulemk.pl -x "r=a:bc"  ar,br,c,dr a,b,c,r result.vlp
#
##############################################################
use strict;
my $maxvar = 128;
my $D=9;	## the dimension (11)

###############################################################
my ($flag,$paste,$base1,$base2,$file)=(0,"","","","");

sub print_usage {
    print "Usage: rulemk.pl [-x] <copy> <base1> [<base2>] <vlp-file>\n",
          "  <base>: the four variables to be taken, such as ar,br,c,dr\n",
          "  -x:  use the sum of two bases\n\n";
    exit 1;
}

if(scalar @ARGV<3 || $ARGV[0] =~ /^\-[\-]?h/ ){ print_usage(); }

if($ARGV[0] eq "-x" ){
    $flag=1; if(scalar @ARGV<5){ print_usage(); }
    $paste=$ARGV[1]; $base1=$ARGV[2],$base2=$ARGV[3], $file=$ARGV[4];
} elsif( scalar @ARGV == 3 ){
    $paste=$ARGV[0], $base1=$ARGV[1]; $file=$ARGV[2];
} elsif( scalar @ARGV == 4 ){
    $paste=$ARGV[0], $base1=$ARGV[1]; $base2=$ARGV[2]; $file=$ARGV[3];
} else {
    print_usage();
}
if(!$file || $file !~ /\.vlp$/ ){ die "The output file name should end with '.vlp'\n"; }
if(-e $file ){
    print "File $file exists. Continue (y/n)? ";
    my $ans=<stdin>;
    if($ans !~ /^y/i){ exit 0; }
}

###############################################################
sub cv { #convert a substring of "abcdrst" to a number 0--127
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

sub name { # number --> abcdrst
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
        return "copy: wrong syntax ($dsc)";
    }
    my ($new,$old,$X,$vars)=($1,$2,cv($3),$info->{vars});
    if(cv($new) & $vars){
        return "copy: new variable in \"$new\" already defined ($dsc)";
    }
    if(($X&$vars)!=$X){
        return "copy: over variable in \"".name($X)."\" not defined ($dsc)";
    }
    push @{$info->{paste}},{ new => $new, over => $vars, by => "$old:".name($X) };
    my @defs=(); # $defs[]={v=> 32, r=>"16|1"};
    my $newvars=0;
    my $Z=0; # pasted variables
    while($new){
        $new =~ s/^(.)//; my $v=cv($1);
        if($v==0 || ($v&$newvars)){
            return "copy: new variable is doubly defined ($dsc)";
        }
        $newvars |= $v;
        my $r=0;
        if( $old =~ s/^([abcdrst])// ){
            $r=cv($1);
        } elsif( $old =~ s/^\(([abcdrst]+)\)// ){
            $r=cv($1);
        } else {
           return "copy: syntax of copy variable ($dsc)";
        }
        if(($r&$vars)!=$r){
            return "copy: copy variable in \"".name($r). "\"not defined ($dsc)";
        }
        $Z = $Z|$r;
        if($r&$X){
            return "copy: copy variable \"".name($r)."\" and over variables overlap ($dsc)";
        }
        push @defs, {v=>$v, r=> $r };
    }
    if($old){
        return "copy: extra copy variable \"$old\" ($dsc)";
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
        if($err){ die "$err\n"; }
    }
    if($nopaste){ die "copy: missing copy string\n"; }
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
["(c,d|a)",       -1, 0, 0, 0,  0, 1, 1, 0, 0, 0,   0,  0, -1,  0,  0  ],
["(c,d|b)",        0,-1, 0, 0,  0, 0, 0, 1, 1, 0,   0,  0,  0, -1,  0  ],
["(c,d)",          0, 0, 1, 1,  0, 0, 0, 0, 0,-1,   0,  0,  0,  0,  0  ],
["(a,b|cd)",       0, 0, 0, 0,  0, 0, 0, 0, 0,-1,   0,  0,  1,  1, -1  ],
#
["(a|bcd)",        0, 0, 0, 0,  0, 0, 0, 0, 0, 0,   0,  0,  0, -1,  1  ],
["(b|acd)",        0, 0, 0, 0,  0, 0, 0, 0, 0, 0,   0,  0, -1,  0,  1  ],
["(c|abd)",        0, 0, 0, 0,  0, 0, 0, 0, 0, 0,   0, -1,  0,  0,  1  ],
["(d|abc)",        0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  -1,  0,  0,  0,  1  ]
];
#

## create the vector of natural coordinates for the four variables in $str
##
sub add_natural_coords {
    my ($info,$sign,$str,$num)=@_;
    $num=15 if(! defined $num);
    my $eqs=[];
    my @vars=split(',',$str);
    for my $i(0..3){
       my $t=cv($vars[$i]);
       if(!$t){ die "var string [$str] is wrong\n"; }
       $vars[$i]=$t;
    }
    foreach my $natcoord(@$macoord){
        next if($num<1); $num--;
        my $idx=0;
        zero_eqs($eqs,$maxvar);
        foreach my $l(@ocords){
           $idx++; my $vv=0;
           if($l =~ /a/ ){ $vv |= $vars[0]; }
           if($l =~ /b/ ){ $vv |= $vars[1]; }
           if($l =~ /c/ ){ $vv |= $vars[2]; }
           if($l =~ /d/ ){ $vv |= $vars[3]; }
           add_eqs($info,$eqs,$vv,$sign*$natcoord->[$idx]);
        }
        _store_ineq($info,$eqs,$natcoord->[0]);
    }
}

######################################################################
##
## after generate_shannon($info), we have 
##   $info->{trans}[cv("variable")] not defined: "variable" remains,
##       "variable" remains, 
##       its real index (starting from zero) is in $info->{vidx}[cv("var")];
##     the latter is -1 otherwise
##   $info->{rows} number of variables which remain
##   $info->{ineq}[0..] = {coeffs=>[0..rows-1], desc=>"description"};
##        coeffs is an array containing all coeffs of the given inequality
##          (all has the same size $info->{rows});
##   number of inequalities: scalar @{$info->{ineq}}
##
##
#  Matrix A is composed as follows
#             inequalities
#        /^^^^^^^^^^^^^^^^^^^^^^^\     
#       l_1            .....     l_n    x_1 ... x_15  y_1 ... y_15
#
# var1   +------------------------+    +----------+  +----------+
#        |    Shannon ineq        |    |   def    |  |   def    |   = 0
# varm   +------------------------+    +----------+  +----------+
#
# nat1   +------------------------+    +----------+  +----------+   >=0 $D
#        |         0              |    |   ID     |  |    0     |
# nat15  +------------------------+    +----------+  +----------+   = 0
#
# Nat1   +------------------------+    +----------+  +----------+   <=0  $D
#        |         0              |    |   0      |  |   ID     |
# Nat15  +------------------------+    +----------+  +----------+   = 0
#
#        +-------- 0 -------------+    +--- 0 ----+  +1--1 0--0 +   = -1
#
#  column constraints: l_i >=0; x_i,y_i are free.
#  matrix P:
#
#        +------------------------+    +----------+  +----------+
#        |          0             |    | ID  | 0  |  |    0     |  $D
#        +------------------------+    +----------+  +----------+
#
#        +------------------------+    +----------+  +----------+
#        |          0             |    |   0      |  | ID  | 0  |  $D
#        +------------------------+    +----------+  +----------+
#
#

sub delete_extra_rows {
    my($info)=@_;
## add $info->{base}->[0..rows], where this is -1 if a combination of
##   previous rows, otherwise the base element in that row
## to get the matrix element: $info->{ineq}->[$col]->{coeffs}->[$row]
    $info->{base}=[];
    my $Q=$info->{ineq};
    my $rows=$info->{rows}; my $cols= scalar @$Q;
    my @M=();
    for my $j(0..$rows-1){
        $info->{base}->[$j]=-1; ## skip it
        ## fetch row $j to $M
        $M[$j]=[];
        for my $i(0..$cols-1){ $M[$j]->[$i]=$Q->[$i]->{coeffs}->[$j]; }
        ## adjust this row
        for my $jj(0..$j){
            my $pivot=$info->{base}->[$jj];
            next if($pivot<0);
            ## $M[$jj]->[$pivot]==1.0;
            my $p=$M[$j]->[$pivot];
            for my $i(0..$cols-1){ $M[$j]->[$i] -= $p*$M[$jj]->[$i]; }
            $M[$j]->[$pivot]=0.0;
        }
        ## search for the largest absolute value in this row
        my $maxi=-1; my $maxp=0.0;
        for my $i(0..$cols-1){
            my $p=$M[$j]->[$i]; $p=-$p if($p<0.0);
            if($maxi<0 || $maxp<$p){$maxp=$p; $maxi=$i; }
        }
        next if($maxp<1e-10); ## all zero line
        $info->{base}->[$j]=$maxi;
        my $p=1.0/$M[$j]->[$maxi];
        for my $i(0..$cols-1){ $M[$j]->[$i] *= $p; }
        $M[$j]->[$maxi]=1.0;
    }
##
#    my $deleted=0;
#    for my $j(0..$rows-1){
#        $deleted++ if($info->{base}->[$j]<0);
#    }
#    print "rows deleted=$deleted\n";
#    exit 24;
##
}

sub generate_vlp {
    my($info)=@_;

#     print "Writing vlp to file $file\n";
    my $rows=$info->{rows}; #number of standard variables
    my $cols = scalar @{$info->{ineq}}; # columns BEFORE adding stuff
    # add 3*$D extra columns
    add_natural_coords($info,-1,"a,b,c,d",$D);
    add_natural_coords($info,+1,$base1,$D);
    my $DD=$D+$D;
    if($base2){
        add_natural_coords($info,+1,$base2,$D);
        if($flag){ # merge last $D columns
            my $lastcol = -$D + scalar @{$info->{ineq}};
            for (1..$D){
                my $q=pop @{$info->{ineq}};
                $lastcol--;
                for my $i(0..-1+scalar @{$q->{coeffs}}){
                     $info->{ineq}->[$lastcol]->{coeffs}->[$i]
                        += $q->{coeffs}->[$i];
                }
            }
        } else {
           $DD=$D+$D+$D;
        }
    }
## delete superfluous equations
## $info->{ineq}->[col]->{coeffs}->[row]
    delete_extra_rows($info);
    my $newrows=0; for my $j(0..$rows-1){
       $newrows++ if($info->{base}->[$j]>=0);
    }
## print "adding extra columns:",-$cols + scalar @{$info->{ineq}},"\n";
    my $nonzero=0;
    foreach my $q (@{$info->{ineq}}){
#        foreach my $v (@{$q->{coeffs}}){
#            $nonzero++ if($v);
#        }
        for my $j(0..$rows-1){
            next if($info->{base}->[$j]<0);
            $nonzero++ if($q->{coeffs}->[$j]);
        }
    }
    open(VLP,">$file") || die "Cannot open file $file for writing.\n";
    if($base2){
        print VLP "c Maximal rule for $paste; $base1; $base2",
            ($flag? " (merged)" : ""), "\n";
    } else {
        print VLP "c Maximal rule for $paste; $base1\n";
    }
    print VLP "p vlp min ",
       1+$newrows,  # number of total rows
       " ",$DD+$cols, # number of columns
##!       " ",$nonzero+$DD, # nonzero elements in A
       " ",$nonzero+$D, # nonzero elements in A
       " ",$DD, # number of objectives
       " ",$DD, # number of non-zero entries in objectives
       "\n";
    # variable types: 1..$cols+$D+$D: non-negative
    for my $i(1..$cols+$DD){
        print VLP "j $i l 0\n";
    }
    # constraint types:   1..$rows:            ==0
    #                     $rows+1              ==1
    for my $i(1..$newrows+1){
        print VLP "i $i s ",($i<=$newrows?"0":"1"),"\n";
    }
    # print the matrix A
    for my $j(1..$cols+$DD){
        my $q=$info->{ineq}->[$j-1];
        my $i=0;
#        for my $v (@{$q->{coeffs}}){
#             $i++; next if($v==0);
#             print VLP "a $i $j $v\n";
#        }
        for my $ii(0..$rows-1){
            next if($info->{base}->[$ii]<0);
            $i++; my $v=$q->{coeffs}->[$ii];
            next if($v==0);
            print VLP "a $i $j $v\n";
        }
    }
##!    for my $i(1..$DD){
##!        print VLP "a ",$newrows+1," ",$cols+$i," 1\n";
##!    }
    for my $i(1..$D){
        print VLP "a ",$newrows+1," ",$cols+$i," 1\n";
    }
    # print the objectives, total number is $DD
    # -1 1 1 1 1 1; 1 -1 -1 -1 -1; 1 -1 -1 -1 -1
    for my $i(1..$DD){
        my $v=($i<=$D ? 1 : -1);
        if($i % $D ==1 ){ $v=-$v; }
#        print VLP "o ",$i," ",$cols+$i,(1<$i && $i<=$D+1 ? " 1":" -1"),"\n";
        print VLP "o ",$i," ",$cols+$i," $v\n";
    }
    print VLP "e\n\n";
    close(VLP);
}

##############################################################
# generate the vlp file for the given rule
#
#
my $info = make_paste($paste); # aborts if there were any errors
generate_shannon($info);


generate_vlp($info); exit 23;

