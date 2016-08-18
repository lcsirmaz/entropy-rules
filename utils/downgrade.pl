#!/usr/bin/perl -w
##
## check a result file for new inequalities. Truncate large coeffs.
##
## arguments: [-t <threshold>] <result> <file1> <file2> ...
##
##   <threshold> is the maximal value of (normalized) coeffs.
##   <result> is a file where each checked line looks like this:
## V 1/2 7/6 5/6 1/2 3/2 1/6 0 0 0 0
##    these are natural coeffs 2..11, the Ingleton coeff is 1
##
##   <file1>, <file2>, ... contain known inequalities in the form
## 2, 1,4,1, 2,5,0, 0,0,0,0, rs=cd:ab;t=c:abrs;u=a:dst, copy:1:24
##   where the numbers are the coefficients.
## Only inequalities which do not follow from the given ones are
## printed.
##

use strict;

# threshold value, start of <ineq?> arguments
my $ths=1000; my $ARGZ=0;

sub print_usage {
    print "Usage: downgrade.pl [-s <supd>] [-t <threshold>] <result> <ineq1> <ineq2> ...\n",
          "   <supd> is the list of superseded inequalities (speeds up checking)\n",
          "   <threshold> is the maximal valur for (integer) coeffs\n",
          "   <result> contains the vertices to be checked\n",
          "   <ineq?> files contain known entropy inequalities\n",
          "The result file should be XXXX.res, and the first line\n",
          "of XXXX.vlp should contain the copy string. The label\n",
          "is the basename of the result file. Rounded coeffs are\n",
          "marked by an *\n";
    exit 1;
}
###################################################################
## compute the lexicographically maximal version
sub swap_ab { # 2<->3, 5<->6, 7<->8
    my $a=shift; my $t;
    $t=$a->[2]; $a->[2]=$a->[3]; $a->[3]=$t;
    $t=$a->[5]; $a->[5]=$a->[6]; $a->[6]=$t;
    $t=$a->[7]; $a->[7]=$a->[8]; $a->[8]=$t;
}
sub swap_cd { # 1<->4, 2<->5, 3<->6
    my $a=shift; my $t; 
    $t=$a->[1]; $a->[1]=$a->[4]; $a->[4]=$t;
    $t=$a->[2]; $a->[2]=$a->[5]; $a->[5]=$t;
    $t=$a->[3]; $a->[3]=$a->[6]; $a->[6]=$t;
}
sub smaller {
    my ($a,$b)=@_;
    for my $i(0..10){
        next if($a->[$i]==$b->[$i]);
        return $a->[$i]<$b->[$i] ? 1 : 0;
    }
    return 0;
}
sub biggest {
    my $a=shift;
    my $b=[]; for my $i(0..10){ $b->[$i]=$a->[$i]; }
    swap_ab($b); if(smaller($a,$b)){
        for my $i(0..10){$a->[$i]=$b->[$i]; }
    }
    swap_cd($b); if(smaller($a,$b)){
        for my $i(0..10){$a->[$i]=$b->[$i]; }
    }
    swap_ab($b); if(smaller($a,$b)){
        for my $i(0..10){$a->[$i]=$b->[$i]; }
    }
}
###############################################################
## compute lcm of denominators
sub gcd {
    my($a,$b)=@_;
    return $b if($a==0 || $a==$b);
    return $a if($b==0);
    return $a<$b ? gcd($b%$a,$a) : gcd($a%$b,$b);
}
sub lcm {
    my($a,$b)=@_;
    return $a*int($b/gcd($a,$b)+0.01);
}
###############################################################
## round down the coefficients
## find out the multiplier which gives the smallest L1 norm
sub comp_l1{
    my($idx,$arr)=@_;
    my $v=0.0; my $coeff=($idx+0.0)/($arr->[0]+0.0);
    for my $i(1..10){
        my $s=$arr->[$i]*$coeff;
        $s = int($s+1.0-1e-7) - $s; ## round up
        if($s<-1e-7) { $s+=1.0; } elsif($s<0){$s=0;}
        $v+=$s;
    }
    return $v/$idx;
}

