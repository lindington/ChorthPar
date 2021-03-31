#!/bin/bash
#SBATCH -J saf_test1_ery
#SBATCH --output=../03.output/saf_test1_ery.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --mem=10000mb
#SBATCH --cpus-per-task=7
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH -t 48:00:00

STARTTIME=$(date +"%s")

angsd -b ../../../inputs/bamlist_ERY.txt -ref ../../../inputs/grasshopperRef.fasta -anc ../../../inputs/grasshopperRef.fasta -doSaf 1 -doCounts 1 -DoMaf 1 -doMajorMinor 1 -GL 1 -r chr1: -sites ../../../inputs/neutral_sites -minInd 4 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -remove_bads 1 -uniqueOnly 1 -C 50 -baq 1 -setMinDepth 10 -fold 0 -SNP_pval 1 -out ../03.output/saf_test1_ery

#angsd -b ../../../inputs/bamlist_CSY.txt -ref ../../../inputs/grasshopperRef.fasta -anc ../../../inputs/grasshopperRef.fasta -doSaf 1 -doCounts 1 -DoMaf 1 -doMajorMinor 1 -GL 1 -r chr1: -sites ../../../inputs/neutral_sites -minInd 4 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -remove_bads 1 -uniqueOnly 1 -C 50 -baq 1 -setMinDepth 10 -fold 0 -SNP_pval 1 -out ../03.output/saf_CSY

ENDTIME=$(date +%s)
TIMESPEND=$(($ENDTIME - $STARTTIME))
((sec=TIMESPEND%60,TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60))
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)
echo "Took $timestamp hours:minutes:seconds to complete..."
