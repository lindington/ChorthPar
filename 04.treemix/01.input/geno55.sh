#!/bin/bash
#SBATCH -J geno55_output
#SBATCH --output=geno55.out
#SBATCH --clusters=inter
#SBATCH --partition=teramem_inter
#SBATCH --cpus-per-task=6
#SBATCH --mem=200000mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=linda.hagberg@campus.lmu.de
#SBATCH -t 4-00:00:00


STARTTIME=$(date +"%s")


~/programs/Angsd/angsd -b ../../00.beagle/01.input/bam_list55.txt -ref ../../00.beagle/01.input/grasshopperRef.fasta -doMajorMinor 1 -GL 1 -doGlf 2 -SNP_pval 1e-2 -doMaf 1 -nThreads 2 -r chr1: -sites ../../00.beagle/01.input/neutral_sites -baq 1 -remove_bads 1 -uniqueOnly 1 -C 50 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -doCounts 1 -doPost 2 -doGeno 2 -postCutoff 0.95 -geno_minDepth 2 -minInd 44 -setMinDepth 110 -out real55

ENDTIME=$(date +%s)
TIMESPEND=$(($ENDTIME - $STARTTIME))
((sec=TIMESPEND%60, TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60))

timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)

echo "Job ended at $(date). Took $timestamp hours:minutes:seconds to complete."

