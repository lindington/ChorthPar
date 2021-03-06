#!/usr/local/bin/perl
#
# Cared for by Filipe G. Vieira <>
#
# Copyright Filipe G. Vieira
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

    geno2treemix.pl v0.0.9

=head1 SYNOPSIS

    perl geno2treemix.pl [OPTIONS]

    OPTIONS:
       -h help        This help screen
       --geno          Input GENO file [stdin]
       --format        Input genotypes format
       --skip_cols     Number of columns to skip from GENO file [0]
       --header        Input file has header
       --ifs           Input field separator [ ]
       --igs           Input genotype separator [,]
       --ofs           Output field separator [ ]
       --ogs           Output genotype separator [,]
       --excl          File or CSV list of individual IDs to exclude
       --pop           Populations file, one indiv per line (ID\tpop)
       --pop_min       Only keep populations that have number of samples > pop_min
       --na            Missing data input character [.]
       --debug         Print extra info to file

=head1 DESCRIPTION

    Converts a genotype file into treemix format. Optionally, it can also 
    merge individuals according to their populations, summing corresponding 
    alleles.

    It can read several GENO formats:
                        HOM1   HET    HOM2
        treeMix:        2,0    1,1    0,2
        angsd:           0      1      2
        traw (plink):    0      1      2
        tped (plink):   2/2    1/2    1/1
        hapmap:       [ACGT] [RYSWKM] [ACGT]

    To convert from regular PLINK PED/BED files, you can run:
    to TRAW (PLINK):
        plink --file INPUT_PREFIX --recode A-transpose -out OUTPUT_PREFIX
        tail -n +2 OUTPUT_PREFIX.traw | perl geno2treemix.pl --format traw --skip_cols 6 --na NA --pop POPULATION_FILE --ifs "\t" > OUTPUT.treemix

    to TPED12 (PLINK):
        plink --file INPUT_PREFIX --recode transpose 12 -out OUTPUT_PREFIX --tab
        perl geno2treemix.pl --geno OUTPUT_PREFIX.tped --format tped --skip_cols 4 --na 0 --pop POPULATION_FILE --ifs "\t" --igs " " > OUTPUT.treemix

=head1 AUTHOR

    Filipe G. Vieira - fgarrettvieira _at_ gmail _dot_ com

=head1 CONTRIBUTORS

    Additional contributors names and emails here

=cut

# Let the code begin...

use strict;
use warnings;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
use List::MoreUtils qw{uniq first_value};
use IO::Zlib;

my ($in_geno, $in_format, $skip_cols, $in_header, $ifs, $igs, $ofs, $ogs, $in_excl, $in_pop, $pop_min, $na, $debug);
my ($n_samples, $major, @buf, @geno, @header, @excl, @pops, %pop, %pop_sizes);

# Default values
$in_geno = '-';
$skip_cols = 0;
$in_format = 'treemix';
$ofs = " ";
$ogs = ",";
$pop_min = 0;

#Get the command-line options
&GetOptions("h|help"      => sub { exec('perldoc',$0); exit; },
	    "g|geno=s"    => \$in_geno,
	    "gf|format:s" => \$in_format,
	    "skip_cols:i" => \$skip_cols,
	    "header!"     => \$in_header,
	    "ifs:s"       => \$ifs,
	    "igs:s"       => \$igs,
	    "ofs:s"       => \$ofs,
	    "ogs:s"       => \$ogs,
	    "excl:s"      => \$in_excl,
	    "p|pop:s"     => \$in_pop,
	    "pop_min:s"   => \$pop_min,
	    "na:s"        => \$na,
	    "debug!"      => \$debug
    );


# Set IFS and IGS for predefined formats
if($in_format eq 'treemix') {
    $ifs = " " unless($ifs);
    $igs = "," unless($igs);
    $na = "." unless($na);
} elsif($in_format eq 'angsd' || 
	$in_format eq 'traw' || 
	$in_format eq 'hapmap') {
    $ifs = "\t" unless($ifs);
    $igs = "," unless($igs);
    $na = "-1" unless($na);
} elsif($in_format eq 'tped') {
    $ifs = " " unless($ifs);
    $igs = "/" unless($igs);
    $na = "0" unless($na);
} else {
    die("ERROR: wrong format specified.\n");
}

die("ERROR: input file separator (-ifs) and input genotype separator (-igs) must be different!\n") if($ifs eq $igs);



###############################################################################

