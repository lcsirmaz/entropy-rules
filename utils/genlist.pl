#!/usr/bin/perl -W
#
# generate ineq-list.txt and ineq-normalized.txt from the files
# supplied as arguments.
# Typical usage:
#   utils/genlist.pl DFZ/DFZ.txt copy/*.new rules/*.new
#

use strict;

my @list=();

my %supplist=();

sub read_supplist {
    my $file=shift;
    open(FILE,$file) || die "Cannot open superseded file $file\n";
    my $cnt=0;
    while(<FILE>){
        next if(!/^superseded: [^\s]+\/([^\s]+) by/);
        $supplist{$1}=1;
        $cnt++;
    }
    close(FILE);
    die "No superseded items found in $file\n" if($cnt==0);
}

sub add_file {
    my $file=shift;
    open(FILE,$file) || die "Cannot open file $file\n";
    while(<FILE>){
        chomp;
        next if(/^#/);
        my @a=split(/,\s*/,$_);
        for my $i(0..-1+scalar @a){
            $a[$i] =~ s/\s//g;
        }
        die "Wrong line in file $file" if(scalar @a < 12);
        next if($a[13]); ## superseded
        next if(defined $supplist{$a[12]});
        push @list,\@a;
    }
    close(FILE);
}

## compute the lexicographically minimal version
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

sub make_list {
    my $file=shift;
    open(OUT,">$file")|| die "Cannot create $file\n";
    foreach my $a(@list){
        biggest($a);
        my $t="";
        for my $i(0..10){ $t.= sprintf("%04x",$a->[$i]); }
        $a->[13]=$t;
    }
    print OUT "# Entropy inequalities for four random variables
#
# Each line contains the coefficients of an entropy inequality using
#  the natural coordinates
#  [a,b,c,d ]  (Ingleton expression: -(a,b)+(a,b|c)+(a,b|d)+(c,d) )
#   (a,b|c), (a,c|b), (b,c|a)   (a,b|d), (a,d|b), (b,d|a)
#   (c,d|a), (c,d|b), (c,d), (a,b|cd)
#
# The next entry is the copy string, followed by the label of the
#  inequality. Only inequalities which are not known to be superseded
#  are listed. The list is in increasing order of the value of the
#  coefficients.
#
# The normalized list contains the same inequalities normalized to have 
#  the Ingleton coefficient be equal to 1.
#
# The number of inequalities listed is ",scalar @list ,".
#
#   Coefficients,             copy string, label
#\n";
    foreach my $a( sort {$a->[13] cmp $b->[13]} @list ){
        for my $i(0..10){
             print OUT $a->[$i],",";
             print OUT " " if($i==0 || $i==3 || $i==6);
        }
        print OUT " ",$a->[11], ", ",$a->[12],"\n";
    }
    close(OUT);
}

sub make_normalized_list {
    my $file=shift;
    open(OUT,">$file")|| die "Cannot create $file\n";
    foreach my $a(@list){
        biggest($a);
        my $t=$a->[0]+0.0; $a->[0]="";
        for my $i(1..10){
            if($a->[$i]==0){ $a->[$i]="0       "; }
            else { $a->[$i]= sprintf("%8.6f", ($a->[$i]+0.0)/$t); }
            $a->[0] .= $a->[$i];
        }
    }
    print OUT "# Normalized entropy inequalities for four random variables
#
# Coefficients are normalized and the list is in increasing order.
#
#         Coefficients                label
#\n";
    foreach my $a( sort {$a->[0] cmp $b->[0]} @list ){
        print OUT "1, ";
        for my $i(1..10){ print OUT $a->[$i],","; print OUT " " if($i==3 || $i==6); }
        print OUT " ",$a->[12],"\n";
    }
    close(OUT);
}

################################################################

my $ARGZ=0;
if( scalar @ARGV>0 && $ARGV[0] eq "-s"){$ARGZ=2; }

if(scalar @ARGV <= $ARGZ){
    print "usage: genlist.pl [-s <slist>] <eqfile1> <eqfile2> ... \n";
    exit 1;
}

## read list of superseded items
if($ARGZ){ read_supplist($ARGV[1]); }

## read all files
for my $i($ARGZ .. -1+scalar @ARGV){ add_file($ARGV[$i]); }

make_list("ineq-list.txt");

make_normalized_list("ineq-normalized.txt");


