#!/usr/bin/perl -w
##
## generate a vlp file from a copy string
##
## arguments: <copy_string> <filename>

use strict;

sub print_usage {
    print "Usage: mkvlp.pl  [fx] <copy string> <filename>\n",
          "   f -- full (10), default\n",
          "   x -- truncated to 8\n";
    exit 1;
}


if(scalar @ARGV ==0 || $ARGV[0] =~ /^\-[\-]?h/ ){ print_usage(); }

my ($full,$paste,$file)=("","","");
if($ARGV[0] =~ /^[\-]?([xf])/ ){
    $full=$1; $paste=$ARGV[1]; $file=$ARGV[2];
} else {
    $paste=$ARGV[0]; $file=$ARGV[1];
}
$full="f" if(!$full);
$full=substr($full,0,1);
$full = $full eq "f" ? 10 : $full eq "x" ? 8 : 0;
if(!$paste || !$file || !$full ){ print_usage(); }

##########################################################################
#
# Natural coordinates:
# "[]", "(a,b|c)","(a,c|b)","(b,c|a)","(a,b|d)","(a,d|b)","(b,d|a)",
#       "(c,d|a)","(c,d|b)","(c,d)","(a,b|cd)",
#       "(a|bcd)","(b|acd)","(c|abd)","(d|abc)",
#

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

sub zero_eqs {
    my($e,$len)=@_;
    if(!$len){ $len = scalar @$e; }
    for my $i(0..$len-1){ $e->[$i]=0; }
}

sub _hash_eqs {
    my $e=shift; my $hash="";
    for my $i (0..scalar @$e-1){ 
        $hash .= ",$e->[$i]"; 
    }
    $hash;
}

sub add_eqs { ## $e->[$var] += $d;
    my($info,$e,$var,$d)=@_;
    return if($var==0);
    my $idx;
    if($var<16){ # subset of abcd
        $idx=(MAINV)[$var];
        for my $i(0..14){
           $e->[$i] += $d*$idx->[$i];
        }
        return;
    }
    $idx = $info->{trans}[$var];
    if(defined $idx ){ # redefined
        foreach my $sss (keys %$idx ){
            add_eqs($info,$e,$sss,$d*$idx->{$sss});
        }
        return;
    }
    $e->[$info->{vidx}[$var]] += $d;
}

sub _store_ineq {
    my ($info,$e,$desc)=@_;
    my $cf=[];
    for my $i(0..$info->{rows}-1){$cf->[$i]=$e->[$i]; }
    push @{$info->{ineq}}, { coeffs => $cf, desc => $desc };
}

sub _generate_ineqs {
    my ($info)=@_;
    $info->{ineq}=[]; ## empty list
    my $vars=$info->{vars}; my $h;
    my $eqs=[]; my %hash=(); ## equations, hash of equations
    zero_eqs($eqs,$info->{rows}); $hash{_hash_eqs($eqs)}=1;
    for my $i(0..15){
        zero_eqs($eqs,$info->{rows}); $eqs->[$i]=1; $hash{_hash_eqs($eqs)}=1;
    }
    for my $A (0..1023){ ## long equations
        next if (($A&$vars) != $A );
        for (my $i=1;$i&1023; $i=$i<<1){
            next if(($i&$vars)==0 || $A==($A|$i));
            for (my $j=$i; $j&1023; $j=$j<<1){
                 next if(($j&$vars)==0 || $j==$i || $A==($A|$j));
                 zero_eqs($eqs,$info->{rows});
                 add_eqs($info,$eqs,$A|$i,1); add_eqs($info,$eqs,$A|$j,1);
                 add_eqs($info,$eqs,$A,-1); add_eqs($info,$eqs,$A|$i|$j,-1);
                 $h=_hash_eqs($eqs);
                 next if(defined $hash{$h}); $hash{$h}=1;
                 ## check if it has ones only at the first 15 positions...
                 my $ok=0;
                 for my $k(0..$info->{rows}-1){$ok=1 if($eqs->[$k]); }
                 next if(!$ok);
                 _store_ineq($info,$eqs,[$A,$i,$j]);
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

sub makeEQ {
    my($info,$x,$b,$c,$d)=@_;
    my $g=[]; 
    putto($info,$x,1,$g); putto($info,$b,-1,$g); 
    putto($info,$c,-1,$g); putto($info,$d,1,$g);
    my $n=-1+scalar @$g;
    while($n>=0 && ! $g->[$n]){ $n--; } # get the first non-zero item
    return if ($n<=0); # not found
    if( defined $info->{trans}[$n]){
       die "wrong: trans is defined at $n\n";
    }
    my $gn=$g->[$n];
    my %t=();
    for my $i(0..$n-1){
        next if(! $g->[$i]);
        $t{$i}= $gn==-1 ? $g->[$i] : $gn==1 ? -$g->[$i] : (-$g->[$i]/($gn+0.0));
    }
    $info->{trans}[$n]=\%t;
}

sub paste { # rst = (ab)cd : uv
    my($info,$dsc)=@_;
    if(! defined $info->{vars} ){$info->{vars} = 0xf; }
    if(! defined $info->{trans} ){$info->{trans} = (); 
        $info->{tight}=1; # it is tight so far 
    }
    if(! defined $info->{paste} ){$info->{paste} = (); }
    if($dsc !~ /^\s*([rstuvw]+)=([[abcdrstuvw\(\)]+):([abcdrstuvw]*)\s*$/ ){
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
    my $Z=0; # pasted variables
    my $newvars=0;
    while($new){
        $new =~ s/^(.)//; my $v=cv($1);
        if($v==0 || ($v&$newvars)){
            return "copy: new variable is doubly defined ($dsc)";
        }
        $newvars |= $v;
        my $r=0;
        if( $old =~ s/^([abcdrstuvw])// ){
            $r=cv($1);
        } elsif( $old =~ s/^\(([abcdrstuvw]+)\)// ){
            $r=cv($1); $info->{tight}=0; # not tight anymore
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
        push @defs, {v=>$v, r=> $r };
    }
    if($old){
        return "copy: extra copy variable \"$old\" ($dsc)";
    }
    $info->{vars} |= $newvars;
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
              makeEQ($info,$vv|$B,$rr|$B);
           }
        }
        for my $B(1..$Y){
            next if($B & ~$Y); ## $B is not a subset of $Y
            makeEQ($info,$v|$B|$X,$v|$X,$B|$X,$X);
        }
    }
    return "";
}

sub _collapse_vars {
    my($info)=@_;
    $info->{vidx}=();
    my $tr=$info->{trans}; my $vars= $info->{vars};
    $info->{vidx}[0]=-1;
    for my $i(1..15){$info->{vidx}[$i]=$i-1;}
    my $j=15; for my $i(16..1023){
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
    my $info={ pastestr => $paste }; $info->{errs}=();
    my $e=""; my $nopaste=1;
    foreach (split(';',$paste)){
         next if( /^\s*$/ || $e);
         $nopaste=0;
         if( /^\s*([abcdrstuvw]+=[\(\)abcdrstuvw:]+)\s*$/ ){
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
    print "There was an error in the copy string:\n",join("\n",@{$info->{errs}}),"\n";
    exit 1;
}

if( $file !~ /\.vlp$/ ){
    print "The output file name should end with '.vlp'\n";
    exit 1;
}

if(-e $file ){
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

