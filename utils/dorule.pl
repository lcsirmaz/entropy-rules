#!/usr/bin/perl -w
##
## dorule.pl: apply a rule for all known inequalities
##
## arguments: <eqlist> <rule> <vlpfile>
##
## known inequalities are read from <eqlist>
## <rule> contains a list of rules of the form
##   [1,0,0,0,0,0,0,0,0,0,0] <= [1,1,1,0,0,0,0,0,0,0,0]
## they are referred to as a_i <= b_i; known inequalities are x_j>=0
## the <vlpfile> is a description of the minimization problem
##
##  minimize \sum_i\lambda_i b_i       (10 objectives, Ingleton is fixed)
##  subject to \lambda_i>=0, \mu_j>=0, (variables)
##             \sum_j\mu_j x_j <= \sum_i \lambda_i a_i
##                   except for the Ingleton, where they should be equal
##             ingleton coeff of \sum_i\lambda_i b_i = 1
##
##  it generates all consequences applying the given rule to all known 
##  inequalities.

use strict;

sub help {
    print "apply a rule for all known inequalities\n";
    print "usage: <eqlist> <rulefile> <vlpfile>\n";
    exit 1;
}
if(scalar @ARGV !=3){ help(); }

if($ARGV[2] !~ /\.vlp$/ ){
    print "The output file name should end with '.vlp'\n";
    exit 1;
}
if(-e $ARGV[2] ){
    print "File $ARGV[2] exists. Continue (y/n)? ";
    my $ans=<stdin>;
    if($ans !~ /^y/i ){exit 0; }
}

################################################################
# read a rule file
# [0,0,0,0,0,0,0,0,0,0,1] <= [0,0,0,0,0,0,0,0,0,0,1]
sub read_rulefile {
    my($info,$file)=@_;
    $info->{a}=(); $info->{b}=();
    open(RULE,"$file")|| die "Cannot open rule file $file\n";
    while(<RULE>){
        chomp;
        my $line=$_;
        next if(/^c/i);
        next if(/^$/);
        /^\[(.*)\] <= \[(.*)\]$/ || die "wrong line in $file:\n $line\n";
        my @left=split(',',$1); my @right=split(',',$2);
        scalar @left ==11 && scalar @right==11 || die "wrong line in $file\n $line\n";
        push @{$info->{a}},\@left; push @{$info->{b}},\@right;
    }
    close(RULE);
#    print "rules: ",scalar @{$info->{a}},"\n";
#    for my $i(0..10){ print $info->{b}[27]->[$i],","; }
#    print "\n";
}
################################################################
# read inequalities
#
sub not_the_same {
    my($a,$b)=@_;
    for my $i(0..10){
        return 1 if($a->[$i]!=$b->[$i]);
    }
    return 0;
}
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

sub read_inequalities {
    my($info,$file)=@_;
    my @array=();
    open(FILE,"$file") || die "Cannot open ineq file $file\n";
    while(<FILE>){
        chomp;
        my $line=$_;
        next if(/^#/);
        next if(/^$/);
        my @a=split(/,\s*/);
        scalar @a==13 || die "wrong line in $file\n  $line\n";
        my(@a1,@a2,@a3,@a4);
        for my $i(0..10){
           $a1[$i]=$a2[$i]=$a3[$i]=$a4[$i]=$a[$i]; 
        }
        swap_ab(\@a2); swap_cd(\@a3); swap_ab(\@a4); swap_cd(\@a4);
        push @array, \@a1;
        push @array, \@a2 if(not_the_same(\@a1,\@a2));
        push @array, \@a3 if(not_the_same(\@a1,\@a3) && not_the_same(\@a2,\@a3));
        push @array, \@a4 if(not_the_same(\@a1,\@a4) &&
                 not_the_same(\@a2,\@a4) && not_the_same(\@a3,\@a4));
    }
    close(FILE);
    $info->{x}=\@array; ## none of them should follow from the rest ...
#    print "number of ineq: ",scalar @array,"\n";
}
################################################################
# create the vlp file
# vars: \lambda_i, \mu_j
#  \lambda_i a_i - \mu_j x_j >=0
#  \lambda_i*Ingleton         =1
# objectives:
#  \lambda_i*b_i
#
sub create_vlp {
    my($info,$vlpfile)=@_;
    my $na=scalar @{$info->{a}}; my $nx=scalar @{$info->{x}};
    my $cols=$na+$nx;
    my $nz=0; my $objz=0;
    foreach my $x(@{$info->{x}}){
       for my $i(0..10){ $nz++ if($x->[$i]); }
    }
    foreach my $a(@{$info->{a}}){
       for my $i(0..10){ $nz++ if($a->[$i]); }
    }
    foreach my $b(@{$info->{b}}){
        $nz++ if($b->[0]);
        for my $i(1..10){ $objz++ if($b->[$i]); }
    }
    print "cols=$cols; nonzero=$nz, nonzero objs=$objz\n";
    my $ruletxt=$ARGV[1]; 
    $ruletxt =~ s/\.[^.]*//; $ruletxt =~ s/.*\///;
    open(VLP,">$vlpfile") || die "Cannot open $vlpfile for writing\n";
     print VLP "c applying rule ",$ruletxt," for ",$ARGV[0],"\n";
     print VLP "p vlp min",
       " ",12,        # number of rows
       " ",$cols,     # columns
       " ",$nz,       # nonzero elements in A
       " ",10,        # number of objectives
       " ",$objz,     # nonzero elements in objectives
       "\n";
     # variable types: 1..$cols: non-negative
     for my $j(1..$cols){
        print VLP "j $j l 0\n";
     }
     # constraint types: 1: ==0, 2..11: >=0, 12: ==1
     print VLP "i 1 s 0\n";
     for my $i(2..11){
        print VLP "i $i l 0\n";
     }
     print VLP "i 12 s 1\n";
     # the matrix A
     for my $i(0..10){
         for my $j(1..$na){
             my $v=$info->{a}[$j-1]->[$i];
             print VLP "a ",$i+1," $j $v\n" if($v);
         }
         for my $j(1..$nx){
             my $v=0-$info->{x}->[$j-1]->[$i];
             print VLP "a ",$i+1," ",$na+$j," $v\n" if($v);
         }
     }
     # Ingleton row
     for my $j(1..$na){
         my $v=$info->{b}[$j-1]->[0];
         print VLP "a 12 $j $v\n" if($v);
     }
     # objectives
     for my $i(1..10){
         for my $j(1..$na){
             my $v=$info->{b}[$j-1]->[$i];
             print VLP "o $i $j $v\n" if($v);
         }
     }
     print VLP "e\n\n";
    close(VLP);
}

################################################################


my $info={};
read_rulefile($info,$ARGV[1]);

read_inequalities($info,$ARGV[0]);

create_vlp($info,$ARGV[2]);

