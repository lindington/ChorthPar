# Can gene flow occur in spite of male sterility? Insights from a grasshopper hybrid zone

This repository contains all the scripts and data for my Lehre@LMU project. An in-depth README for each of the 3 components are available. This README contains general information about the analyses I conducted, an introduction to working on the LMU's LRZ server and some preliminary work.

## Project Components

I have devided this repository into three folders, which contain detailed scripts and data from each analysis:

- [ABBA-BABA Test](01.ABBABABA)
- [Site Frequency Spectra](02.SFS)
- [Demographic Modeling using ∂a∂i](03.dadi)


## Using the Server

All my analyses were run on the Leibniz-Rechenzentrum's (LRZ) Linux-Cluster systems from LMU. Once you have account access through your LRZ-ID, you will be able to use your account and directory for storing files and submitting jobs. Short jobs may be run directly from the command line via SSH, while longer running jobs should be submitted to the SLURM queue, which manages budgets and resources.

#### Connecting to LRZ

LRZ can be accessed via SSH with

`ssh username@lxlogin8.lrz.de`

There are multiple log in nodes, and some partitions will require you to start jobs from a certain node. More information about the different log in nodes and getting access is available [here](https://doku.lrz.de/display/PUBLIC/Access+and+Login+to+the+Linux-Cluster).

After this, you will be prompted for your password.

You may have to confirm you 'trust' the connection when you first access the cluster. You will be logged in to your home directory, where you can navigate using command line syntax.

#### Modifying the .bashrc

After successfully logging in, you should first modify your .bashrc file in your home directory. You can do this with any text editor, my preferred is vim. To modify your .bashrc file, type:
`cd`(brings you to your home directory)
`vim .bashrc` (opens the hidden .bashrc file in the text editor vim)

Press the 'a' key to INSERT and paste the following lines in the file:

```
export PROJECT=/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/username
export MODULEPATH=${MODULEPATH}:/home/hpc/pr62ba/di49pey3/modenv
```

To save and exit, press ESC and type ':x'. To exit without saving, type ':q!'.
These modifications will make a shortcut to the directory of your project and a path to the modules. A detailed documentation of vim can be found [here](http://vimdoc.sourceforge.net/htmldoc/intro.html).

#### Loading a program

To use a program, you need to load it first with the following command:
`module load [program]`

For a full list of available programs in the server, use the command:
`module avail`

To use a program that isnt available in the server, either install it locally or use conda. 

#### Submitting a job

Bioinformatic processes can take a lot of time, so running multiple tasks in parallel will make your work more efficient. To do this, you can write SLURM scripts (.sh files) which will be submitted to a cluster. The clusters which are available from LRZ have different settings and should be used for different kinds of processes. Which cluster to chose depends on how much memory and running time your job needs. There is a detailed list of the available clusters [here](https://doku.lrz.de/display/PUBLIC/Available+SLURM+clusters+and+features).

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

module load bioinfo-tools
module load angsd

angsd -b /01.input/bam_list.txt -ref /01.input/grasshopperRef.fasta -doMajorMinor 1 -GL 1 -doGlf 2 -SNP_pval 1e-2 -doMaf 1 -nThreads 2 -r chr1: -sites /01.input/neutral_sites -baq 1 -remove_bads 1 -uniqueOnly 1 -C 50 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -doCounts 1 -doPost 2 -doGeno 32 -minInd 41 -setMinDepth 102 -out /02.output/beagle

ENDTIME=$(date +%s)
TIMESPEND=$(($ENDTIME - $STARTTIME))
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60))

timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)

echo "Job ended at $(date). Took $timestamp hours:minutes:seconds to complete."
```
Submit the job with
`sbatch example.sh`

See the status of your submitted jobs with
`squeue -M [clustername] | grep [yourLRZusername]`

You can cancel a job with
`scancel -M [clustername] [jobID]`


There is a summary of the LRZ's SLURM status and a list with all partitions and waiting times [here](https://www.lrz.de/services/compute/linux-cluster/status/SLURM/SLURM_Status.html). A full documentation of SLURM and SLURM commands is available [here](https://slurm.schedmd.com).


## ANGSD Basics

Many analyses are performed in ANGSD (Korneliussen, Albrechtsen & Nielsen, 2014), a tool for analysing next generation sequencing data. The primary data type used by ANGSD are bam files (.bam), which contain genetic sequences aligned to a reference. The bam files I used were produced by Clara during her thesis and are stored in Enrique's folder on the LRZ.

#### Reference Transcriptome

When ANGSD reads in bamfiles, it compares them to a reference genome. The reference genome I used, *C. parallelus*, was built by Ricardo and can be found in the [input folders](01.input) of each component as `grasshopper_Ref.fasta` and must have its index file (`.fai`) with it. The `.positions` file contains the site information for each gene in the genome.

This reference transcriptome was built from transcriptomic data of all *C. parallelus* males in this dataset. The genome is organised into four artificial 'chromosomes', which each contain certain types of genes: (1) contains 16,970 single cope genes, 12,735 with identified open reading frames (ORFs) and 4,235 without; (2) contains 4,263 multi-copy genes; (3) contains 18,623 genes found onl in a subset of *C. parallelus* individuals; and (4) contains the 13 mitochondrial genes.

```
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm1.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm2.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm3.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm4.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm5.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PERYm1.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PERYm2.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PERYm3.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PERYm4.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PERYm5.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cpar/trimmed/Cpar_PPARm1.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cpar/trimmed/Cpar_PPARm2.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cpar/trimmed/Cpar_PPARm3.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cpar/trimmed/Cpar_PPARm4.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cpar/trimmed/Cpar_PPARm5.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cpar/trimmed/Cpar_TARm1.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cpar/trimmed/Cpar_TARm2.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cpar/trimmed/Cpar_TARm3.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cpar/trimmed/Cpar_TARm4.grasshopperRef.realigned.bam
```


#### Neutral Sites

Most demographic analyses rely on neutral evolution, which is why it has to be specified which sites are not under selective pressure. In this case (like in the SFS and ∂a∂i analyses), I only include neutral sites in the analyses, such as the untranslated regions, and the third position of each codon, as they rarely affect the function of the genes. A list of these [neutral sites](01.input/neutral_sites) is found in
the input folder of each component folder and included in the ANGSD command when relevant.

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


## 01.ABBABABA

The ABBA-BABA test detects gene flow between populations by calculating bias of discordance between gene trees and population trees. The bias is calculated by comparing the sites adhering to ABBA with sites adhering to BABA, with A = ancestral and B = derived. Each site is noted A or B for each population with the relationship (((H1,H2),H3),H4), with H4 being the outgroup.

When the gene tree for a site matches the species tree, the layout for the site is BBAA. However, the informal sites are the ones that do not match the species tree (ABBA or BABA). Since H1 and H2 are equally as related to H3, there should not be a bias toward one of the two layouts, if the discordance between gene tree and species tree was purely due to incomplete lineage sorting. A significant overrepresentation of ABBA or BABA sites indicates gene flow between the B-noted populations.

The proportions of ABBA and BABA are described by the D-statistic. A D-value of 0 indicates no significant bias, a positive D-value indicates bias towards ABBA (gene flow between H2 and H3), and a negative D-value indicates bias towards BABA (gene flow between H1 and H3).


## 02.SFS

A site frequency spectrum (SFS) is a summary statistic, which describes the distribution of allele frequencies in a sample. This can be used to infer demographic parameters for a population, such as gene flow. For this project, I use two population SFS (2D SFS) to fit demographic models in ∂a∂i.

## 03.dadi
