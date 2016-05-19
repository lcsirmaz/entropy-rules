#!/usr/bin/perl -W
#
# create .md files from the DFZ.txt file
#

use strict;

## file to be listed
my @files = ( "DFZ/DFZ.txt", "copy/new.txt");

my @list=();

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
        next if($a[13]); ## superseded
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
    foreach my $a(@list){
        biggest($a);
        my $t=$a->[0]+0.0; $a->[0]="";
        for my $i(1..10){
            if($a->[$i]==0){ $a->[$i]="0       "; }
            else { $a->[$i]= sprintf("%8.6f", ($a->[$i]+0.0)/$t); }
            $a->[0] .= $a->[$i];
        }
    }
    print "# Normalized entropy inequalities
#
#  coefficients, index
#\n";
    foreach my $a( sort {$a->[0] cmp $b->[0]} @list ){
        print "1, ";
        for my $i(1..10){ print $a->[$i],","; print " " if($i==3 || $i==6); }
        print " ",$a->[12],"\n";
    }
}

## read all files
foreach my $input(@files){ add_file($input); }

make_list();


