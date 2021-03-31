#!/bin/bash
#SBATCH -J theta_SLO
#SBATCH --output=../03.output/theta_SLO.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de


~/programs/Angsd/angsd/angsd -b ../../../inputs/bamlist_SLO.txt -ref ../../../inputs/grasshopperRef.fasta -anc ../../../inputs/grasshopperRef.fasta -doThetas 1 -pest ../../../05.SFS/02.sfs/03.output/SFS_SLO.sfs -doSaf 1 -doCounts 1 -GL 1 -r chr1: -sites ../../../inputs/neutral_sites -minInd 4 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -remove_bads 1 -uniqueOnly 1 -C 50 -baq 1 -setMinDepth 10 -out ../03.output/theta_SLO
