# Gene Flow in the face of Haldane's Rule: Insights from a grasshopper hybrid zone

This repository contains all the scripts and data for my IRT3, masters thesis, and Lehre@LMU project. An in-depth README for each component is available in the respective folder. This README contains an introduction to my projects and to working on LMU's servers.

## Project Components

I have devided this repository into seven folders, which contain detailed scripts and data from each analysis:

- [Principle Component analysis](/01.PCA/)
- [Population Admixture](/02.NGSadmix/)
- [ABBA-BABA Test](/03.ABBABABA/)
- [Treemix](/04.treemix/)
- [Site Frequency Spectra](/05.SFS/)
- [Demographic Modeling using ∂a∂i](/06.dadi/)
- [Summary statistics](/07.sumstats/)


## Using the servers

All my analyses except demographic modeling were conducted on the Leibniz-Rechenzentrum's (LRZ) Linux-Cluster systems from LMU. Once you have account access through your LRZ-ID, you will be able to use your account and directory for storing files and submitting jobs. The demographic analysis using dadi was conducted on cruncher, a local server from the Faculty of Biology. On both servers, short jobs may be run directly from the command line via SSH, while longer running jobs should be submitted to the SLURM queue, which manages budgets and resources.


#### Connecting to the LRZ or cruncher

Both the LRZ and cruncher can be accessed via SSH with the following commands: 

cruncher: `ssh username@10.153.164.249`

