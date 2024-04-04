#!/usr/bin/perl -w
##
## generate a vlp file from a copy string
##
## arguments: [flag] <copy_string> <filename>
##
## Changes:
##   --  argument -xx for truncating to the first 6 coordinates
##   --  checking if the over part is a flat
##   --  parallel extensions
##   --  consequences to further reduce the number of varibles
##   --  assuming that the original polymatroid is tight
##

use strict;

#########################################################################
#
# Natural coordinates:
# "[]", "(a,b|c)","(a,c|b)","(b,c|a)","(a,b|d)","(a,d|b)","(b,d|a)",
#       "(c,d|a)","(c,d|b)","(c,d)","(a,b|cd)",
#       "(a|bcd)","(b|acd)","(c|abd)","(d|abc)",
#
# Which natural coordinates are assumed to be zero? The last four mean tightness
#
my @ZERONAT =
(0, 0,0,0, 0,0,0, 0,0,0,0, 1,1,1,1);

use constant NATCOORDS => (
"-a-b-abc-abd-cd+ab+ac+ad+bc+bd",  # [a,b,c,d]
"ac+bc-c-abc",                     # (a,b|c)
"ab+bc-b-abc",                     # (a,b|b)
"ab+ac-a-abc",                     # (b,c|a)
"ad+bd-d-abd",                     # (a,b|d)
"ab+bd-b-abd",                     # (a,d|b)
"ab+ad-a-abd",                     # (b,d|a)
"ac+ad-a-acd",                     # (c,d|a)
"bc+bd-b-bcd",                     # (c,d|b)
"c+d-cd",                          # (c,d)
"acd+bcd-cd-abcd",                 # (a,b|cd)
"abcd-bcd",                        # (a|bcd)
"abcd-acd",                        # (b,|acd)
"abcd-abd",                        # (c,abd)
"abcd-abc"                         # (d|abc)
);

use constant MAINV => (
[], #
[-2,  1, 1, 0, 1, 1, 0,  1, 0, 1, 1,  1, 0, 0, 0], #a
[-2,  1, 0, 1, 1, 0, 1,  0, 1, 1, 1,  0, 1, 0, 0], #b
[-3,  1, 1, 1, 1, 1, 1,  1, 1, 1, 2,  1, 1, 0, 0], #ab
[-2,  0, 1, 1, 1, 0, 0,  1, 1, 1, 1,  0, 0, 1, 0], #c
[-3,  1, 1, 1, 1, 1, 0,  2, 1, 1, 2,  1, 0, 1, 0], #ac
[-3,  1, 1, 1, 1, 0, 1,  1, 2, 1, 2,  0, 1, 1, 0], #bc
[-4,  1, 1, 1, 1, 1, 1,  2, 2, 1, 3,  1, 1, 1, 0], #abc
[-2,  1, 0, 0, 0, 1, 1,  1, 1, 1, 1,  0, 0, 0, 1], #d
[-3,  1, 1, 0, 1, 1, 1,  2, 1, 1, 2,  1, 0, 0, 1], #ad
[-3,  1, 0, 1, 1, 1, 1,  1, 2, 1, 2,  0, 1, 0, 1], #bd
[-4,  1, 1, 1, 1, 1, 1,  2, 2, 1, 3,  1, 1, 0, 1], #abd
[-4,  1, 1, 1, 1, 1, 1,  2, 2, 1, 2,  0, 0, 1, 1], #cd
[-4,  1, 1, 1, 1, 1, 1,  2, 2, 1, 3,  1, 0, 1, 1], #acd
[-4,  1, 1, 1, 1, 1, 1,  2, 2, 1, 3,  0, 1, 1, 1], #bcd
[-4,  1, 1, 1, 1, 1, 1,  2, 2, 1, 3,  1, 1, 1, 1] #abcd
);

#########################################################################
## usage, check arguments

my ($quiet,$full,$paste,$file)=(0,"","","");

sub print_usage {
    print "Usage: mkvlp.pl  [-q] [-fxx] <copy string> <filename>\n",
          "   q -- quiet\n",
          "   f -- full (10), default\n",
          "   x -- truncated to 8\n",
          "  xx -- truncated to 6\n";
    exit 1;
}

