#!/usr/bin/perl -w
#
# minrule.pl: finding minimal rule coefficients from the result file
#
# read a rule result file and compile a list of minimal set.
# The vertices are scaled to have integer coordinates only
# As they are not necessarily independent, redundant ones are
#   filtered out.
#

use strict;
my $roundeps=1e-7;

sub value { # value of a fraction
    my $str=shift;
    $str =~ s/\s//g; my $sign=1;
    if($str =~ s/^\-// ){ $sign=-1; }
    my $v=0;
    if( $str =~ /^(\d+)\/(\d+)$/ ){
        $v=(0.0+$1)/(0.0+$2);
    } else {
        $v= 0.0+$str;
    }
    if($sign<0){$v=-$v; }
    return $v;
}

sub toint {
    my $v=0.0+shift;
    my $sign=1; if($v<0){ $sign=-1; $v=-$v; }
    my $intv=int($v+0.1);
    if($v>$intv-$roundeps && $v<$intv+$roundeps){
        return ($sign<0 ? -$intv : $intv);
    }
    return $v;
}

sub denom {
    my $v=0.0+shift;
    my $intv=int($v+0.1);
    if($v>$intv-$roundeps && $v<$intv+$roundeps){ return 1; }
    for my $d(2..503){
        my $dv=$d*$v;
        $intv=int($dv+0.1);
        if($dv>$intv-$roundeps && $dv<$intv+$roundeps){ return $d; }
    }
    die "denom($v) is out of range\n";
    return 0;
}

sub gcd {
    my($a,$b)=@_;
    return $b if($a==0 || $a==$b);
    return $a if($b==0);
    return gcd($b%$a,$a) if($a<$b);
    return gcd($a%$b,$b);
}

sub lcm {
    my ($a,$b)=@_;
    return $a if($b==1 || $a==$b);
    return $b if($a==1);
    return $a*int(0.1+$b/gcd($a,$b));
}

# read the result file
sub read_input {
    my ($info,$file)=@_;
    $info->{dim}=0; $info->{M}=[];
    open(FILE,"$file") || die "Cannot open input file $file\n";
    my $start=1;
    while(<FILE>){
        if(/^C /){ $info->{prelude}.= $_ if($start);  next; }
        if(!/^V /){ next; }
        $start=0;
        chomp;
        my @w=split(/\s+/);
        my $dim=-1 + scalar @w;
        if(!$info->{dim}){$info->{dim}=$dim; }
        elsif($info->{dim}!=$dim){
           die "Number of item are different ($dim vs $info->{dim}): file $file, line:\n$_\n"; 
        }
        my $d=1; for my $i(1..$dim){
            my $v=value($w[$i]); next if($v==0 || $v==1 || $v==-1);
            $v=-$v if($v<0);
            $d=lcm($d,denom($v));
        }
        my @row=();
        for my $i(1..$dim){
            push @row,toint($d*value($w[$i]));
        }
        push @{$info->{M}},\@row;
    }
    $info->{cols}=scalar @{$info->{M}};
    close(FILE);
}

#===========================================================================
sub run_lp {
    my($info,$d)=@_;
    my @M=();
    my $cols=$info->{cols}; my $rows=$info->{dim};
    my $i=0; my $nonzero=0;
    for my $ii(0..$cols-1){
       next if($ii==$d);
       for my $j(0..$rows-1){
           $M[$j][$i]=$info->{M}->[$ii]->[$j];
           $nonzero++ if($M[$j][$i]);
       }
       $i++;
    }
    my $tmpname = `mktemp -q /tmp/chk_XXXXXX.vlp`; chomp $tmpname;
    open(VLP,">$tmpname") || die "Cannot create temporary file $tmpname\n";
      print VLP "C checking whether a rule is independent of others\n";
      print VLP "p vlp min",
         " ",$rows,         # number of rows
         " ",$cols-1,       # columns
         " ",$nonzero,      # nonzero coeffs
         " ",1,             # number of objectives
         " ",0,             # nonzxero elements in objectives
         "\n";
      # variable types: 1..$cols-1: non-negative
      for my $j(1..$cols-1){
        print VLP "j $j l 0\n";
      }
      # constraint types: <=
      for my $i(1..$rows){
        print VLP "i $i u ",$info->{M}->[$d]->[$i-1],"\n";
      }
      # the matrix
      for my $i(1..$rows){ for my $j(1..$cols-1){
        my $v=$M[$i-1][$j-1];
        print VLP "a $i $j $v\n" if ($v);
      }}
    close(VLP);
    system("inner -y- $tmpname > /dev/null");
    my $e=$?>>8; # 0: superseded, 2: not
    die "Unexpected error from inner ($e)\n" if($e!=0 && $e!=2);
    unlink($tmpname);
    return $e==0 ? 1 : 0;
}

if(scalar @ARGV !=2){
   print "Generating minimal rule coefficients from a result file..\n";
   print "Usage: minrule.pl <filename> <rulefile>\n";
   exit 1;
}

if($ARGV[0] !~ /^(.+)\.res/ ){
    die "The filename should end with .res\n";
}
my $info={prelude => ""};
if(open(VLP,"$1.vlp")){
   $info->{prelude}=<VLP>; close(VLP);
}
read_input($info,$ARGV[0]);
if($info->{dim}!=22){
    print "Expecting 11+11 dimensions, sorry\n"; exit 7;
}
#print "file: $ARGV[0]\n";
#print "dim=$info->{dim}\n";
#print "cols=$info->{cols}\n";
my $output=$ARGV[1];
if(-e $output){
    print "Output file $output exists. Continue (y/n)? ";
    my $ans=<stdin>;
    if($ans !~ /^y/i ){ exit 0; }
}

my @res=();
for my $j(0..-1+$info->{cols}){
  my $v=run_lp($info,$j);
  next if($v);
  my $txt="";
  for my $i(0..10){
     $txt .= ($i==0?"[":",").(0-$info->{M}->[$j]->[$i+11]);
  }
  $txt .= "] <= ";
  for my $i(0..10){
    $txt .= ($i==0? "[":",").$info->{M}->[$j]->[$i];
  }
  push @res,$txt;
}

open(OUT,">$output") || die "Cannot open $output for writing\n";
print OUT $info->{prelude};

foreach my $line (sort @res){
    print OUT $line,"]\n";
}