# Read EXCL file
if($in_excl) {
    if (-f $in_excl) {
	my $EXCL_POP = new IO::Zlib;
	$EXCL_POP->open($in_excl, "r") or die("ERROR: cannot read EXCL file\n");
	die("ERROR: EXCL file is empty\n") unless(-s $in_excl);
	@excl = <$EXCL_POP>;
	$EXCL_POP->close;
    } else {
	@excl = split(/,/,$in_excl);
    }

    die("ERROR: invalid EXCL argument\n") if($#excl < 0);
}



# Read POP file
if($in_pop){
    my $IN_POP = new IO::Zlib;
    $IN_POP->open($in_pop, "r") or die("ERROR: cannot read POP file\n");
    die("ERROR: POP file is empty\n") unless(-s $in_pop);
    while(<$IN_POP>) {
	chomp();
	@buf = split(/\t/, $_);
	my $id = $buf[0];
	# In case there is no header, store name of samples
	$header[$n_samples++] = $id;
	next if(first_value {m/^$id$/} @excl);
	die("ERROR: individual ".$id." has no assigned population.\n") unless(defined($buf[1]));
	$pop{$id} = $buf[1];
    }
    $IN_POP->close;

    $pop_sizes{$pop{$_}}++ for (keys(%pop));
    print(STDERR "===> Found ".$n_samples." individuals across ".scalar(keys(%pop_sizes))." populations on POP file.\n");
}



# Go through INPUT file
my $IN_GENO = new IO::Zlib;
$IN_GENO->open($in_geno, "r") or die("ERROR: cannot read geno file\n");

my $line = 0;
while(<$IN_GENO>) {
    $line++;
    chomp();
    @buf = split(/$ifs/, $_);
    splice(@buf, 0, $skip_cols) if($skip_cols);
    
    if($line == 1) {
	print(STDERR "===> Found ".scalar(@buf)." individuals on GENO file.\n");
	if($in_header){
	    # Parse header
	    @header = @buf;

	    # Seq IDs with no population on POP file remain unchanged
	    foreach (@header) {
		$pop{$_} = $_ if( !defined($pop{$_}) && !grep(/$_/,@excl) );
	    }
	}else{
	    print(STDERR "===> GENO file has no header. Assuming same order as POP file.\n");
	    die("ERROR: number of individuals on GENO file does not matches lines in POP file!\n") if($n_samples != scalar(@buf));
	}

	# Print header
	@pops = uniq sort values(%pop);
	my $str = '';
	foreach (@pops) {
	    $str .= $_.$ofs if($pop_sizes{$_} > $pop_min);
	}
	chop($str);
	print($str."\n");

	# If there is a header skip it
	next if($in_header);
    }

    # Define major allele (only used if HAPMAP format)
    $major = first_value { m/^[ACGT]$/ } uniq(@buf);
    $major = "A" if(!defined($major));

    my %pop_geno;
    for(my $i=0; $i<=$#buf; $i++){
	my $id = $header[$i];
	next if( grep(/$id/,@excl) );

	@geno = map{ $_ = -1 if($_ eq $na); $_ } split(m/$igs/, $buf[$i]);

	if($in_format eq "treemix"){
	    die("ERROR: invalid TREEMIX format. Check '--ifs' and '--igs'.\n") unless ($#geno == 1);
	}elsif($in_format eq "tped"){
	    die("ERROR: invalid TPED format. Check '--ifs' and '--igs'.\n") unless ($#geno == 1);
	    die("ERROR: genotypes are not numbers (".$geno[0]."/".$geno[0]."). Does your file have a header? Did you specify '--na'?") unless looks_like_number($geno[0]) && looks_like_number($geno[1]);

	    if($geno[0] == -1){
		$geno[0] = 0;
		$geno[1] = 0;
	    }elsif($geno[0] == $geno[1]){
		if($geno[0] == 2){
		    $geno[0] = 2;
		    $geno[1] = 0;
		}elsif($geno[0] == 1){
		    $geno[0] = 0;
		    $geno[1] = 2;
		}else{
		    die("ERROR: invalid TPED format. Did specify '--na'?\n");
		}
	    }else{
		$geno[0] = $geno[1] = 1;
	    }
	}elsif($in_format eq "angsd" || $in_format eq "traw") {
	    die("ERROR: invalid ANGSD/TRAW format. Check '--ifs'.\n") unless ($#geno == 0);
	    die("ERROR: genotype is not a number (".$geno[0]."). Does your file have a header? Did you specify '--na'?") unless looks_like_number($geno[0]);

	    if($geno[0] == 0) {
		$geno[0] = 2;
		$geno[1] = 0;
	    } elsif($geno[0] == 1) {
		$geno[0] = 1;
		$geno[1] = 1;
	    } elsif($geno[0] == 2) {
		$geno[0] = 0;
		$geno[1] = 2;
	    }elsif($geno[0] == -1) {
		$geno[0] = 0;
		$geno[1] = 0;
	    } else {
		die("ERROR: invalid ANGSD/TRAW format. Did you specify '--na'?\n");
	    }
	}elsif($in_format eq "hmp" || $in_format eq "hapmap"){
	    die("ERROR: invalid HAPMAP format. Did you specify '--ifs' and '--igs'?\n") unless ($#geno == 0);

	    if($geno[0] eq "-1"){
		$geno[0] = 0;
		$geno[1] = 0;
	    }elsif($geno[0] eq $major){
		$geno[0] = 2;
		$geno[1] = 0;
	    }elsif($geno[0] =~ m/^[RYSWKM]$/){
		$geno[0] = 1;
		$geno[1] = 1;
	    }elsif($geno[0] ne $major){
		$geno[0] = 0;
		$geno[1] = 2;
	    }else{
		die("ERROR: invalid HAPMAP format. Did you specify '--na'?\n");
	    }
	}else{
	    die("ERROR: format not supported!\n");
	}

	$pop_geno{$pop{$id}}[0] += $geno[0];
	$pop_geno{$pop{$id}}[1] += $geno[1];
    }

    # DEBUG
    print("# ".$_."\n") if($debug);
    # Print line
    my $str = '';
    foreach (@pops) {
	$pop_geno{$_}[0] = "." if( !defined($pop_geno{$_}[0]) );
	$pop_geno{$_}[1] = "." if( !defined($pop_geno{$_}[1]) );
	$str .= join($ogs, $pop_geno{$_}[0], $pop_geno{$_}[1]).$ofs if($pop_sizes{$_} > $pop_min);
    }
    chop($str);
    print($str."\n");
}
$IN_GENO->close;