if(($ARGV[0]||"") eq "-q"){
    $quiet=1; shift @ARGV;
}
if(scalar @ARGV ==0 || $ARGV[0] =~ /^\-[\-]?h/ ){ print_usage(); }

if($ARGV[0] =~ /^[\-]?([xf]+)/ ){
    $full=$1; $paste=$ARGV[1]; $file=$ARGV[2];
} else {
    $paste=$ARGV[0]; $file=$ARGV[1];
}
$full="f" if(!$full);
$full = $full eq "f" ? 10 : $full eq "x" ? 8 : $full eq "xx" ? 6 : 0;
if(!$paste || !$file || !$full ){ print_usage(); }
for my $i(0 .. $full){
   if($ZERONAT[$i]){
      print "Coordinate ",$i+1," is fixed to zero; use -x or -xx argument\n";
      exit 1;
   }
}
my $chkfile=1;
if( $file eq "--test"){ ## checking syntax only
    $chkfile=-1;
} else {
    if( $file !~ /\.vlp$/ ){
      print "The output file name should end with '.vlp'\n";
      exit 1;
    }
    if(-e $file ){
      if($quiet){ exit 1; }
      print "File $file exists. Continue (y/n)? ";
      my $ans=<stdin>;
      if($ans !~ /^y/i ){ exit 0; }
      $chkfile=0;
    }
}

my $CHECKFLATS=1;

#########################################################################
##
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
    $r+=128 if($v=~/u/);
    $r+=256 if($v=~/v/);
    $r+=512 if($v=~/w/);
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
    $v .= "u" if($s&128);
    $v .= "v" if($s&256);
    $v .= "w" if($s&512);
    return $v;
}

sub _zero_eqs {
    my($info)=@_;
    for my $i(0 .. $info->{rows}-1){ $info->{eqs}->[$i]=0; }
    for my $i(0 .. 14){ $info->{neqs}->[$i]=0; }
}

sub _hash_eqs {
    my $info=shift; my $hash="";
    for my $i( 0 .. 14){
        next if($ZERONAT[$i]);
        $hash .= ",$info->{neqs}->[$i]";
    }
    for my $i (0 .. $info->{rows}-1){ 
        $hash .= ",$info->{eqs}->[$i]"; 
    }
    return $hash;
}

sub add_eqs { ## $e->[$var] += $d; $info->{eqs}->[new] for $var>=16,
    my($info,$var,$d)=@_;
    return if($var==0);
    my $idx = $info->{trans}[$var];
    if(defined $idx ){ # redefined
        foreach my $sss (keys %$idx ){
            add_eqs($info,$sss,$d*$idx->{$sss});
        }
        return;
    }
    if($var<16){ # subset of abcd, store in $info->{neqs}
        $idx=(MAINV)[$var];
        for my $i(0 .. 14){
           $info->{neqs}->[$i] += $d*$idx->[$i];
        }
        return;
    } # store it in $info->{eqs}
    die "add_eqs: wrong var $var\n" if($info->{vidx}[$var]<0);
    $info->{eqs}->[$info->{vidx}[$var]] += $d;
}

sub _store_ineq {
    my ($info,$desc)=@_;
    my $cf=[];
    my $idx=0; for my $i(0 .. 14){
       if($ZERONAT[$i]==0){
          $cf->[$idx]=$info->{neqs}->[$i]; $idx++;
       }
    }
    while($idx<$info->{rows}){ $cf->[$idx]=$info->{eqs}->[$idx]; $idx++; }
    my $OK=$cf->[0]>0 ? 1 : 0;
    for my $i(1..$info->{rows}-1){ if($cf->[$i]<0){$OK=1; last; }}
    return if($OK==0);
    push @{$info->{ineq}}, { coeffs => $cf, desc => $desc };
}

sub _generate_ineqs {
    my ($info)=@_;
    $info->{ineq}=[]; ## empty list
    $info->{eqs}=[]; $info->{neqs}=[];   ## temporary storage
    my $vars=$info->{vars}; my $h;
    my %hash=(); ## equations, hash of equations
    for my $A (0..1023){ ## long equations
        next if (($A&$vars) != $A );
        for (my $i=1;$i&1023; $i=$i<<1){
            next if(($i&$vars)==0 || $A==($A|$i));
            for (my $j=$i; $j&1023; $j=$j<<1){
                 next if(($j&$vars)==0 || $j==$i || $A==($A|$j));
                 _zero_eqs($info);
                 add_eqs($info,$A|$i,1); add_eqs($info,$A|$j,1);
                 add_eqs($info,$A,-1); add_eqs($info,$A|$i|$j,-1);
                 $h=_hash_eqs($info);
                 next if(defined $hash{$h}); $hash{$h}=1;
                 _store_ineq($info,[$A,$i,$j]);
            }
        }
    }
}