LRZ: `ssh username@lxlogin8.lrz.de` (There are multiple log in nodes, and some partitions will require you to start jobs from a certain node. More information about the different log in nodes and getting access is available [here](https://doku.lrz.de/display/PUBLIC/Access+and+Login+to+the+Linux-Cluster).)

After this, you will be prompted for your password.

You may have to confirm you 'trust' the connection when you first access the cluster. You will be logged in to your home directory, where you can navigate using command line syntax.

#### Modifying the .bashrc in the LRZ

After successfully logging into the LRZ, you should first modify your .bashrc file in your home directory. You can do this with any text editor, my preferred is vim. To modify your .bashrc file, type:
`cd` (brings you to your home directory)
`vim .bashrc` (opens the hidden .bashrc file in the text editor vim)

Press the 'a' key to enable INSERT mode and paste (right click) the following line in the file:

```
export PROJECT=/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/username
```

To save and exit, press ESC and type ':x'. To exit without saving, type ':q!'.
This will create a shortcut to the directory of your project, which you can now reach with ´cd $PROJECT´. Detailed documentation of vim can be found [here](http://vimdoc.sourceforge.net/htmldoc/intro.html).

#### Loading a program

To use a program, it needs to be installed on the server, locally, or in a [conda](https://docs.conda.io/en/latest/miniconda.html) environment. 

For a full list of available programs in the server, use the command:
`module avail`

To find out if a specific program is available type 
`module avail | grep [name of program]`

If the program is available, you need to load it before using it.
`module load [program]`

To use a program that is not installed in the server, but locally, just type the name of the program. If that doesnt work, add the Path leading to the program.

To use conda, install a program in an environment. Call the environment using 
`conda activate [env]`

#### Submitting a job

Bioinformatic processes can take a lot of time, so running multiple tasks in parallel will make your work more efficient. To do this, you can write SLURM scripts (.sh files) which will be submitted to a cluster. The different clusters on the LRZ have different settings and should be used for different kinds of processes. Which cluster to chose depends on how much memory and running time your job needs. A detailed list of the available clusters can be found [here](https://doku.lrz.de/display/PUBLIC/Available+SLURM+clusters+and+features).

#### Creating a SLURM script

A SLURM script (.sh file) contains settings for the cluster as well as the commands for you want to run. This is an example of a SLURM script to make a beagle file with angsd. Open a new document with `vim example.sh`

```
#!/bin/bash
#SBATCH -J beagle
#SBATCH --output=beagle.out
#SBATCH --clusters=mpp3
#SBATCH --partition=mpp3_batch
#SBATCH --mail-type=ALL
#SBATCH --mail-user=linda.hagberg@campus.lmu.de
#SBATCH -t 48:00:00


STARTTIME=$(date +"%s")

angsd -b /01.input/bam_list.txt -ref /01.input/grasshopperRef.fasta -doMajorMinor 1 -GL 1 -doGlf 2 -SNP_pval 1e-2 -doMaf 1 -nThreads 2 -r chr1: -sites /01.input/neutral_sites -baq 1 -remove_bads 1 -uniqueOnly 1 -C 50 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -doCounts 1 -doPost 2 -doGeno 32 -minInd 41 -setMinDepth 102 -out /02.output/beagle

ENDTIME=$(date +%s)
TIMESPEND=$(($ENDTIME - $STARTTIME))
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60))

timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)

echo "Job ended at $(date). Took $timestamp hours:minutes:seconds to complete."
```
Test if the script runs with
`bash example.sh`

if it runs with no error messages, abort the job with 'ctrl+C' and submit the job with
`sbatch example.sh`

See the status of your submitted jobs with
`squeue -M [clustername]`

You can cancel a job with
`scancel -M [clustername] [jobID]`


A summary of the LRZ's SLURM status and a list with all partitions and waiting times is available [here](https://www.lrz.de/services/compute/linux-cluster/status/SLURM/SLURM_Status.html). A full documentation of SLURM and SLURM commands is available [here](https://slurm.schedmd.com).


## ANGSD Basics

Many analyses are performed in ANGSD (Korneliussen, Albrechtsen & Nielsen, 2014), a tool for analysing next generation sequencing data. The primary data type used by ANGSD are bam files (.bam), which contain genetic sequences aligned to a reference. The bam files I used were produced by Clara during her thesis and are stored in Enrique's folder on the LRZ. Because bam files are large, instead of copying them, I refer to them using a bamlist that provides a path to each required bam file when using angsd. 

#### Reference Transcriptome

When ANGSD reads in bam files, it compares them to a reference genome. The reference genome I used, *C. parallelus*, was built by Ricardo and can be found in the [input folder](00.input) of each component as `grasshopper_Ref.fasta` and must have its index file (`.fai`) with it. The `.positions` file contains the site information for each gene in the genome.

This reference transcriptome was built from transcriptomic data of all *C. parallelus* males in this dataset. The genome is organised into four artificial 'chromosomes', which each contain certain types of genes: (1) contains 16,970 single cope genes, 12,735 with identified open reading frames (ORFs) and 4,235 without; (2) contains 4,263 multi-copy genes; (3) contains 18,623 genes found only in a subset of *C. parallelus* individuals; and (4) contains the 13 mitochondrial genes.

#### Neutral Sites

Most demographic analyses rely on neutral evolution, which is why it has to be specified which sites are not under selective pressure. In this case (like in the SFS and ∂a∂i analyses), I only include neutral sites in the analyses, such as the untranslated regions, and the third position of each codon, as they rarely affect the function of the genes. A list of these [neutral sites](01.input/neutral_sites) is found in the input folder and included in the ANGSD command when relevant.

#### General ANGSD Options

ANGSD has an extensive list of options, many for filtering the data to be analysed. This is a list of options I included in almost every ANGSD analysis.

Option                                | Description
--------------------------------------|-----------------------------------------
`-b /01.input/bamlist.txt`            | Specifies name and location of input file
`-ref /01.input/grasshopperRef.fasta` | Specifies name and location of the reference transcriptome
`-doMajorMinor 1`                     | genotype likelihood
`-GL 1`                               | calculates likelihood of observing our data in one individual
`-doMaf 1`                            | frequency of major and minor alleles
`doCounts 1`                          | Calculates the frequency of each base per sample per site
`-r chr1:`                            | Restricts analysis to the artificial chromosome 1
`-sites /01.input/neutral_sites`      | Points to the file containing a list of sites not experiencing selection pressure.
`-baq 1`                              | Performs Base alignment Quality (BAQ) analysis in SAMtools
`-remove_bads 1`                      | Filters sites that contain SAMtools flags greater than 255 (poor alignments, duplicate reads, etc.)
`-uniqueOnly 1`                       | Removes reads with more than one best hit (places in the genome where the read aligns).
`-C 50`                               | Reduces the mapping quality score of a read based on the probability of sites being misaligned as per BAQ. Reduces reliance on reads with poor mapping quality.
`-minMapQ 15`                         | Removes reads with low mapping quality. The scale is logarithmic, so a value of 20 represents a probability of ~ 3 in 100 for a mapping mismatch.
`-only_proper_pairs 0`                | Removes unpaired reads.
`-minQ 20`                            | Removes low base read quality. Logarithmic scale.
`-minInd 67`                          | Removes sites that are not present in min number of individuals. Usually allowing 20 % missing data.
`setMinDepth 168`                     | Removes sites below minimum number of reads in the entire pool of individuals (coverage). Set to 2 times the number of individuals, (at least one read per allele, two alleles per individual). Varies depending on the number of individuals.
`-SNP_pval 1e-2`                      | Removes SNPs with p-value of greater than 1e-2, filtering out fixed sites and low frequency SNPs. Only necessary in analyses were fixed sites shoud be discarded.
`-out /output/output_file_name`       | Specifies name and location of the output files.

## REFERENCES

Korneliussen, Thorfinn Sand, Anders Albrechtsen, and Rasmus Nielsen. 2014. “ANGSD: Analysis of Next Generation Sequencing Data.” *BMC Bioinformatics* 15 (1): 356. doi:[10.1186/s12859-014-0356-4](https://doi.org/10.1186/s12859-014-0356-4).