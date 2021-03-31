#!/bin/bash

#SBATCH -J aballpops
#SBATCH --output=aballpops.out
#SBATCH --cpus-per-task=6
#SBATCH -n 1
#SBATCH --clusters=inter
#SBATCH --partition=teramem_inter
#SBATCH --mail-type=ALL
#SBATCH --mail-user=linda.hagberg@campus.lmu.de
#SBATCH -t 100:00:00

STARTTIME=$(date +"%s")

~/programs/Angsd/angsd -b ../01.input/bam_list55.txt -ref ../01.input/grasshopperRef.fasta -doMajorMinor 1 -GL 1 -doMaf 1 -doCounts 1 -doAbbababa2 1 -sizeFile ../01.input/pop_all.size -useLast 1 -r chr1: -baq 1 -remove_bads 1 -uniqueOnly 1 -C 50 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -minInd 44 -setMinDepth 110 -SNP_pval 1e-6 -out ../03.output/ab_allpops

ENDTIME=$(date +%s)
TIMESPEND=$(($ENDTIME - $STARTTIME))
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60))

timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)

echo "Job ended at $(date). Took $timestamp hours:minutes:seconds to complete."
