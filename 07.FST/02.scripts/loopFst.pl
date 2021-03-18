#! usr/bin/perl -w
# 'strict' pragma: require to call a variable before using it
use strict;
# 'warnings' pragma: give control over when/which warnings are enabled
use warnings;
# end if wrong number of arguments
die "perl $0 <position file> <fst alpha beta file>" unless (@ARGV==2);
# open file one (reference genome) or end
# capital letters = file handles
open IN, "$ARGV[0]" or die $!;
# open file two (fst file) or end 
#(|| = or with higher precedence, i.e. doesnt evaluate right side if left side is TRUE)
open FS, "$ARGV[1]" || die $!;
# name undefined arrays alpha & beta
my (@alpha, @beta);
# name and define scalar variable finish as 0
my $finish=0;
#define fl as FS array elements & chop (but what?) 
chomp(my $fl=<FS>);
# split fl by tab & define endp as second element(column?) in array 
my $endp=(split /\t/,$fl)[1];
# set position in fstfile position 0 (in bites)
seek (FS, 0, 0);

# TNT = elements in new file(?) define po as ref. genome array
TNT:while (my $po=<IN>){
        # if the position starts with "derivedFileName" (formerly misspelled as derivedFileNanme), do the next
        next TNT if ($po=~/^derivedFileName/);
        #chop off linespace? of position
        chomp ($po);
        #array a = reference file split by tab
        my @a=split /\t/,$po;
        #genes are last element in array split by : 
        my $gene=(split /\:/,$a[0])[-1];
        #array b = second element in reference genome split by : (position)
        my @b=split /\:/,$a[1];
        #chr is first element in position string 
        my $chr=$b[0];
        #st = start position of gene 
        #en = end position of gene
        my $st=(split /\-/,$b[1])[0];
        my $en=(split /\-/,$b[1])[1];
        #if end position of gene is smaller than 
        next TNT if ($en < $endp and $finish==0);
        #gene length 
        my $len=$en-$st+1;
#       print "$gene\:$st\-$en\t"
        if(@alpha){
                my $ta; my $tb;
                warn "no match for two array\n" unless (@alpha == @beta);
                my $elen=$#alpha+$finish;
                for my $ia (0..($#alpha-1+$finish)){
                        my $na=shift @alpha;
                        $ta+=$na;
                }
                for my $ib (0..($#beta-1+$finish)){
                        my $nb=shift @beta;
                        $tb+=$nb;
                }
                my $fst_l;
                if ($tb==0){
                        $fst_l=sprintf "%.4f", 0;
                }else{
                        $fst_l=sprintf "%.4f", ($ta/$tb);
                }
                print "$elen\t$fst_l\t$ta\t$tb\n"
        }
        last TNT if ($finish);
        print "$gene\:$st\-$en\t$a[-1]\t$len\t";
#       for my $i (0..($#alpha-1)){
#               shift @alpha;
#               shift @beta;
#       }
#       last TNT if ($finish);
        TTT:while(my $fst=<FS>){
                if (eof(FS)){
                        $finish=1;
                }
                chomp($fst);
                my @c=split /\t/,$fst;
                if ($c[1]>$en){
                        push @alpha,$c[2];
                        push @beta,$c[3];
                        $endp=$c[1];
                        next TNT;
                }else{
                        push @alpha,$c[2];
                        push @beta,$c[3];
                }
        }
}
close IN;
close FS;

