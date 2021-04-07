## Treemix

Treemix is a program that uses allele frequency data to estimate the maximum likelihood tree while allowing for admixture events (Pickrell & Pritchard, 2012). The treemix manual is available [here](http://gensoft.pasteur.fr/docs/treemix/1.12/treemix_manual_10_1_2012.pdf), but it is not up to date.

## Making a .treemix file

The input file for TreeMix, a `.treemix` file, is created from a `.geno` file, which encodes genotypes as -1, 0, 1, and 2. 

#### Making a .geno file
To make the `.geno` file, i used `ANGSD` with the following options: 

```
angsd -b ../../inputs/bam_list55.txt -ref ../../inputa/grasshopperRef.fasta -doMajorMinor 1 -GL 1 -doGlf 2 -SNP_pval 1e-2 -doMaf 1 -nThreads 2 -r chr1: -sites ../inputs/neutral_sites -baq 1 -remove_bads 1 -uniqueOnly 1 -C 50 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -doCounts 1 -doPost 2 -doGeno 2 -postCutoff 0.95 -geno_minDepth 2 -minInd 44 -setMinDepth 110 -out ../03.output/real55
```

This gave me 4 output files: an ´.arg´ file, containing information on the used angsd options, a ´.beagle.gz´ file, a ´.mafs.gz´ file, and a ´.geno.gz´ file. 

#### Making a .pop file
Next, i created a ´.pop´ file, which indexes each individual as part of a population. It looked like this: 

```
1       BIG     BIG
2       BIG     BIG
3       BIG     BIG
4       BIG     BIG
5       BIG     BIG
6       PHZ     COR
7       PHZ     COR
8       PHZ     COR
9       PHZ     LAT
10      PHZ     LAT
11      CSY     CSY
12      CSY     CSY
13      CSY     CSY
14      CSY     CSY
15      CSY     CSY
16      POR     POR
17      POR     POR
18      POR     POR
19      POR     POR
20      POR     POR
21      ERY     ESC
22      ERY     ESC
23      ERY     BIE
24      ERY     BIE
25      ERY     BIE
26      DOB     DOB
27      DOB     DOB
28      DOB     DOB
29      DOB     DOB
30      DOB     DOB
31      PAR     ARU
32      PAR     ARU
33      PAR     ARU
34      PAR     GAB
35      PAR     GAB
36      AHZ     PAS
37      AHZ     PAS
38      AHZ     PAS
39      AHZ     PAS
40      AHZ     PAS
41      SLO     SVI
42      SLO     VRE
43      SLO     VRE
44      SLO     VRE
45      SLO     SVI
46      GOM     GOM
47      GOM     GOM
48      GOM     GOM
49      GOM     GOM
50      GOM     GOM
51      TAR     TAR
52      TAR     TAR
53      TAR     TAR
54      TAR     TAR
55      TAR     TAR
```
Here, column one is the individual number, column two is the population name that will be displayed in the results, and column 3 is the sampling location (or sublocation). The order of individuals has to match the order in the bamlist.

#### Converting .geno to .treemix
To convert the `.geno` file to a `.treemix` file, I first unzipped and printed only the 3rd fields to the new `.geno` file with `zcat real55.geno.gz | cut -f 3- > real55.geno`. Then I used the perl script [geno2treemix.pl](../04.treemix/02.scripts/geno2treemix.pl) from Filipe G. Vieira to convert the new `.geno` file with `perl geno2treemix.pl -geno ../03.output/real55.geno -format angsd -pop ../../inputs/real55.pop > ../03.output/real55.treemix`. The resulting `.treemix` file contained a header specifying the populations and then one row per SNP and its count in each population.  

## Making a tree

To generate a maximum likelihood tree, I used treemix. I called the program using the following command: 

```
for migs in {1...4}; do 
    treemix -i ../03.output/real55.treemix -root BIG -m ${migs} -o output ../03.output/all55mig${migs}.
done
```

gzip ../03.output/all55.treemix

## References 

Pickrell, J., & Pritchard, J. (2012). Inference of population splits and mixtures from genome-wide allele frequency data. Nature Precedings, 1-1.