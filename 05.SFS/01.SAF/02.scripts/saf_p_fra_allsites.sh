#!/bin/bash
#SBATCH -J saf_p_fra_allsites
#SBATCH --output=../03.output/saf_p_fra_allsites.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_long
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

STARTTIME=$(date +"%s")

angsd -b ../01.input/bamlist_p_fra.txt -ref ../01.input/grasshopperRef.fasta -anc ../01.input/grasshopperRef.fasta -doSaf 1 -doCounts 1 -DoMaf 1 -doMajorMinor 1 -GL 1 -r chr1: -minInd 4 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -remove_bads 1 -uniqueOnly 1 -C 50 -baq 1 -setMinDepth 10 -fold 0 -SNP_pval 1 -out ../03.output/saf_p_fra_allsites

ENDTIME=$(date +%s)
TIMESPEND=$(($ENDTIME - $STARTTIME))
((sec=TIMESPEND%60,TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60))
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)
echo "Took $timestamp hours:minutes:seconds to complete..."
