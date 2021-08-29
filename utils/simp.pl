#!/usr/bin/perl -w
# canonize a copy string
# Usage:  simp.pl <copy_string>
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

sub sortparts { # array of { new => "char", old=>"str" } ]
    my ($arr,$sep)=@_;
    my $new=""; my $old="";
    foreach my $p ( sort { lc($a->{old}) cmp lc($b->{old}) } @$arr ){
        $new .= $p->{new}; 
        if($old && $sep){$old .= $sep; }
        if(!$sep && length($p->{old})>1){ $old .= "(".$p->{old}.")"; }
        else { $old .= $p->{old}; }
    }    
    return { new=>$new, old=>$old };
}

sub arrange { # $arr->[$idx] and $arr->[$j] has the same length
    my($arr,$idx)=@_;
    my($new,$old)=($arr->[$idx],$arr->[$idx+1]);
    my @all=(); ## $all[i] = [ { new=> "str", old=>"char" }, { ... } ]
    my $d=[]; my $newcnt=0; my $inside=0;
    foreach my $ch (split('',$old)){
       if($inside){
          my $dn=-1+scalar @$d;
          if($ch eq ")"){ 
              $inside=0; 
              $d->[$dn]->{old}=stringsort($d->[$dn]->{old});
          } else {
              $d->[$dn]->{old} .= $ch;
          }
       } elsif($ch eq "("){
          $inside=1; push @$d, {old => "", new => substr($new,$newcnt,1) };
          $newcnt++;
       } elsif($ch eq "|"){
          die "Syntax error in the copy string\n" if(scalar @$d==0); # syntax error
          push @all,sortparts($d); $d=[];
       } else {
          push @$d, {old => $ch, new => substr($new,$newcnt,1) };
          $newcnt++;
       }
    }
    die "Syntax error in the copy string\n" if($inside || scalar @$d==0); # syntax error
    push @all, sortparts($d);
    ## sort the elements of $all
    my $res=sortparts(\@all,"|");
    $arr->[$idx]=$res->{new}; $arr->[$idx+1]=$res->{old};
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
        $parts[$i+2]=stringsort($parts[$i+2]); # the "copy over" part
        arrange(\@parts,$i); ## to be pasted, new variables
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
        if($t !~ /^[a-z]+\=[a-z\(\)\|]+:[a-z]+$/){
            die "Syntax error in the copy string\n";
        }
    }
    ## create all permutations with swappable inversions
    my $n=scalar @parts;
    return min_paste($str) if($n<2); ## should handle ()
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
    $minimal =~ s/\(([a-z]+)\)/"(".stringsort($1).")"/ge;
    return $minimal;
}

##################################################################
## apply the symmetry of the head of the copy string to the rest
## parse the string as rst=abc:xy;<rest>, then swap [rst]<->[abc]
## in <rest>.
##
sub swapthem { ## swap chars in $s1 to chars in $s2
    my($s1,$s2,$str)=@_;
    return $str if(length($s1)!=length($s2));
    $str=uc($str);
    for my $i(0..-1+length($s1)){
        my $t=uc(substr($s1,$i,1)); my $u=substr($s2,$i,1);
        $str =~ s/$t/$u/eg;
        $t=uc(substr($s2,$i,1)); $u=substr($s1,$i,1);
        $str =~ s/$t/$u/eg;
    }
    return lc($str);
}
sub permute_min {
    my($str)=@_;
    $str =~ s/\s//g; # no spaces
    $str =~ s/,$//; # no trailing comma
    my $copy=$str; my $rest="";
    if($str =~ /^([^;]+);(.+)$/) { $copy=$1; $rest=$2; }
    my $this=swapped($str);
    return $this if(!$rest);
    if($copy =~ /^([a-z][a-z])\=([a-z][a-z]):/){
        my $s1=$1; my $s2=$2;
        my $that=swapped( $copy.";".swapthem($s1,$s2,$rest));
        if($that lt $this){ return $that; }
    } elsif($copy =~ /^([a-z])=([a-z]):/ ){
        my $s1=$1; my $s2=$2;
        if($str !~ /a/ || $str !~ /b/ || $str !~ /c/ || $str !~ /d/){
           my $that=swapped($copy.";".swapthem($s1,$s2,$rest));
           if($that lt $this){ return $that; }
        }
    }
    return $this;
}

##################################################################
#
if( scalar @ARGV != 1 ){ die "Please specify the copy string to normalize\n"; }

print permute_min($ARGV[0]),"\n";
exit 0;

