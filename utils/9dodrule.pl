#!/usr/bin/perl -w
##
## 9dodrule.pl: apply a double rule for a set of inequalities
##
## arguments: <eqlist> <rule> <vlpfile>
##
## inequalities are read from <eqlist>; should be prepared 
##     not to be too large
## <rule> is a list of double 9-rules of the form
## [1,2,3,4,5,6,7,8,9] + [1,2,3,4,5,6,7,8,9] <= [1,2,3,4,5,6,7,8,9]
## written as  a_i + b_i <= c_i, these are vectors.
## The inequalities are x_j>=0.
## The problem can be worded as follows.
##   variables are u_j, v_j, w_i >=0
## constraints: 
##      \sum_j u_j*x_j <= sum_i w_i*a_i except for Ingleton where >=
##      \sum_j v_j*x_j <= sum_i w_i*b_i except for Ingleton where >=
##      \sum_i w_i*c_i =1 for the Ingleton
## objectives: \sum_i*c_i for the rest of the coordinates; to be minimized
##

use strict;

my $dim=9; # should be 9 (reduced) or 11 (full

sub help {
    print "apply a double rule for a set of inequalities\n";
    print "usage: [-t bnd] <eqlist> <rulefile> <vlpfile>\n";
    exit 1;
}
my $argcnt=0; my $bound=0;
if(scalar @ARGV <4){ help(); }
if($ARGV[0] eq "-t"){
    $bound = 0+$ARGV[1]; if($bound<10 || $bound > 1000){ help(); }
    $argcnt=2;
}
if(scalar @ARGV != $argcnt+3){ help(); }
if($ARGV[$argcnt+2] !~ /\.vlp$/ ){
    print "The output file name should end with '.vlp'\n";
    exit 1;
}
if(-e $ARGV[$argcnt+2] ){
    print "File ",$ARGV[$argcnt+2]," exists. Continue (y/n)? ";
    my $ans=<stdin>;
    if($ans !~ /^y/i ){exit 0; }
}

################################################################
# read a double rule file
# [1,2,3,4,5,6,7,8,9 ] + [ 1,2,3,4,5,6,7,8,9] <= [1,2,3,4,5,6,7,8,9]
sub read_rulefile {
    my($info,$file)=@_;
    $info->{a}=(); $info->{b}=(); $info->{c}=();
    open(RULE,"$file") || die "Cannot open rule file $file\n";
    while(<RULE>){
       chomp;
       my $line=$_;
       next if(/^c/i);
       next if(/^$/);
       /^\[(.*)\] \+ \[(.*)\] <= \[(.*)\]$/ || die "wrong line in $file:\n $line\n";
       my @a=split(',',$1); my @b=split(',',$2); my @c=split(',',$3);
       scalar @a==$dim && scalar @b ==$dim && scalar @c==$dim ||
          die "wrong line in $file:\n $line\n";
       push @{$info->{a}},\@a;
       push @{$info->{b}},\@b;
       push @{$info->{c}},\@c;
    }
    close(RULE);
}

