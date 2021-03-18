#for pop in ERY PAR TAR GOM; do #use for first batch

for pop in POR CSY PHZ AHZ DOB SLO; do #use for second batch of pops

echo "#!/bin/bash
#SBATCH -J theta_${pop}
#SBATCH --output=../03.output/theta_${pop}.out
#SBATCH --clusters=mpp3
#SBATCH --partition=mpp3_batch
#SBATCH --cpus-per-task=3
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH -t 48:00:00

angsd -b ../../../inputs/bamlist_${pop}.txt -ref ../../../inputs/grasshopperRef.fasta -anc ../../../inputs/grasshopperRef.fasta -doThetas 1 -pest ../../../05.SFS/02.sfs/03.output/SFS_${pop}.sfs -doSaf 1 -doCounts 1 -GL 1 -r chr1: -sites ../../../inputs/neutral_sites -minInd 4 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -remove_bads 1 -uniqueOnly 1 -C 50 -baq 1 -setMinDepth 10 -out ../03.output/saf_${pop}" > ../00.slurmscripts/theta_${pop}.sh

sbatch ../00.slurmscripts/theta_${pop}.sh

done
