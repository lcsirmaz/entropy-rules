#!/usr/bin/perl -W
#
# create .md files from the DFZ.txt file
#

use strict;

sub usage {
    print "usage: DFZgen.pl <latest-inequality-file>\n";
    print "Generating DFZ/main.txt, the list of DFZ inequalities\n";
    print "inequalities NOT in the supplied file are marked as\n";
    print "superseded\n";
    exit 1;
}

my $rawfile = "DFZ/orig.txt";

my @list=();

my %supplist=();
my $cnt=0;

if(scalar @ARGV!=1 || !$ARGV[0]){ usage(); }
open(FILE,$ARGV[0])|| die "Cennot open inequality file $ARGV[0] for reading\n";
while(<FILE>){
    next if(/^#/);
    next if(!/ dfz:\d+:(\d+)$/);
    $supplist{$1}=1; $cnt++;
}
close(FILE);

if($cnt==0){
    print "No dfz label was found in $ARGV[0], aborting\n";
    exit(1);
}

open(FILE,$rawfile) || die "Cannot open file $rawfile\n";
while(<FILE>){
    chomp;
    next if(!/^\s*[1-9]/);
    my @a=split(/,\s*/,$_);
    for my $i(0..-1+scalar @a){
        $a[$i] =~ s/\s//g;
    }
    my ($n)= $a[12] =~ /dfz:\d+:(\d+)/;
    if(!defined $supplist{$n}){ $a[13]='S'; }
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