## downgrade
sub downgrade { # $arr[0..10], $new[0..10]
    my($arr,$new)=@_;
    my $max=1.0;
    for my $i(1..10){ my $v=($arr->[$i]+0.0)/($arr->[0]+0.0); $max=$v if($max<$v); }
    my $upto = int(1e-7+($ths+0.0)/($max+0.0));
    return 0 if($upto<1); ## cannot downgrade
    my $L1=1000.0; my $ing=0;
    for my $i(1..$upto){
        my $newl1=comp_l1($i,$arr);
        if($ing<1 || $newl1<$L1){$ing=$i; $L1=$newl1; }
    }
    $new->[0]=$ing; my $cf=($ing+0.0)/$arr->[0];
    for my $i(1..10){
        my $s=$arr->[$i]*$cf;
        my $is=int($s+1.0-1e-7); if($is-$s<-1e-7){$is++;}
        $new->[$i]=$is; }
    # check if the downgraded inequality is superseded by one of the known ones
    # 1, 1,1,1, 0,0,0, 0,0,0,0 (ZY)
    return 0 if($new->[1]>=$new->[0] && $new->[2]>=$new->[0] && $new->[3]>=$new->[0]);
    # 2, 1,3,2, 0,0,0, 0,0,0,0
    return 0 if(2*$new->[1]>=$new->[0] && 2*$new->[2]>=3*$new->[0] && $new->[3]>=$new->[0]);
    # 2, 3,2,1, 0,0,0, 0,0,0,0
    return 0 if(2*$new->[1]>=3*$new->[0] && $new->[2]>=$new->[0] && 2*$new->[3]>=$new->[0]);
    # 3, 1,5,5, 0,0,0, 0,0,0,0
    return 0 if(3*$new->[1]>=$new->[0] && 3*$new->[2]>=5*$new->[0] && 3*$new->[3]>=5*$new->[0]);
    # 3, 5,5,1, 0,0,0, 0,0,0,0
    return 0 if(3*$new->[1]>=5*$new->[0] && 3*$new->[2]>=5*$new->[0] && 3*$new->[3]>=$new->[0]);
    return 1;
}

###############################################################
## read in the result file
sub lexmin {
    my($a,$b)=@_;
    for my $i(0..10){
       my $d=$a->[$i]-$b->[$i];
       if($d){ return $d<0 ? -1 : +1 ; }
    }
    return 0;
}
sub read_result_file {
    my ($info,$fname)=@_;
    $info->{new}=();
    my @lines=();
    open(FILE,$fname) || die "Cannot open result file $fname for reading\n";
    while(<FILE>){
      next if(!/^V/);
      chomp;
      my $line=$_;
      my @v=split(/\s+/,$line);
      scalar @v==11 || die "Wrong vertex line in file $fname:\n  $line\n";
      my $d=1;
      for my $i(1..10){
          if($v[$i] =~ /^\d+\/(\d+)$/) { $d=lcm($d,$1); }
      }
      my @a=(); $a[0]=$d; my $downgrade=$d>$ths ? 1 : 0;
      for my $i(1..10){
          if($v[$i] =~ /^\d+$/ ){ 
              $a[$i]=$d*$v[$i]; 
              $downgrade=1 if($a[$i]>$ths);
          } elsif( $v[$i] =~ /^(\d+)\/(\d+)$/ ){
              $a[$i]=int($1*$d/$2+0.01);
              $downgrade=1 if($a[$i]>$ths);
          } else {
             $downgrade=1;
             $a[$i]=$d*(0.0+$v[$i]);
          }
      }
      biggest(\@a);  ## make it lexicographically maximal
      if($downgrade){
          my $new=[];
          next if(!downgrade(\@a,$new));
          $new->[11]="*";
          push @lines, $new;
      } else {
          push @lines, \@a;
      }
    }
    close(FILE);
    foreach my $a (sort {lexmin($a,$b)} @lines ){
      push @{$info->{new}}, $a;  ## and store it
    }
}

## read known inequalities
my %supplist=();

sub read_supplist {
    my $file=shift;
    open(FILE,$file) || die "Cannot open supserseded file $file\n";
    my $cnt=0;
    while(<FILE>){
        next if(!/^superseded: [^\s]+\/([^\s]+) by/);
        $supplist{$1}=1;
        $cnt++;
    }
    close(FILE);
#    die "No superseded items found in $file\n" if($cnt==0);
}

