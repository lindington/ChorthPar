# ABBABABA

The ABBA-BABA test detects gene flow between populations by calculating bias of discordance between gene trees and population trees. The bias is calculated by comparing the sites adhering to ABBA with sites adhering to BABA, with A = ancestral and B = derived. Each site is noted A or B for each population with the relationship (((H1,H2),H3),H4), with H4 being the outgroup.

When the gene tree for a site matches the species tree, the layout for the site is BBAA. However, the informal sites are the ones that do not match the species tree (ABBA or BABA). Since H1 and H2 are equally as related to H3, there should not be a bias toward one of the two layouts, if the discordance between gene tree and species tree was purely due to incomplete lineage sorting. A significant overrepresentation of ABBA or BABA sites indicates gene flow between the B-noted populations.

The proportions of ABBA and BABA are described by the D-statistic. A D-value of 0 indicates no significant bias, a positive D-value indicates bias towards ABBA (gene flow between H2 and H3), and a negative D-value indicates bias towards BABA (gene flow between H1 and H3).

## doAbbababa2 in ANGSD

ANGSD is a populatation genetics software, which has an implementation of the ABBA-BABA test called doAbbababa2 (Soraggi, Wiuf, & Albrechtsen, 2018). It runs the analysis repeatedly, with every possible combination of individuals per population. This allows multiple individuals to be used per population, and the summarised results to be weighted for each individual population topology.

### Input files

There are four main input files for this test: 

Bamlist: The list referring to the location of all the bam files that are included in the analysis. The list should be organised in groups of each population with the ougroup being last in the list. An example is included in my [input files](01.input/bamlist.txt)  

Reference transcriptome: The *C. paralellus* reference transcriptome can be found in my [input files](01.input/grasshopperRef.fasta)

Neutral sites file: 

Size file: This file tells angsd how to group the populations. It should be a list of numbers, with each number representing a population size (number of individuals in this population). This should include the outgroup. The size file can be found in my [input files](01.input/pop_all.size)

### Running on the cluster through SLURM

This job uses a lot of memory and should be submitted to an appropriate cluster via the slurm queue with a slurm script such as the following: 

```
#!/bin/bash

#SBATCH -J abbababa
#SBATCH --output=../02.output/abbababaallsites.out
#SBATCH --cpus-per-task=6
#SBATCH --clusters=mpp3
#SBATCH --partition=mpp3_batch
#SBATCH --mail-type=ALL
#SBATCH --mail-user=linda.hagberg@campus.lmu.de
#SBATCH -t 48:00:00

STARTTIME=$(date +"%s")

angsd -b ./bamlist.txt -ref ./grasshopperRef.fasta -doMajorMinor 1 -GL 1 -doMaf 1 -doCounts 1 -doAbbababa2 1 -sizeFile pop_all.size -useLast 1 -r chr1: -baq 1 -remove_bads 1 -uniqueOnly 1 -C 50 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -minInd 24 -setMinDepth 60 -SNP_pval 1e-6 -out ../02.output/slurmallsites.out

ENDTIME=$(date +%s)
TIMESPEND=$(($ENDTIME - $STARTTIME))
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60))

timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)

echo "Job ended at $(date). Took $timestamp hours:minutes:seconds to complete."
```

In addition to the [general ANGSD options](../README), for this test I used a few specific options explained below: 

 
Option						|Description
------------------------------------------------|----------------------------------------------------
`-doAbbababa2 1`				|This is the point at which we instruct angsd to do the ABBA BABA test. The 2 in the option name refers to the newest implementation of the test which allows multiple individuals to be used per population in the analysis.
`-blockSize [Int]`				|Did not specify, leaving at default value of 5000000.
`-sizeFile sizefile.size`			|This option points to the location of a sizefile, which angsd uses to divide up the bamlist into populations.
`-useLast 1`					|Instructs angsd to use the last population in the bamlist as our outgroup.
`-SNP_pval 1e-6`				|Discards SNPs with a p-value of greater than 1e-6. This largely filters out fixed sites and low frequency SNPs. For ABBA-BABA, this is an appropriate filter as low frequency SNPs will largely be singletons, which are not very beneficial for inferring ancestral gene flow.

### Output files

The test will output three files, output_name.abbababa2, output_name.arg, and output_name.mafs.gz. The raw data used to calculate the D-statistic is found in the .abbababa2 files. 

### Calculating the D-statistic

ANGSD has provided an R script to calculate the D-statistic using the .abbababa2 output file. Along with the .abbababa2 file, a name file needs to be fed into the R script. This name file should be a list of the names of the populations and should be the same length as the size file. Find this [script](02.output/estAvgError.R) and my [name file](02.output/popNames.name) in my output folder. The R script can be run from the command line like this: 

`Rscript estAvgError.R angsdfile="[.abbababa2file] out="[nameofoutput]" nameFile=popnames.name`

Depending on the environment you are running the script from, you may have to load the r module first. You may have to load the r module like this:

`module load r`

This will output two .txt files, one containing the observed D-statistics and one in which ancestral transitions are removed (transrem). Since the transrem file is used for ancient DNA samples, it is not important for this analysis. 

#### Trimming

The output contains D-statistics for all possible combinations of populations, but since the ABBA-BABA test assumes the reconstructed tree matches the species tree, we must trim all non matching topologies from the output file. Zach wrote an R script for his analysis, which I adjusted for my data. The [trimming script](02.output/trim_abba_baba.R) can be found in my output files. It can be run in the command line like this:

`Rscript trim_abba_baba.R [output_nameObserved.txt]`

This will output the final data as a .csv file. It contains all the D-statistics, topologies, p-values, and Z-scores for analysis. Entries with a significant p-value suggest evidence for ancient gene flow between the two populations. If the D-statistic is positive and the p-value is significant, there is evidence for gene flow between H2 and H3. If the D-statistic is negative and the p-value is significant, there is evidence for gene flow between H1 and H3.

#### Plotting

I used excel to plot the trimmed .csv results. These plots can be found in my [plots folder](03.plots). 

## REFERENCES

Soraggi, Samuele, Carsten Wiuf, and Anders Albrechtsen. "Powerful inference with the D-statistic on low-coverage whole-genome data." *G3: Genes, Genomes, Genetics* 8.2 (2018): 551-566. doi:[10.1534/g3.117.300192](https://doi.org/10.1534/g3.117.300192).
