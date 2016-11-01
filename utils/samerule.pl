#!/usr/bin/perl -w
##
##  check if two rulesets are the same.
##
##  arguments: <ruleset1> <ruleset2>
##
##  The rules can be swapped a<->b and c<->d
##

use strict;

sub print_usage {
    print "Usage: samerule.pl <ruleset1> <ruleset2>\n",
          "Checks if the two rulesets are the same or not.\n";
    exit 1;
}

if(scalar @ARGV !=2){ print_usage(); }

####################################################################
## read a ruleset
##
my $dim=0; my $weight="";
sub read_ruleset {
    my($file)=@_;
    open(FILE,$file) || die "Cannot open ruleset $file\n";
    my $empty=1; 
    my @all=();
    while(<FILE>){
        chomp; my $line=$_;
        if( /^\[([\d,]+)\] <= \[([\d,]+)\]$/ ){
            my @left=split(',',$1); my @right=split(',',$2);
            if(!$weight){ $weight="two"; }
            $weight eq "two" || die "Wrong line in ruleset $file:\n$line\n";
            if(!$dim){ $dim=scalar @left; }
            (scalar @left==$dim && scalar @right==$dim) || die "Wrong line in ruleset $file:\n$line\n";
            $empty=0;
            push @all,[\@left,\@right];
        } elsif( /^\[([\d,]+)\] \+ \[([\d,]+)\] <= \[([\d,]+)\]$/ ){
            my @left1=split(',',$1); my @left2=split(',',$2); my @right=split(',',$3);
            $weight="three" if(!$weight);
            $weight eq "three" || die "Wrong line in ruleset $file:\n$line\n";
            if(!$dim){ $dim=scalar @left1; }
            (scalar @left1==$dim && scalar @left2==$dim && scalar @right==$dim) ||
                  die "Wrong line in ruleset $file:\n$line\n";
            $empty=0;
            push @all,[\@left1,\@left2,\@right];
        }
    }
    close(FILE);
    $empty && die "No rule was found in $file\n";
#    foreach my $x (@all){
#         print "[",join(',',@{$x->[0]}),"] [",join(',',@{$x->[1]}),"]\n";
#    }
    return \@all;
}

####################################################################
## compute permutations
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
sub permute_ruleset {  ## side: 0/1, method: 0(ab)/1(cd)
    my($set,$side,$method)=@_;
    foreach my $x(@$set){
        if($method==0){ swap_ab($x->[$side]); }
        else { swap_cd($x->[$side]); }
    }
}
sub permute_left { # swap left1 and left2 of every rule
    my($set)=@_;
    foreach my $x(@$set){
      my $t=$x->[0]; $x->[0]=$x->[1]; $x->[1]=$t;
    }
}
sub same_ruleset {
    my($set,$hash)=@_;
    foreach my $x(@$set){
       my $v=join(',',@{$x->[0]}).":".join(',',@{$x->[1]});
       if($weight eq "three"){ $v .= ":".join(',',@{$x->[2]}); }
       return 0 if(! $hash->{$v} );
    }
    return 1;
}
sub create_hash {
    my($set)=@_;
    my $hash={};
    foreach my $x(@$set){
        my $v=join(',',@{$x->[0]}).":".join(',',@{$x->[1]});
        if($weight eq "three"){ $v .= ":".join(',',@{$x->[2]}); }
        $hash->{$v}=1;
    }
    return $hash;
}

#######################################################
my $ruleset1 = read_ruleset($ARGV[0]);
my $ruleset2 = read_ruleset($ARGV[1]);
my $swapped=0;
#######################################################
sub different {
    print "Rulesets $ARGV[0] and $ARGV[1] are different\n";
    exit 1;
}

sub same {
    if(scalar @$ruleset1 == scalar @$ruleset2){
       print "Rulesets $ARGV[0] and $ARGV[1] are the SAME\n";
    } elsif($swapped) {
       print "Ruleset $ARGV[0] is an EXTENSION of $ARGV[1]\n";
    } else {
       print "Ruleset $ARGV[0] is a SUBSET of $ARGV[1]\n";
    }
    exit 0;
}

#######################################################
print "R1=",scalar @$ruleset1,", R2=",scalar @$ruleset2,"\n";
if(scalar @$ruleset1 > scalar @$ruleset2){
    my $temp=$ruleset1; $ruleset1=$ruleset2; $ruleset2=$temp;
    $swapped=1;
## different() if(scalar @$ruleset1 != scalar @$ruleset2) ;
}
my $hash=create_hash($ruleset2);

sub checktwo {
  permute_ruleset($ruleset1,0,0); same() if( same_ruleset($ruleset1,$hash) );  # ab
  permute_ruleset($ruleset1,0,1); same() if( same_ruleset($ruleset1,$hash) );  # ab cd
  permute_ruleset($ruleset1,0,0); same() if( same_ruleset($ruleset1,$hash) );  # cd
  permute_ruleset($ruleset1,0,1); same() if( same_ruleset($ruleset1,$hash) );  # --
  permute_ruleset($ruleset1,1,0);
  permute_ruleset($ruleset1,0,0); same() if( same_ruleset($ruleset1,$hash) );  # ab
  permute_ruleset($ruleset1,0,1); same() if( same_ruleset($ruleset1,$hash) );  # ab cd
  permute_ruleset($ruleset1,0,0); same() if( same_ruleset($ruleset1,$hash) );  # cd
  permute_ruleset($ruleset1,0,1); same() if( same_ruleset($ruleset1,$hash) );  # --
  permute_ruleset($ruleset1,1,1);
  permute_ruleset($ruleset1,0,0); same() if( same_ruleset($ruleset1,$hash) );  # ab
  permute_ruleset($ruleset1,0,1); same() if( same_ruleset($ruleset1,$hash) );  # ab cd
  permute_ruleset($ruleset1,0,0); same() if( same_ruleset($ruleset1,$hash) );  # cd
  permute_ruleset($ruleset1,0,1); same() if( same_ruleset($ruleset1,$hash) );  # --
  permute_ruleset($ruleset1,1,0);
  permute_ruleset($ruleset1,0,0); same() if( same_ruleset($ruleset1,$hash) );  # ab
  permute_ruleset($ruleset1,0,1); same() if( same_ruleset($ruleset1,$hash) );  # ab cd
  permute_ruleset($ruleset1,0,0); same() if( same_ruleset($ruleset1,$hash) );  # cd
  permute_ruleset($ruleset1,0,1); same() if( same_ruleset($ruleset1,$hash) );  # --
  permute_ruleset($ruleset1,1,1);
}
if($weight eq "two" ){
  checktwo();
  # print "done...\n";
  different();
  exit 0;

}
## $weight eq "three"
  permute_ruleset($ruleset1,2,0); checktwo();
  permute_ruleset($ruleset1,2,1); checktwo();
  permute_ruleset($ruleset1,2,0); checktwo();
  permute_ruleset($ruleset1,2,1); checktwo();
  permute_left($ruleset1);
  permute_ruleset($ruleset1,2,0); checktwo();
  permute_ruleset($ruleset1,2,1); checktwo();
  permute_ruleset($ruleset1,2,0); checktwo();
  permute_ruleset($ruleset1,2,1); checktwo();
  permute_left($ruleset1);
  different();
  exit 0;
  