#!/usr/bin/perl
# generating the vlp file for outer approximaation
# of the 3-dimensional visualization
#   outer.pl <output> <ineq1> <ineq2> ...
#
############################################################
use strict;

sub print_usage {
    print "usage: outer.pl <output> <ineq1> <ineq2> ...\n",
          "   <output>  the output vlp file\n",
          "   <ineq>    list of entropy inequalities\n\n";
    exit 1;
}

if(scalar @ARGV<2 ) { print_usage(); }

my $file=$ARGV[0];
if( !$file || $file !~ /\.vlp$/ ){ die "The output file name should end with '.vlp'\n"; }
if(-e $file ){
    print "File $file exists. Continue (y/n)? ";
    my $ans=<stdin>;
    if($ans !~ /^y/i) { exit 0; }
}

############################################################
sub push_if_new {
    my($info,$a,$b,$c,$d)=@_;
    my($v1,$v2,$v3)=(($b+0.0)/($a+0.0),($c+0.0)/($a+0.0),($d+0.0)/($a+0.0));
    if(!$info->{n}){
        $info->{n}=1; $info->{eq}=[]; $info->{a}=[]; $info->{flag}=[];
        $info->{eq}->[0]=[$a,$b,$c,$d]; 
        $info->{a}->[0]=[$v1,$v2,$v3];
        $info->{flag}->[0]=1;
        return;
    }
    my $next=-1;
    for my $i(0..-1+$info->{n}){
        if(!$info->{flag}->[$i]){ if($next<0){$next=$i;} next; }
        # check if ($a,$b,$c,$d) is superseded
        my $ia=$info->{a}->[$i];
        return if($ia->[0] <=$v1 && $ia->[1]<=$v2 && $ia->[2]<=$v3);
        # check if it supersedes this item
        if($v1<=$ia->[0] && $v2<=$ia->[1] && $v3<=$ia->[2]){
            $info->{flag}->[$i]=0;
            if($next<0){ $next=$i; }
        }
    }
    if($next<0){$next=$info->{n}; $info->{n}=$next+1; }
    $info->{eq}->[$next]=[$a,$b,$c,$d];
    $info->{a}->[$next] = [$v1,$v2,$v3];
    $info->{flag}->[$next]=1;
}
# $info->{n}: maximum index
# $info->{flag}->[$i]:  1 if valid entry
# $info->{eq}->[$i] = [$a,$b,$c,$d]

sub read_ineq_file {
    my($info,$file)=@_;
    open(FILE,$file)|| die "Cannot open ineq file $file\n";
    while(<FILE>){
        chomp;
        my $line=$_;
        next if(/^#/);
        next if(/^$/);
        my @a=split(/,\s*/);
        scalar @a>11 || die "wrong line in $file:\n  $line\n";
        push_if_new($info,
          $a[0]+0,                  # alpha
          2*($a[1]+$a[4]),          # beta
          $a[7]+$a[8],              # gamma
          $a[2]+$a[3]+$a[5]+$a[6]); # delta
    }
    close(FILE);
}

############################################################
# the MOLP problem has three objectives: x,y,z
# constraints: x>=0, y>=0, z>=0, x+y+z<=1
# plus for each valid [a,b,c,d]: a(1-x-y-z)<=bx+cy+dz, i.e.
#    (a+b)x + (a+c)y + (a+d)z >= a

sub create_vlp {
    my($info,$file)=@_;
    my $n=0;
    for my $i(0..-1+$info->{n}){
       $n++ if($info->{flag}->[$i]);
    }
    open(VLP,">$file")|| die "Cannot create vlp file $file\n";
    print VLP "C outer bound for the entropy region\n";
    print VLP "p vlp min",
       " ",$n+1,   # number of rows
       " ",3,      # number of columns
       " ",3*$n+3, # nonzero elements in a[]
       " ",3,      # number of objectives
       " ",3,      # nonzero elements in objectives
       "\n";
    # variable types: 1,,cols: non-negative
    for my $i(1..3){
        print VLP "j $i l 0\n";
    }
    # constraint types: 1..$n: >=, $n+1: <=
    my $i=0;
    for my $idx(0..-1+$info->{n}){
        next if(!$info->{flag}->[$idx]);
        $i++;
        print VLP "i $i l ",$info->{eq}->[$idx]->[0],"\n";
    }
    $i++;
    # last constraint
    print VLP "i $i u 1\n";
    # the matrix a
    $i=0;
    for my $idx(0..-1+$info->{n}){
        next if(!$info->{flag}->[$idx]);
        $i++;
        my $eq=$info->{eq}->[$idx];
        print VLP "a $i 1 ",$eq->[0]+$eq->[1],"\n";
        print VLP "a $i 2 ",$eq->[0]+$eq->[2],"\n";
        print VLP "a $i 3 ",$eq->[0]+$eq->[3],"\n";
    }
    # x+y+z<=1
    $i++;
    print VLP "a $i 1 1\n";
    print VLP "a $i 2 1\n";
    print VLP "a $i 3 1\n";
    # the objectives: x, y, z
    print VLP "o 1 1 1\n";
    print VLP "o 2 2 1\n";
    print VLP "o 3 3 1\n";
    # last line
    print VLP "e\n\n";
    close(VLP);
}

############################################################
my $info={};
for my $i(1..-1+scalar @ARGV){ read_ineq_file($info,$ARGV[$i]); }
create_vlp($info,$file);
print "done\n";




