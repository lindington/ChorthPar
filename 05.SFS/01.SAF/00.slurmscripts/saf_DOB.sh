#!/bin/bash
#SBATCH -J saf_DOB
#SBATCH --output=../03.output/saf_DOB.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_long
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

angsd -b ../../../inputs/bamlist_DOB.txt -ref ../../../inputs/grasshopperRef.fasta -anc ../../../inputs/grasshopperRef.fasta -doSaf 1 -doCounts 1 -DoMaf 1 -doMajorMinor 1 -GL 1 -r chr1: -sites ../../../inputs/neutral_sites -minInd 4 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -remove_bads 1 -uniqueOnly 1 -C 50 -baq 1 -setMinDepth 10 -fold 0 -SNP_pval 1 -out ../03.output/saf_DOB
