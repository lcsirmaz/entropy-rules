#!/usr/bin/perl -w
## generate the book inequalities
##
##  From (x,y,z) generate two inequalities:
##  (x, 1,x+y,x+y, 0,z,z, 0,0,0,0)
##  (x, 1,x+z,x+z, 0,y,y, 0,0,0,0)
##
##  Given A[0 .. n] of >=0 integer pairs, getvalue(A) returns
##
##   (x,y,a) = sum {i<n,j<=A[i]}  (i+j choose i) * [ 1,i,j ]
##
##  A[n]=0, and A[i-1]-A[i]= 0/1, thus each such A[i] is defined
##   by a 0/1 sequence of length n (a number < 2^n).
##
## Some inequalities are superseded as determined by superseded()
##
##################################################################

use strict;

my @choose_cache=(); # compute each (n choose k) only once
sub choose {
    my($n,$i)=@_;
    if($i<0 || $i>$n){ return 0;}
    if($i==0 || $i==$n){ return 1; }
    my $ii=$n-$i; if($ii<$i){$i=$ii;}
    if($i==1){ return $n; }
    if(defined $choose_cache[$n][$i]){
        return $choose_cache[$n][$i];
    }
    my $v=choose($n-1,$i-1)+choose($n-1,$i);
    $choose_cache[$n][$i]=$v;
    return $v;
}

sub get3 {
    my($i,$j)=@_;
    my $v=choose($i+$j,$i);
    return [$v,$v*$i,$v*$j];
}

sub add3 {
    my($w,$i,$j)=@_;
    my $c=choose($i+$j,$i);
    $w->[0]+=$c; $w->[1]+=$c*$i; $w->[2]+=$c*$j;
}

sub genmatrix {
# generate the matrix [a_0,a_1,...a_n]
##  so that a_i-a_{i+1} = b[i] = 0/1. a_n=0;
    my($i,$b)=@_;
    my $a=[]; $a->[$i]=0;
    while($i>0){
       $i--; $a->[$i]=$a->[$i+1]+($b&1); $b>>=1;
    }
## print "\ngenmatrix: [",join(", ",@$a),"]\n";
    return $a;
}

sub superseded { # check if the matrix is superseded
    my $a=shift;
    my $n= -1 + scalar @$a;
    return 0 if($n<2); ## all of those seven are OK
    my @plus; my @minus;
    if($a->[0]==$a->[1]){ push @plus,[0,1+$a->[0]]; } 
    else { push @minus,[0,$a->[0]]; }
    for my $i(1..$n-1){
       my $ai=$a->[$i];
       if($a->[$i-1]>$ai){
         push @plus, [$i,1+$ai] if($ai==$a->[$i+1]);
       } elsif ($ai>$a->[$i+1]){
         push @minus,[$i,$ai];
       }
    }
    push @plus,[$n+1,0];
    push @minus,[$n,0] if($a->[$n-1]==0);
    ## now check if it is superseded ...
    foreach my $m(@minus){
        my($max,$min)=(-1,10000000);
        foreach my $p(@plus){
            my $v=(0.0+$m->[1]-$p->[1])/(0.0+$p->[0]-$m->[0]);
            if($m->[0]<$p->[0]){
               $max=$v if($v>$max);
            } else {
               $min=$v if($v<$min);
            }
        }
        return 1 if($max > $min -1e-8);
    }
    foreach my $p(@plus){
        my($max,$min)=(-1,10000000);
        foreach my $m(@minus){
           my $v=(0.0+$m->[1]-$p->[1])/(0.0+$p->[0]-$m->[0]);
           if($m->[0]<$p->[0]){
              $max=$v if($v>$max);
           }else {
              $min=$v if($v<$min);
           }
        }
        return 1 if($max>$min- 1e-8);
    }
    return 0;
}


sub getvalue { ## return \sum_{(i,j)\in A} (i+j/choose i)*[1,i,j] 
    my $a=shift; ## the matrix
    my $w=[0,0,0];
    for my $i(0..-1+scalar @$a){
       for my $j(0..$a->[$i]){
          add3($w,$i,$j);
       }
    }
    return $w;
}

######################################
## A=genmatrix(n,b): 0<=b<2^n;
## superseded(A)== 0/1: 1 means superseded
## [x,y,z]=getvalue(A): the appropriate coordinates for A
######################################

my $threshold=300; my $gen=16; my $progress=0;
my @BOOK=();

if(scalar @ARGV <2){
   print "Usage: bookineq.pl [-p] <threshold> <generation>\n",
         "        -p: progress indication for generation>10 on STDOUT\n";
   exit 1;
}
if($ARGV[0] eq "-p"){ $progress=1; shift @ARGV; }
$threshold=int($ARGV[0]+0); $gen=int($ARGV[1]+0);
if($threshold<10 || $gen<5 || $gen>30){
    print "bookineq: arguments are out of range\n";
    exit 1;
}

sub makepairs { ## print out pairs ($n,$b) which are not superseded
    my $n=shift;
if($progress && $n>10){ print STDERR "doing $n\n"; }
    for my $b(0..-1+(1<<$n)){
       my $a=genmatrix($n,$b);
       if(!superseded($a)){
           my $v=getvalue($a);
           my($x,$y,$z)=($v->[0],$v->[1]+$v->[0], $v->[2]);
           if($y<$threshold && $z<$threshold){
              push @BOOK, [$x,$y,$z,$n,$b];
           }
           ($x,$y,$z)=($v->[0],$v->[2]+$v->[0],$v->[1]);
           if($v->[1]!=$v->[2] && $y<$threshold && $z<$threshold){
              push @BOOK, [$x,$y,$z,-$n,$b];
           }
       }
    }
}

sub generate_book_inequalities {
    @BOOK=(); # no book inequalities so far
    for my $n(1 .. $gen){ makepairs($n); }
    for my $v(sort {$a->[0]<=>$b->[0] || $a->[1]<=> $b->[1]} @BOOK ){
       my($x,$y,$z,$n,$b)=@$v;
       my($R,$nn)=("",$n); if($nn<0){$nn=-$nn; $R="R"; }
       my $nums="$x, 1,$y,$y, 0,$z,$z, 0,0,0,0, ";
       printf "%-41s %-12s %s\n", $nums,"book$R=$nn,", "book:$R$nn:$b";
    }
}

print 
"# Book inequalities up to $threshold and generation $gen
#
# For generation n and serial number b construct A[0 .. n] so that
#  A[n]=0 and A[i-1].A[i]= 0/1 where 0/1 comes from b. Let
#  (x,y,z) = sum {i<=n, j<=A[i] } (i+j choose i) * [1,i,j], and
#  generate two inequalities: 
#    x, 1,x+y,x+y, 0,z,z, 0,0,0,0,  book=n,  book:n:b
#    x, 1,x+z,x+z, 0,y,y, 0,0,0,0,  bookR=n, book:Rn:b
#
";

generate_book_inequalities(); exit 0;

__END__
