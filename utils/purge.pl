#!/usr/bin/perl -w
##
## print out inequalities which follow from others
##
## arguments: <file1> <file2> ...
##
##  Each file contains known inequalities in the form
## 2, 1,4,1, 2,5,0, 0,0,0,0, rs=cd:ab;t=c:abrs;u=a:dst, paste:1:24
##  where the last part is the label
##

use strict;

sub print_usage {
    print "Usage: purge.pl <file1> <file2> ...\n",
          "  each <file> is a list of known inequalities.\n",
          "  Prints out the labels of superseded ones.\n";
    exit 1;
}

if(scalar @ARGV < 1 ){ print_usage(); }

#######################################################################
## read an inequality file
sub read_ineq_file {
    my ($info,$fname)=@_;
    $info->{old}=() if(!defined $info->{old});
    $info->{superseded}=() if(!defined $info->{supserseded});
    my $base=$fname; $base =~ s/^.*\///g; $base =~ s/\..*$//;
    open(FILE,$fname) || die "Cannot open inequality file $fname for reading\n";
    while(<FILE>){
      next if(!/^\s*\d+,/ ); # comment line 
      chomp; my $line=$_;
      my @a=split(/,\s*/,$line);
      scalar @a>=12 || die "Wrong data line in inequality file $fname:\n   $line\n";
##      if($a[13]){ print "line superseded: $line\n"; }
      if($a[13]){  # superseded ...
          $a[13]=$base;
          push @{$info->{superseded}},\@a;
      } else {
          $a[13]=$base;
          push @{$info->{old}},\@a;
      }
    }
    close(FILE);
}
####################################################################
## check if an inequality is superseded by others
sub is_superseded {
    my($info,$idx,$sded)=@_;
    my @v; my $a;
    if($sded){
        $a=$info->{superseded}[$idx];
        $idx=-1;
    } else {
        $a=$info->{old}[$idx];
    }
    for my $i(1..10){
        $v[$i]=$a->[$i]/$a->[0]+1e-9;
    }
    my $j=-1;
    foreach my $x( @{$info->{old}}){
        $j++;
        next if($j==$idx);
        my $above=1; my $i=1; 
        while($above && $i<11){
           $above=0 if($v[$i]*$x->[0]<$x->[$i]);
           $i++;
        }
        return $j if($above);
    }
    return -1;
}
####################################################################
## compute all versions of the inequality
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
sub not_the_same {
    my($a,$b)=@_;
    for my $i(0..10){
       return 1 if($a->[$i]!=$b->[$i]);
    }
    return 0;
}
####################################################################
## generate vlp file for checking whether $idx is superseded
sub generate_matrix {
    my($info,$idx)=@_;
    my @array=();
    my $j=-1;
    foreach my $a(@{$info->{old}}){
        $j++;
        next if($j==$idx);
        next if($a->[14]); ## it is superseded
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
sub generate_vlp {
    my($info,$idx,$sded)=@_;
    generate_matrix($info,$sded ? -1 : $idx);
    my $goal = $sded ? $info->{superseded}[$idx] : $info->{old}[$idx];
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
       print VLP "i $i ", ($i==1 ? "s ":"u "),$goal->[$i-1],"\n";
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
sub run_lp {
    my($info,$idx,$sded)=@_;
    my $vlpfile=generate_vlp($info,$idx,$sded);
    system("inner -y- $vlpfile > /dev/null");
    my $e=$?>>8; # 0: superseded, 2: not
    unlink($vlpfile);
    return $e==0 ? 1 : 0;
}

####################################################################
##
my $info={};
for my $i(0..-1+scalar @ARGV){ read_ineq_file($info,$ARGV[$i]); }

print "total: ",scalar @{$info->{old}},
      ",  superseded: ",scalar @{$info->{superseded}},"\n";

for my $j(0..-1+scalar @{$info->{old}}){
    my $s=is_superseded($info,$j);
    if($s>=0){
        $info->{old}[$j]->[14]="S";
        print "superseded: ",$info->{old}[$j]->[13],"/",$info->{old}[$j]->[12],
          " by ",$info->{old}[$s]->[13],"/",$info->{old}[$s]->[12],"\n";
    }
}
for my $j(0..-1+scalar @{$info->{superseded}}){
    if(is_superseded($info,$j,1)){ $info->{superseded}[$j]->[14]="S"; }
}
print "Calling LP\n";
for my $j(0..-1+scalar @{$info->{old}}){
    next if($info->{old}[$j]->[14]);
    if( run_lp($info,$j)){
        $info->{old}[$j]->[14]="S"; # superseded
        print "superseded: ",$info->{old}[$j]->[13],"/",$info->{old}[$j]->[12],
          " by  LP\n";
    }
}
for my $j(0..-1+scalar @{$info->{superseded}}){
    next if($info->{superseded}[$j]->[14]);
    if(! run_lp($info,$j,1)){
         print "NOT superseded: ",$info->{superseded}[$j]->[13],"/",$info->{superseded}[$j]->[12],
            " by LP\n";
    }
}