sub putto {
    my($info,$i,$n,$g)=@_; ## $t=$trans[$i];
    return if(!$i);
    my $t=$info->{trans}[$i];
    if(defined $t){
        foreach my $j (keys %$t){ putto($info,$j,$n*$t->{$j},$g); }
    } else {
         $g->[$i] = ($g->[$i]||0) + $n;
    }
}

sub _store_trn {
    my($info,$g)=@_;
    my $n=-1+scalar @$g;
    while($n>=0 && ! $g->[$n]){ $n--; } # get the first non-zero item
    return if ($n<=0); # not found
    if( defined $info->{trans}[$n]){
       die "wrong: trans is defined at $n\n";
    }
    my $gn=$g->[$n];
    my %t=();
    for my $i(0..$n-1){
        my $v=$g->[$i];
        next if(! $v);
        $t{$i}= $gn==-1 ? $v : $gn==1 ? -$v : (-$v/($gn+0.0));
    }
    $info->{trans}[$n]=\%t; $info->{trn}++;
}

sub makeEQ {
    my($info,$x,$b,$c,$d)=@_;
    my $g=[]; 
    putto($info,$x,1,$g); putto($info,$b,-1,$g); 
    putto($info,$c,-1,$g); putto($info,$d,1,$g);
    _store_trn($info,$g);
}

