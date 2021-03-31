#!/bin/bash
#SBATCH -J saf_a_tar
#SBATCH --output=../02.output/saf_a_tar.out
#SBATCH --clusters=mpp3
#SBATCH --partition=mpp3_batch
#SBATCH --cpus-per-task=3
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH -t 48:00:00

STARTTIME=$(date +"%s")

angsd -b ./bamlist_a_tar.txt -ref ./grasshopperRef.fasta -anc ./grasshopperRef.fasta -doSaf 1 -doCounts 1 -DoMaf 1 -doMajorMinor 1 -GL 1 -r chr1: -sites ./neutral_sites -minInd 4 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -remove_bads 1 -uniqueOnly 1 -C 50 -baq 1 -setMinDepth 10 -fold 0 -SNP_pval 1 -out ../02.output/saf_a_tar

ENDTIME=$(date +%s)
TIMESPEND=$(($ENDTIME - $STARTTIME))
((sec=TIMESPEND%60,TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60))
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)
echo "Took $timestamp hours:minutes:seconds to complete..."
