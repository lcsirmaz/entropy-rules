#!/usr/bin/perl -W
#
# create .md files from the DFZ.txt file
#

use strict;

my $rawfile = "DFZ/orig.txt";

my @list=();

my %supplist=();

if(scalar @ARGV>0){
   if($ARGV[0] ne "-s" || scalar @ARGV!=2){ 
     print "generating DFZ/main.txt\n";
     print "usage: [-s <superseded-list>]\n";
     exit 1;
   }
   open(FILE,$ARGV[1])|| die "Cennot open superseded file $ARGV[1]\n";
   while(<FILE>){
       next if(!/^superseded: DFZ\/([^\s]+) by/ );
       $supplist{$1}=1;
   }
   close(FILE);
}

open(FILE,$rawfile) || die "Cannot open file $rawfile\n";
while(<FILE>){
    chomp;
    next if(/^#/);
    my @a=split(/,\s*/,$_);
    for my $i(0..-1+scalar @a){
        $a[$i] =~ s/\s//g;
    }
    if(defined $supplist{$a[12]}){ $a[13]='S'; }
    push @list,\@a;
}
close(FILE);

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

open(OUT1,">DFZ/main.txt") || die "Cannot create file DFZ/main.txt\n";
print OUT1
"#########################################################
#                                                       #
#       Dougherty - Freiling - Zeger inequalities       #
#                                                       #
#########################################################
#
# Generated automatically from orig.txt. Superseded inequalities
# are marked by *
#
#index natural coefficients                normalized copy string
#\n";

foreach my $a(@list){
    my $cnt=$a->[12]; $cnt =~ s/.*://g;
    printf OUT1 "%3d",$cnt; 
    if($a->[13]){ print OUT1 "*, "; } else {print OUT1 " , "; }
    biggest($a);
    for my $i(0..10){ printf OUT1 "%2d,",$a->[$i];
      print OUT1 " " if($i==0 || $i==3 || $i==6);
    }
    print OUT1 " ",$a->[11],"\n";
}
close(OUT1);

