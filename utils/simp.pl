#!/usr/bin/perl -w
# canonize a paste string
# Usage:  simp.pl <paste>
##
use strict;

#################################################################
#
# generate the minimal past string form the argument
# returns the first occurrecnte of $what in $string, or "" if
# none found
sub change_all {
    my ($arr,$what,$to)=@_;
    return if(!defined $to);
    foreach my $str(@$arr){
        $str =~ s/$what/$to/ge;
    }
}
sub stringsort {
    my $str=shift;
    if(length($str)<2){ return $str; }
    my @a=split('',$str); my $n=-1+scalar @a;
    for my $i(0..$n-1){for my $j($i+1..$n){
        if(lc($a[$i]) gt lc($a[$j])){
            my $t=$a[$i]; $a[$i]=$a[$j]; $a[$j]=$t;
        }
    }}
    return join('',@a);
}

sub arrange { # $arr->[$idx] and $arr->[$j] has the same length
    my($arr,$idx,$j)=@_;
    my @a1=(); ## $arr->[$idx] = "ab(xxx)e(efg)"
    my $coll=""; my $inside=0;
    foreach my $chr (split('',$arr->[$idx])){
        if($inside){
            if($chr eq ")"){ push @a1,$coll; $coll=""; $inside=0; }
            else { $coll .= $chr; }
        } else {
            if($chr eq "("){ $inside=1; }
            else { push @a1, $chr; }
        }
    }
    return if($inside);  ## wrong paste syntax
    my @a2=split('',$arr->[$j>=0?$j : $idx]);
    return if(scalar @a1<2 || scalar @a1 != scalar @a2);
    my $n=-1 + scalar @a1;
    ## go over all elements of $a1 and arrange them alphabetically
    for my $i(0..$n){$a1[$i]=stringsort($a1[$i]); }
    # use bubble sort
    for my $i(0..$n-1){for my $j($i+1..$n){
        if(lc($a1[$i]) gt lc($a1[$j])){
            my $t=$a1[$i]; $a1[$i]=$a1[$j]; $a1[$j]=$t;
            $t=$a2[$i]; $a2[$i]=$a2[$j];$a2[$j]=$t;
        }
    }}
    for my $i(0..$n){
        if(length($a1[$i])>1){ $a1[$i]="($a1[$i])"; }
    }
    $arr->[$idx]=join('',@a1);
    $arr->[$j]=join('',@a2) if($j>=0);
}

sub create_min {
    my($orig,$swapab,$swapcd)=@_;
    if($swapab){
        $orig =~ s/A/b/g; $orig =~ s/B/a/g;
    } else {
        $orig =~ s/A/a/g; $orig =~ s/B/b/g;
    }
    if($swapcd){
        $orig =~ s/C/d/g; $orig =~ s/D/c/g;
    }else {
        $orig =~ s/C/c/g; $orig =~ s/D/d/g;
    }
    my @parts=split(/[=:;]/,$orig);
    my @pool = split('',"zyxwvutsr");
    my $res="";
    # now go over all parts and assign the corresponding working variable
    for( my $i=0; $i<scalar @parts; $i+=3){
        arrange(\@parts,$i+2,-1); ## the "copy over" part
        arrange(\@parts,$i+1,$i); ## to be pasted, new variables
        foreach my $h(split('',$parts[$i])){
            next if($h !~ /[RSTUVWXYZ]/);
            change_all(\@parts,$h,pop @pool);
        }
        $res .= $parts[$i]."=".$parts[$i+1].":".$parts[$i+2].";";
    }
    $res =~ s/;$//;
    return $res;
}

sub min_paste {
    my $origstr=shift;
    my $str=uc($origstr);
    my $min1=create_min($str,0,0);
    my $min2=create_min($str,1,0); $min1=$min2 if($min2 lt $min1);
    $min2=create_min($str,0,1); $min1=$min2 if($min2 lt $min1);
    $min2=create_min($str,1,1); $min1=$min2 if($min2 lt $min1);
    return $min1;
}

sub is_swappable {
    my($a,$b)=@_;
    $a =~ s/=.*//; # variables defined in $a
    foreach my $ch(split('',$a)){
        return 0 if( $b =~ /$ch/ );
    }
    return 1;
}

sub not_an_element {
    my($z,$perm)=@_;
    my $n=scalar @$z;
    foreach my $t(@$perm){
        my $i=0;
        while($i<$n && $z->[$i]==$t->[$i]){ $i++; }
        if($i==$n){ return 0; }
    }
    return 1;
}

sub swapped {
    my ($str)=@_;
    my @parts=split(/;/,$str);
    foreach my $t(@parts){
        if($t !~ /^[a-z]+\=[a-z\(\)]+:[a-z]+$/){
            print "Syntax error: $str\n"; return $str;
        }
    }
    ## create all permutations with swappable inversions
    my $n=scalar @parts;
    return if($n<2);
    my @perms=(); $perms[0]=[];
    for my $i(0..$n-1){$perms[0]->[$i]=$i;}
    my $tested=0;
    while($tested < scalar @perms){
       for my $i(0..$n-2){
           next if(!is_swappable($parts[$perms[$tested]->[$i]],
                                 $parts[$perms[$tested]->[$i+1]]));
           my $z=[];
           for my $k(0..$n-1){$z->[$k]=$perms[$tested]->[$k]; }
           $z->[$i+1]=$perms[$tested]->[$i];
           $z->[$i]=$perms[$tested]->[$i+1];
           if(not_an_element($z,\@perms)){ push @perms,$z; }
       }
       $tested++;
    }
    my $minimal=min_paste($str); $tested=1;
    while($tested < scalar @perms){
        my $z="";
        for my $i(0..$n-1){
            $z .= ';' if($z);
            $z .= $parts[$perms[$tested]->[$i]];
        }
        $tested++;
        $z=min_paste($z);
        if($z lt $minimal){ $minimal=$z; }
    }
    return $minimal;
}

##################################################################
#
if( scalar @ARGV != 1 ){ die "Please specify the paste string to minimize\n"; }

print swapped($ARGV[0]), "\n";
exit 0;