##################################################################
# read inequalities
#
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
sub make_hash {
    my $a=shift;
    return join(',',@$a);
}
sub read_inequalities {
    my($info,$file)=@_;
    my @array=(); my %hash=();
    open(FILE,$file) || die "Cannot open ineq file $file\n";
    while(<FILE>){
        chomp;
        my $line=$_;
        next if(/^#/);
        next if(/^$/);
        my @a=split(/,\s*/);
        scalar @a>=11 || die "wrong line in ineq $file:\n $line\n";
        my $ok=1; my $idx=$dim;
        while($idx<=10){ $ok=0 if($a[$idx]); $idx++; }
        next if(!$ok);
        my(@a1,@a2,@a3,@a4);
        $ok=1;
        for my $i(0..$dim-1){
            $a1[$i]=$a2[$i]=$a3[$i]=$a4[$i]=$a[$i];
            $ok=0 if($bound && $a[$i]>$bound);
        }
        next if(!$ok);
        swap_ab(\@a2); swap_cd(\@a3); swap_ab(\@a4); swap_cd(\@a4);
        my ($h1,$h2,$h3,$h4)=(make_hash(\@a1),make_hash(\@a2),
              make_hash(\@a3),make_hash(\@a4));
        if(!$hash{$h1}){ $hash{$h1}=1; push @array, \@a1; }
        if(!$hash{$h2}){ $hash{$h2}=1; push @array, \@a2; }
        if(!$hash{$h3}){ $hash{$h3}=1; push @array, \@a3; }
        if(!$hash{$h4}){ $hash{$h4}=1; push @array, \@a4; }
    }
    close(FILE);
    scalar @array > 0 || die "No applicable inequality was found in $file\n";
    $info->{x}=\@array;
}

################################################################
# create the vlp file
#
##     w_i     u_j    v_j
##     a_i    -x_j    0      Ingleton <=0, others >=0
##     b_i     0     -x_j    Ingleton <=0, others >=0
## objectives:
##     c_i     0      0      Ingleton: =1, others: objective
##
sub create_vlp {
    my($info,$vlpfile)=@_;
    my $na=scalar @{$info->{a}}; my $nx = scalar @{$info->{x}};
    my $cols=$na+$nx+$nx;
    my $az=0; my $objz=0;
    foreach my $x(@{$info->{x}}){
        for my $i(0..$dim-1){ $az+=2 if($x->[$i]); }
    }
    foreach my $a(@{$info->{a}}){
        for my $i(0..$dim-1){ $az++ if($a->[$i]); }
    }
    foreach my $b(@{$info->{b}}){
        for my $i(0..$dim-1){ $az++ if($b->[$i]); }
    }
    foreach my $c(@{$info->{c}}){
        $az++ if($c->[0]);
        for my $i(1..$dim-1){ $objz++ if($c->[$i]); }
    }
    my $ruletxt=$ARGV[$argcnt+1]; 
    $ruletxt =~ s/\.[^.]*//; $ruletxt =~ s/.*\///;
    open(VLP,">$vlpfile") || die "Cannot open $vlpfile for writing\n";
     print VLP "c applying double rule ",$ruletxt," for ",$ARGV[$argcnt],"\n";
     print VLP "p vlp min",
       " ",$dim+$dim+1,   # number of rows
       " ",$cols,         # columns
       " ",$az,           # nonzero elements in A
       " ",$dim-1,        # number of objectives
       " ",$objz,         # nonzero elements in objectives
       "\n";
     # variable types: 1..$cols: non-negative
     for my $j(1..$cols){
        print VLP "j $j l 0\n";
     }
     # constraint types: Ingleton: <=0, others >=0
     for my $i(1..$dim+$dim){
        print VLP "i $i ",($i==1|| $i==$dim+1 ?"u":"l")," 0\n";
     }
     # result Ingleton ==1
     print VLP "i ",$dim+$dim+1," s 1\n";
     # the matrix A
     for my $i(0..$dim-1){
         for my $j(1..$na){
            my $v=$info->{a}[$j-1]->[$i];
            print VLP "a ",$i+1," $j $v\n" if($v);
            $v=$info->{b}[$j-1]->[$i];
            print VLP "a ",$dim+$i+1," $j $v\n" if($v);
         }
         for my $j(1..$nx){
            my $v=0-$info->{x}->[$j-1]->[$i];
            print VLP "a ",$i+1," ",$na+$j," $v\n" if($v);
            print VLP "a ",$dim+$i+1," ",$na+$nx+$j," $v\n" if($v);
         }
     }
     # Ingleton row
     for my $j(1..$na){
         my $v=$info->{c}[$j-1]->[0];
         print VLP "a ",$dim+$dim+1," $j $v\n" if($v);
     }
     # objectives
     for my $i(1..$dim-1){
         for my $j(1..$na){
            my $v=$info->{c}->[$j-1]->[$i];
            print VLP "o $i $j $v\n" if($v);
         }
     }
     print VLP "e\n\n";
    close(VLP);
}

###############################################################

my $info={};
read_rulefile($info,$ARGV[$argcnt+1]);
read_inequalities($info,$ARGV[$argcnt]);
create_vlp($info,$ARGV[$argcnt+2]);

exit;

