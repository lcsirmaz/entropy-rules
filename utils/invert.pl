#!/usr/bin/perl -w
#######################################################################
#
# inverting the natural coordinate system
#
########################################################################

use strict;

my @ocords =   qw( a  b  c  d  ab ac ad bc bd cd  abc abd acd bcd abcd );

## Natural coordinates, [] = Ingleton
my $macoord = [
["[]",            -1,-1, 0, 0,  1, 1, 1, 1, 1,-1,  -1, -1,  0,  0,  0  ],
["(a,b|c)",        0, 0,-1, 0,  0, 1, 0, 1, 0, 0,  -1,  0,  0,  0,  0  ],
["(a,c|b)",        0,-1, 0, 0,  1, 0, 0, 1, 0, 0,  -1,  0,  0,  0,  0  ],
["(b,c|a)",       -1, 0, 0, 0,  1, 1, 0, 0, 0, 0,  -1,  0,  0,  0,  0  ],
["(a,b|d)",        0, 0, 0,-1,  0, 0, 1, 0, 1, 0,   0, -1,  0,  0,  0  ],
["(a,d|b)",        0,-1, 0, 0,  1, 0, 0, 0, 1, 0,   0, -1,  0,  0,  0  ],
["(b,d|a)",       -1, 0, 0, 0,  1, 0, 1, 0, 0, 0,   0, -1,  0,  0,  0  ],
#
["(c,d|a)",       -1, 0, 0, 0,  0, 1, 1, 0, 0, 0,   0,  0, -1,  0,  0  ],
["(c,d|b)",        0,-1, 0, 0,  0, 0, 0, 1, 1, 0,   0,  0,  0, -1,  0  ],
["(c,d)",          0, 0, 1, 1,  0, 0, 0, 0, 0,-1,   0,  0,  0,  0,  0  ],
["(a,b|cd)",       0, 0, 0, 0,  0, 0, 0, 0, 0,-1,   0,  0,  1,  1, -1  ],
#
["(a|bcd)",        0, 0, 0, 0,  0, 0, 0, 0, 0, 0,   0,  0,  0, -1,  1  ],
["(b|acd)",        0, 0, 0, 0,  0, 0, 0, 0, 0, 0,   0,  0, -1,  0,  1  ],
["(c|abd)",        0, 0, 0, 0,  0, 0, 0, 0, 0, 0,   0, -1,  0,  0,  1  ],
["(d|abc)",        0, 0, 0, 0,  0, 0, 0, 0, 0, 0,  -1,  0,  0,  0,  1  ],

];
#

my $n=15;

my $inv=[];

foreach my $i(0..$n-1){
   $inv->[$i]=[];
   foreach my $j(0..$n-1){ 
      $inv->[$i]->[$n+$j]= ($i==$j ? 1.0 : 0.0 );
      $inv->[$i]->[$j]= $macoord->[$i]->[$j+1];
   }
}
## make the first part the ID
for my $i(0..$n-1){
  # eliminate column $i
  my $v=$inv->[$i]->[$i];
  if($v==0){
      for my $ii($i..$n-1){
          $v=$inv->[$ii]->[$i];
          if($v){ # add row $ii to row $i
              for my $j(0..$n+$n-1){
                  $inv->[$i]->[$j] += $inv->[$ii]->[$j];
              }
              $v=$inv->[$i]->[$i];
              last;
          }
      }
  }
  if($v==0){ die "Matrix is singlar, cannot compute inverse (row=$i)\n"; }
  $v=1.0/$v;
  for my $j(0..$n+$n-1){ $inv->[$i]->[$j] *= $v; }
  $inv->[$i]->[$i]=1.0;
  # subtract row $i from all other rows
  for my $ii(0..$n-1){
      next if($i==$ii);
      $v=$inv->[$ii]->[$i]; next if($v==0);
      for my $j(0..$n+$n-1){
         $inv->[$ii]->[$j] -= $v*$inv->[$i]->[$j];
      }
      $inv->[$ii]->[$i]=0;
  }
}

## print out the result
print "\# Computing individual entropies from natural coordinates
\#
my \@natcoords=( ";
for my $i(0..$n-1){
    print '"',$macoord->[$i]->[0],'",';
    print "\n    " if($i==0 || $i==6 || $i==10 || $i==14);
}
print "\n);\nmy \$inv = [\n";
for my $i(0..$n-1){
    printf "[%6s]", "\"".$ocords[$i]."\"";
    for my $j($n..$n+$n-1){
        print ",";
        my $jj=$j-$n;
        print " " if($jj<=1 || $jj==7 || $jj==11 || $jj==15);
        my $v=$inv->[$i]->[$j];
        $v=0 if($v<1e-10 && $v>-1e-10);
        printf "%2g",$v;
    }
    print "],\n";
}
print "];\n\#\n";