sub _initialize_trans {
    my($info)=@_;
    return if(defined $info->{trans});
    $info->{trans} = (); $info->{trn}=0;
    # find out which natrual coordinates are to be set to zero
    foreach my $idx(0 .. 14){
        next if(!$ZERONAT[$idx]);
        my $txt=(NATCOORDS)[$idx]; my $g=[]; my $n=1;
        while($txt){
            $txt =~ s/^\+//;
            if($txt =~ s/^-//){ $n=-1; }
            elsif( $txt =~ s/^([abcd]+)//){
               putto($info,cv($1),$n,$g); $n=1;
            } else { die "Natcoord[$idx] has an error ($txt)\n"; }
        }
        _store_trn($info,$g);
    }
}

sub checkeq { # return 1 for zero, 1 for non-zero
    my($info,$x,$b,$c,$d)=@_;
    my $g=[];
    putto($info,$x,1,$g); putto($info,$b,-1,$g); 
    putto($info,$c,-1,$g); putto($info,$d,1,$g);
    my $n=-1+scalar @$g;
    while($n>=0 && ! $g->[$n]){ $n--; } # get the first non-zero item
    return $n<=0; 
}

########################################################################
## handle additional symmetries
## $info->{symm} is a list of symmetries
##   a symmetry: [a1,b1], [a2,b2], ... [ak,bk]
##   both <a1...ak> and <b1...bk> are the same partition;
##   either ai=bi, or both [ai,bi] and [bi,ai] are present
##

sub checkM { # check if $M is closed for the symmetry in $symm
    my($M,$symm)=@_;
    my $cover=0;
    foreach my $s(@$symm){
       my $meet=$s->[0]&$M;
       next if($meet==0);             # disjoint
       return 0 if($meet != $s->[0]); # not inside
       return 0 if(0 == ($M&$s->[1])); # the image is outside $M
       $cover |= $meet;
    }
    return $cover == $M; # whole $M is covered
}

sub newpairs { # given the paste description $paste1 and symmetry $sym,
               #  check if it extends to the new arrangement.
    my($paste1,$symm)=@_;
    my $allv=0; # variables in the paste array
    # fist, we take a subset of paste so that
    #  if ai intersects r, then both ai and bi are subset of $allv
    # create a local version of $paste1
    my $paste=[]; foreach my $p(@$paste1){
       push @$paste, {r=>$p->{r}, v=>$p->{v}, use=>1 };
    }
    my $done=0;
    while(!$done){ $done=1;
      # collect variables to $allv;
      $allv=0;
      foreach my $p(@$paste){ if($p->{use}){$allv |= $p->{r};} }
      # go over all elements of $paste
      foreach my $p(@$paste){
         next if(!$p->{use}); # skip it
         my $var=$p->{r};
         # check if $p->{r} intesects ai
         foreach my $s(@$symm){ # $s->[0], $s->[1]
            next if(($var & $s->[0])==0);
            next if(($s->[0] & $allv)==$s->[0] && ($s->[1]& $allv)==$s->[1]);
            $done=0; $p->{use}=0;
         }
      }
    }    
    # at this point $allv is the union of all feasible old variables
    #  if this is empty, there is nothing to do
    if($allv==0){ return []; }
    # at this point we have that $s->[0/1] is either in $allv, or disjoint from it.
    # Now we have s0 / s1, try to expand it
    my @allpairs=(); # {s0=>, s1=>, v1=>, v2=> };
    foreach my $s01(@$symm){
        my $s0=$s01->[0]; my $s1=$s01->[1];; # s0 => s1
        my $found=0;
        foreach my $last(@allpairs){
            if( $s0&$last->{s0} ){
               $found=1;
               if(($s0&$last->{s0})!=$s0){ die "newpairs: not closed for $s0\n"; }
               last;
            }
        }
        last if($found); # it has been taken care ...
        $done=0; my $v0=0; my $v1=0;
        while(!$done){ $done=1;
            foreach my $p(@$paste){
                next if(!$p->{use}); # skip it
                my $r=$p->{r};
                if($s0 & $r){ 
                   $v0 |= $p->{v};
                   if(($s0 & $r)!=$r){ $done=0; $s0|=$r; }
                }
                if($s1 & $r){
                    $v1 |= $p->{v};
                    if(($s1&$r)!=$r){ $done=0; $s1|=$r; }
                }
            }
            foreach my $sm(@$symm){ # $s->[0], $s->[1]
                my $s=$sm->[0];
                if(($s0&$s)!=0){
                    if(($s0&$s)!=$s){ $done=0; $s0 |= $s; }
                    if(($s1 & $sm->[1])!=$sm->[1]){ $done=0; $s1 |= $sm->[1]; }
                }
            }
        } # the closure was found, but it might be out of range
        next if($v0==0 && $v1==0); # do not interact with the copy variables
        # at this point we have $s0 => $s1, $v0 => $v1 for the new symmetry
        if(!$v0 || !$v1){ die "newpairs: $v0 or $v1 is zero\n"; }
        $found=0;
        foreach my $last(@allpairs){
            if($last->{s0} & $s0){
                $found=1;
                if($s0!=$last->{s0} || $s1!=$last->{s1}|| $v0!=$last->{v0}|| $v1!=$last->{v1}){
                   die "newpairs: ($s0,$s1,$v0,$v1) different\n";
                }
            }
        }
        if(!$found){
            push @allpairs, {s0=>$s0, s1=>$s1, v0=>$v0, v1=>$v1 };
        }
    }
    # no @allpairs contains all potential symmetries
    # sanity check: s0 and s1 should be the same partition of the same set
    my $alls0=0; my $alls1=0;
    for my $last(@allpairs){
        $alls0 |= $last->{s0}; $alls1 |= $last->{s1};
        foreach my $other(@allpairs){
            if($last->{s0} & $other->{s0}){
              $last->{s0}==$other->{s0} || die "newpairs: s0/s0 are different\n";
            }
            if($last->{s0} & $other->{s1}){
              $last->{s0}==$other->{s1} || die "newpairs: s0/s1 are different\n";
            }
            if($last->{s1} & $other->{s1}){
              $last->{s1}==$other->{s1} || die "newpairs: s1/s1 are different\n";
            }
        }
    }
    $alls0 == $alls1 || die "newpairs: total s0 /s1 different\n";
    my $result=[];
    for my $last(@allpairs){
        my $found=0;
        my $s0=$last->{s0};
        foreach my $ss(@$result){
            if($ss->[0]== $s0){ 
                $ss->[1]==$last->{s1} || die "newpairs: different s1 values\n";
                $found=$ss->[1]; last;
            }
        }
        next if($found);
        push @$result, [$last->{s0},$last->{s1}];
        push @$result, [$last->{v0},$last->{v1}];
    }
    # check if it really gives anything new
    $allv=0;
    foreach my $p(@$result){
       if($p->[0]!=$p->[1]){ $allv=1; last; }
    }
    if($allv==0){ return []; } # nothing new
    return $result;
}

sub apply_symmetries {
    my($info)=@_;
    my $sm=$info->{symms};
    my $nsm=-1+scalar @$sm;
    ## handle only symmetries with index >=1
    return if($nsm <1);
    my %pairs=();
    for my $idx(1 .. $nsm){
        my $s=$sm->[$idx]; # this is an array of pairs
        my $N=scalar @$s; # how many elements does it have
        $N >1 || die "spply_symmetries: $N is small (idx=$idx)\n";
        for my $AA(1 .. (-2+(1<<$N))){
            my($i,$A,$v0,$v1)=(0,$AA,0,0);
            while($A){
                if($A&1){ $v0 |= $s->[$i]->[0]; $v1 |= $s->[$i]->[1]; }
                $A>>=1; $i++;
            }
            next if($v0==$v1);
            $v0>0 && $v1>0 || die "apply_symmetries: vars $v0,$v1\n";
            if($v1<$v0){my $t=$v0; $v0=$v1,$v1=$t;}
            next if($pairs{"$v0,$v1"});
            $pairs{"$v0,$v1"}=1;
            makeEQ($info,$v0,$v1);
        }
    }
}


########################################################################

sub nextperm { # next permutation of $info->{perm} starting at $from
    my ($info,$from,$to)=@_;
    if($from >= $to){ return 0; }
    my $p=$from+1; my $t;
    if(nextperm($info,$p,$to)){ return 1; }
    if($info->{perm}->[$from] > $info->{perm}->[$p]){ return 0; }
    my $q=$to; while($p<$q){ 
        $t=$info->{perm}->[$p];
        $info->{perm}->[$p]=$info->{perm}->[$q];
        $info->{perm}->[$q]=$t; $p++; $q--;
    }
    $p=$from+1; $t=$info->{perm}->[$from];
    while($t>$info->{perm}->[$p]){$p++;}
    $info->{perm}->[$from]=$info->{perm}->[$p]; $info->{perm}->[$p]=$t;
    return 1;
}

sub makeSubsetsEQ { ## xB=yB for all subsets of A
    my($info,$x,$y,$A)=@_;
    return if($x==$y);
    for my $B(0 .. $A){
        next if(($B & ~$A) || ($x|$B)==($y|$B) );
        makeEQ($info,$x|$B,$y|$B);
    }
}

sub symmetry { # handle the actual permutation
    # $x: first value, $y: second value, $i: index where I am; initially it is zero
    my($info,$PN,$i,$x,$y)=@_;
    my $permi=$info->{perm}->[$i];
    if($i==$PN){ # last step
        if($permi==$PN){ # go over all subsets of $X \cup $Y
             makeSubsetsEQ($info,$x,$y,$info->{X}|$info->{Y});
             return;
        } else { # $Y goes to $permi
             my $pairs=$info->{par}->[$permi]->[0]->{pairs};
             foreach my $pr(@$pairs){
                 makeSubsetsEQ($info,$x|$pr->[1],$y|$pr->[0],$info->{X});
             }
        }
    } elsif($permi==$PN){
        my $pairs=$info->{par}->[$i]->[0]->{pairs};
        foreach my $pr(@$pairs){
            symmetry($info,$PN,$i+1,$x|$pr->[0],$y|$pr->[1]);
        }
    } else {
        my $pairs=$info->{SYMM}->{"$i,$permi"};
        foreach my $pr(@$pairs){
            symmetry($info,$PN,$i+1,$x|$pr->[0],$y|$pr->[1]);
        }
    }
}

sub paste { # rst = (ab)c|d : uv
    my($info,$dsc)=@_;
    if(! defined $info->{vars} ){$info->{vars} = 0xf; }
    if(! defined $info->{symms} ){$info->{symms}=[]; } # symmetries so far
    _initialize_trans($info);
    if(! defined $info->{paste} ){$info->{paste}=(); }
    if($dsc !~ /^\s*([rstuvw]+)=([[abcdrstuvw\(\)\|]+):([abcdrstuvw]*)\s*$/ ){
        return "copy: wrong syntax ($dsc)";
    }
    my ($new,$old,$X,$vars)=($1,$2,cv($3),$info->{vars});
    if(cv($new) & $vars){
        return "copy: new variable in \"$new\" already defined ($dsc)";
    }
    if(($X&$vars)!=$X){
        return "copy: over variable in \"".name($X)."\" not defined ($dsc)";
    }
    $info->{par}=[]; # parallel definitions
    my $defs=[]; # $defs[]={v=> 32, r=>"16|1"};
    my $Z=0; # pasted variables
    my $newvars=0;
    while($new){
        if($old =~ s/^\|// ){
            return "copy: wrong parallel | symbol ($dsc)" if(0 == scalar @$defs);
            push @{$info->{par}}, $defs;
            $defs=[];
            next;
        }
        $new =~ s/^(.)//; my $v=cv($1);
        if($v==0 || ($v&$newvars)){
            return "copy: new variable is doubly defined ($dsc)";
        }
        $newvars |= $v;
        my $r=0;
        if( $old =~ s/^([abcdrstuvw])// ){
            $r=cv($1);
        } elsif( $old =~ s/^\(([abcdrstuvw]+)\)// ){
            $r=cv($1);
        } else {
           return "copy: syntax of copy variable ($dsc)";
        }
        $Z = $Z|$r; 
        if(($r&$vars)!=$r){
            return "copy: copy variable in \"".name($r). "\"not defined ($dsc)";
        }
        if($r&$X){
            return "copy: copy variable \"".name($r)."\" and over variables overlap ($dsc)";
        }
        push @$defs, {v=>$v, r=> $r };
    }
    if($old){
        return "copy: extra copy variable \"$old\" ($dsc)";
    }
    return "copy: wrong parallel | symbol ($dsc)" if(0 == scalar @$defs);
    push @{$info->{par}},$defs;
    my $Y= $vars & ~$X; # copied variables
    my $PN=scalar @{$info->{par}}; # at least one 
    ## take care of new symmetries. Do it only when $PN==1
    ####################################################
    my $oldsyms=$info->{symms}; $info->{symms}=[];
    if($PN==1){ # only if no parallel extension
        my @newsymm=();
        for( my $i=1; $i<=$X; $i<<=1){ # this is the new symmetry
             next if(($i&$X)==0);
             push @newsymm, [$i,$i];
        }
        foreach my $t(@{$info->{par}->[0]}){
             push @newsymm, [$t->{v},$t->{r}];
             push @newsymm, [$t->{r},$t->{v}];
        }
        push @{$info->{symms}},\@newsymm;
        # go over all old symmetries and apply the new ones
        foreach my $symm(@$oldsyms){
           next if(! checkM($X,$symm)); # does it keep $X ?
           my $ns=newpairs($info->{par}->[0],$symm);
           next if(0 == scalar @$ns);
           # supplement $ns with those keeping $X
print "FOUND NEW\n";
           foreach my $s(@$symm){
              next if(0==($X & $s->[0]));
              push @$ns,$s;
           }
           push @{$info->{symms}},$ns;
        }
        # now $info-{symms} contains all symmetries.
        # apply all of them, except for the very first one
        apply_symmetries($info);
    }
    ############################################################
    # now we have all parallel requests in @par
    foreach my $cp (@{$info->{par}}){
        my $allv=0;
        foreach my $h(@$cp){ $allv |= $h->{v}; }
        $cp->[0]->{allv}=$allv;
        # for each subset S of $allv create an entry  [ S, r(S) ]
        my $pairs=[]; push @$pairs, [0,0];
        foreach my $S(1 .. $allv){
           next if( $S& ~$allv); # not a subset
           my $RS=0; foreach my $h(@$cp){ 
              $RS |= $h->{r} if($S&$h->{v});
           }
           push @$pairs, [$S,$RS];
        }
        $cp->[0]->{pairs}=$pairs;
    }
    # $par[???]->[0] = { allv => new variables; pairs => [] }
    # independence: (A,B|X)=0; where A, B are variables in $Y cup $newvars
    #   and no $par[???]->[0]->{allv} indersects both A and B
    my $overvars = $Y | $newvars; my $full=(1<<($PN+1))-1;
    my @inC = (0) x ($overvars+1); my $pidx=1;
    foreach my $cp(@{$info->{par}}){
       foreach my $h(@$cp){ $inC[$h->{v}]=$pidx; }
       $pidx<<=1;
    }
    for (my $i=1; $i<= $Y; $i<<=1){
       next if(($i&$Y)==0); # not a new variable
       $inC[$i]=$pidx;
    }
    for my $subset(1 .. $overvars){
       if($subset & ~$overvars){ # not a subset of
          $inC[$subset]=$full;
       } else {
          for(my $i=1;$i<=$subset;$i<<=1){
              if($i&$subset){$inC[$subset] |= $inC[$i]; }
          }
       }
    }
    foreach my $A(1 .. $overvars){
       my $CA=$inC[$A];
       next if($CA==$full);
       foreach my $B($A .. $overvars){
          next if($CA & $inC[$B]);
          makeEQ($info,$A|$B|$X,$A|$X,$B|$X,$X);
       }
    }
    # Symmetry: for each index pair [i,j] create an array of all matching subsets
    #   it contains at least [0,0], and symmetric in (i,j).
    $info->{SYMM}={};
    for my $i(0 .. $PN-1){ for my $j(0 .. $PN-1){
       if($i==$j){
          my $pp=[];
          foreach my $p(@{$info->{par}->[$i]->[0]->{pairs}}){
             push @$pp, [$p->[0],$p->[0]];
          }
          $info->{SYMM}->{"$i,$j"}=$pp;
       } else {
          my $pp=[]; my $paj=$info->{par}->[$j]->[0]->{pairs};
          foreach my $p(@{$info->{par}->[$i]->[0]->{pairs}}){
             # check if $p->[1]== $q->[1]; if yes, put [$p->[0],$q->[0]]
             foreach my $q(@$paj){
                next if($p->[1]!=$q->[1]);
                push @$pp, [$p->[0],$q->[0]];
                last;
             }
          }
          $info->{SYMM}->{"$i,$j"}=$pp;
       }
    }}
###########################################################
    # generate all permutations of [0 .. $PN]
    # X: over variables, Y: complement of X ($PN goes over all subsets of Y)
    $info->{X}=$X; $info->{Y}=$Y; $info->{PN}=$PN;
    $info->{perm}=[];
    for my $i(0 .. $PN){ $info->{perm}->[$i]=$i; }
    while(nextperm($info,0,$PN)){ symmetry($info,$PN,0,0,0); }
# =================================================================================
    # check if $X is a flat; existing variables are in $vars
    if($CHECKFLATS){
      for (my $i=1; $i<$vars;$i<<=1){
          next if(($X|$i)==$X || ($i&$vars)==0 );
          if(checkeq($info,$X|$i,$X)){ # they are equal
             return "copy: \"".name($X)."\" is not a flat, you can add ".name($i)." to it ($dsc)";
          }
      }
    }
    $info->{vars} |= $newvars;
    ##
    # check for consequences: if Ai=A then Aij=Aj (and iterate)
    # if Aij=A then Ai=Aj=A
    # if Aijk-Ajk=Ai-A, then Aij-Aj=Ai-A (and iterate)
    my $done=0; $vars=$info->{vars};
    while($done==0){ $done=1;
       for my $A(0 .. $vars){
         for(my $i=1;$i<$vars;$i<<=1){
           next if(($A&$i)!=0 || ($i&$vars)==0);
           my $oldtr=$info->{trn};
           if(checkeq($info,$A|$i,$A)){
             for(my $j=1; $j<$vars;$j<<=1){
                next if(($A&$j)!=0 || $i==$j || ($j&$vars)==0);
                makeEQ($info,$A|$i|$j,$A|$j);
             }
           }
           for(my $j=1; $j<$vars;$j<<=1){
#            for my $j(1 .. $vars){
              next if((($A|$i)&$j)!=0 || ($j&$vars)!=$j);
              if(checkeq($info,$A|$i|$j,$A)){
                  makeEQ($info,$A|$i,$A); makeEQ($info,$A|$j,$A);
              }
              for(my $k=1;$k<$vars;$k<<=1){
#              for my $k(1 .. $vars){
                 next if((($A|$i|$j)&$k)!=0 || ($k&$vars)!=$k);
                 if(checkeq($info,$A|$i|$j|$k,$A|$j|$k,$A|$i,$A)){
                    makeEQ($info,$A|$i|$j,$A|$j,$A|$i,$A);
                 }
              }
           }
           if($oldtr<$info->{trn}){ $done=0; }
         }
       }
    }
    return "";
}

sub _collapse_vars {
    my($info)=@_;
    $info->{vidx}=();
    my $tr=$info->{trans}; my $vars= $info->{vars};
    $info->{vidx}[0]=-1;
    my $j=0; for my $i(1 .. 15){
       if($ZERONAT[$i-1]!=0){$info->{vidx}[$i]=-1; }
       else { $info->{vidx}[$i]=$j; $j++; }
    }
    for my $i(16..1023){
       if(($i&$vars)==$i && !defined $tr->[$i]){
           $info->{vidx}[$i]=$j; $j++;
       } else {
           $info->{vidx}[$i]=-1;
       }
    }
    $info->{rows}=$j;
}

sub make_paste {
    my($paste,$syntax)=@_;
    $paste="" if(!defined $paste);
    $paste =~ s/\s//g; 
    my $info={ pastestr => $paste}; $info->{errs}=();
    my $e=""; my $nopaste=1;
    foreach (split(';',$paste)){
         next if( /^\s*$/ || $e);
         $nopaste=0;
         if( /^\s*([abcdrstuvw]+=[\|\(\)abcdrstuvw:]+)\s*$/ ){
            $e=paste($info,$1);
            if($e){ push @{$info->{errs}},$e; }
         } else {
            push @{$info->{errs}}, "copy: wrong format $_";
         }
    }
    if($nopaste){
        push @{$info->{errs}}, "no copy was defined at all";
    }
    if(!defined $info->{errs} && !$syntax){
         _collapse_vars($info);
         _generate_ineqs($info);
    }
    return $info;    
}

##########################################################################

my $info=make_paste($paste);
if(defined $info->{errs}){
    if(!$quiet){
       print "There was an error in the copy string:\n",join("\n",@{$info->{errs}}),"\n";
    }
    exit 1;
}

if($chkfile<0){ exit 0; }

if($chkfile && -e $file ){ # check it again 
    print "File $file exists. Continue (y/n)? ";
    my $ans=<stdin>;
    if($ans !~ /^y/i ){ exit 0; }
}

#=========================================================================================

my $Q=$info->{ineq};
my $rows=scalar @{$Q->[0]->{coeffs}};
my $cols = scalar @$Q;
my $arows=0; for my $j($full+1..$rows-1){
    $arows++;
}
## row 0 : ingleton row;
## row 1..$full: matrix P
## rows $full+1..$rows-1: matrix A
my $nonzeroa=0; my $nonzerop=0;
for my $j(0..$rows-1){ 
    for my $i(0..$cols-1){
    if($Q->[$i]->{coeffs}->[$j]){
        if(1<=$j && $j<=$full){ $nonzerop++; }
        else { $nonzeroa++;  }
    }}
}
open(FILE,">$file") || die "Cannot open $file for writing\n";
## cols, a-rows, p-rows, Ingleton row (0) 
print FILE "c copy string: $paste\n";
print FILE "p vlp min ",
      $arows+1,      # number of total rows
      " ",$cols,     # number of columns
      " ",$nonzeroa, # nonzero elements in a
      " ",$full,     # number of objectives
      " ",$nonzerop, # nonzero elements in objectives
      "\n";
## variable types: 1..$cols: non-negative
for my $i(1..$cols){
    print FILE "j $i l 0\n";
}
## constraint types: 1: ==1, others: ==0
for my $j(1..$arows+1){
    print FILE "i $j s ",($j==1?1:0),"\n";
}
## the matrix a 
## the Ingleton row
for my $i(0..$cols-1){
    my $v=$Q->[$i]->{coeffs}->[0];
    next if(!$v);
    print FILE "a 1 ",$i+1," $v\n";
}
## A rows
my $j=1;
for my $jj ($full+1..$rows-1){
  $j++;
  for my $i(0..$cols-1){
    my $v=$Q->[$i]->{coeffs}->[$jj];
    next if(!$v);
    print FILE "a $j ",$i+1," $v\n";
}}
## print the objectives
for my $j (1..$full){
  for my $i(0..$cols-1){
    my $v=$Q->[$i]->{coeffs}->[$j];
    next if(!$v);
    print FILE "o $j ",$i+1," $v\n";
}}
print FILE "e\n\n";
close(FILE);

exit 0;