sub read_ineq_file {
    my ($info,$fname)=@_;
    $info->{old}=() if(!defined $info->{old});
    open(FILE,$fname) || die "Cannot open inequality file $fname for reading\n";
    while(<FILE>){
      next if(!/^\s*\d+,/ ); # comment lines
      chomp; my $line=$_;
      my @a=split(/,\s*/,$line);
      scalar @a>=11 || die "Wrong data line in inequality file $fname:\n  $line\n";
      next if(defined $a[13]); ## 'S'
      next if(defined $a[12] && defined $supplist{$a[12]});
      biggest(\@a);    ## make it lexocographically maximal
      push @{$info->{old}}, \@a; ## and store
    }
    close(FILE);
}

################################################################
## generate all relevant permutation of inequalities
sub not_the_same {
    my($a,$b)=@_;
    for my $i(0..10){
       return 1 if($a->[$i]!=$b->[$i]);
    }
    return 0;
}
sub generate_matrix {
    my ($info)=@_;
    return if($info->{array});
    my @array=();
    foreach my $a(@{$info->{old}}){
        next if( scalar @$a>13 && $a->[13] ); # superseded
        my(@a1,@a2,@a3,@a4);
        for my $i(0..10){
           $a1[$i]=$a2[$i]=$a3[$i]=$a4[$i]=$a->[$i]; 
        }
        swap_ab(\@a2); swap_cd(\@a3); swap_ab(\@a4); swap_cd(\@a4);
        push @array, \@a1;
        push @array, \@a2 if(not_the_same(\@a1,\@a2));
        push @array, \@a3 if(not_the_same(\@a1,\@a3) && not_the_same(\@a2,\@a3));
        push @array, \@a4 if(not_the_same(\@a1,\@a4) &&
                 not_the_same(\@a2,\@a4) && not_the_same(\@a3,\@a4));
    }
    $info->{array}=\@array;
    $info->{rows}=11;
    $info->{cols} = scalar @array;
    $info->{nonzero}=0;
    foreach my $a(@array){
       for my $i(0..10){
           $info->{nonzero}++ if($a->[$i]);
       }
    }
}
sub add_to_matrix {
    my($info,$a)=@_;
    my(@a1,@a2,@a3,@a4);
    for my $i(0..10){
       $a1[$i]=$a2[$i]=$a3[$i]=$a4[$i]=$a->[$i]; 
    }
    swap_ab(\@a2); swap_cd(\@a3); swap_ab(\@a4); swap_cd(\@a4);
    push @{$info->{array}}, \@a1;
    $info->{cols}++;
    for my $i(0..10){ $info->{nonzero}++ if($a1[$i]); }
    if(not_the_same(\@a1,\@a2)){
        push @{$info->{array}}, \@a2;
        $info->{cols}++;
        for my $i(0..10){ $info->{nonzero}++ if($a2[$i]); }
    }
    if(not_the_same(\@a1,\@a3) && not_the_same(\@a2,\@a3)){
        push @{$info->{array}}, \@a3;
        $info->{cols}++;
        for my $i(0..10){ $info->{nonzero}++ if($a3[$i]); }
    }
    if(not_the_same(\@a1,\@a4) && not_the_same(\@a2,\@a4) && not_the_same(\@a3,\@a4)){
        push @{$info->{array}}, \@a4;
        $info->{cols}++;
        for my $i(0..10){ $info->{nonzero}++ if($a4[$i]); }
    }
}
################################################################
## check if an inequality is simply superseded
sub is_superseded {
    my ($info,$a)=@_;
    my @v;
    for my $i(1..10){
        $v[$i]=$a->[$i]/$a->[0]+1e-9;
    }
    foreach my $x(@{$info->{old}}){
        my $above=1; my $i=1;
        while($above && $i<11){
           $above=0 if($v[$i]*$x->[0]<$x->[$i]);
           $i++;
        }
        return 1 if($above);
    }
    return 0;
}
sub generate_vlp {
    my($info,$a)=@_;
    my $tmpname=`mktemp -q /tmp/chk_XXXXXX.vlp`; chomp $tmpname;
    open(VLP,">$tmpname") || die "Cannot create temporary file $tmpname\n";
     print VLP "C checking whether an inequality is new\n";
     print VLP "p vlp min",
         " ",$info->{rows},    # number of rows
         " ",$info->{cols},    # columns
         " ",$info->{nonzero}, # nonzero coeffs
         " ",1,                # number of objectives
         " ",0,                # nonzero elements in objectives
         "\n";
     # variable types: 1..cols: non-negative
     for my $j(1..$info->{cols}){
       print VLP "j $j l 0\n";
     }
     # constraint types: 1 ==, others are <=
     for my $i(1..$info->{rows}){
       print VLP "i $i ", ($i==1 ? "s ":"u "),$a->[$i-1],"\n";
     }
     # the matrix
     for my $i(0..$info->{rows}-1){ for my $j(0..$info->{cols}-1){
       my $v=$info->{array}->[$j]->[$i]; 
       print VLP "a ",$i+1," ",$j+1," $v\n" if($v);
     }}
     print VLP "e\n\n";
    close(VLP);
    return $tmpname;
}
################################################################
## find out the copy string
sub find_copy {
    my($info,$fname)=@_;
    $info->{copy}="[none]";
    $info->{id}="[none]:";
    $fname =~ s/\.res$/.vlp/;
    if(open(FILE,$fname)){
        my $a=<FILE>; close(FILE);
        chomp($a);
        if($a=~/^c copy/){
            $a=~ s/^.*string: //; $info->{copy}="$a"; $info->{id}="copy:";
            if($a =~ s/; ineq:.*//){
                $a =~ s/,/./g;
                $info->{copy}=$a; $info->{id}="drule:";
            }
            $info->{copy} =~ s/;$//;
        } elsif( $a=~/rule (\d.+) for/){
            $info->{copy} = "rule$1"; $info->{id}="rule:";
        }
    }
    if($fname =~ /iter([2-9])/ ){
        $info->{id} .= "$1."; 
    } else {
        my $thisdir=`pwd`;
        $info->{id} .= "$1." if( $thisdir =~ /iter([2-9])/ );
    }
    $fname =~ /([a-z\d]+)\.vlp$/;
    $info->{id} .= $1;
}
################################################################
##
my $info={};

if(scalar @ARGV < 2){ print_usage(); }

$ARGZ=0;
while(1){
  if($ARGV[$ARGZ] eq "-s"){
    if(scalar @ARGV<4){ print_usage(); }
    read_supplist($ARGV[$ARGZ+1]);
    $ARGZ+=2;
  } elsif($ARGV[$ARGZ] eq "-t"){
    if(scalar @ARGV<4+$ARGZ || $ARGV[$ARGZ+1] !~ /^\d+$/){ print_usage(); }
    $ths=0+$ARGV[$ARGZ+1]; if($ths<10||$ths>1000){ print_usage();}
    $ARGZ+=2;
  } else {
     last;
  }
}
if($ARGV[$ARGZ] !~ /\.res$/ ){
    die "First argument should be a result file endign with .res\n";
}

for my $i($ARGZ+1..-1+scalar @ARGV){
    read_ineq_file($info,$ARGV[$i]);
}
read_result_file($info,$ARGV[$ARGZ]);

find_copy($info,$ARGV[$ARGZ]);

## print "old: ",scalar @{$info->{old}},", new: ",scalar @{$info->{new}},"\n";
generate_matrix($info);
## print "done\n"; exit 3;
my $cnt=0;
foreach my $a(@{$info->{new}}){
    $cnt++;
    next if(is_superseded($info,$a));
#    print "trying: ",join(', ',@$a);
    my $vlpfile=generate_vlp($info,$a);
    system("inner -y- $vlpfile >/dev/null");
    my $e=$?>>8; # 0: superseded, 2: new
    die "Unexpected error from inner ($e)\n" if($e!=0 && $e !=2);
    unlink $vlpfile;
    next if($e==0);
    for my $i(0..10){
        print $a->[$i],","; print " " if($i==0 || $i==3 || $i==6);
    }
    print " ",$info->{copy},", ",($a->[11]?"*":""),$info->{id},":$cnt\n";
    # store it, and use it subsequently
    add_to_matrix($info,$a);
}


