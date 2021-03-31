#for pop in POR CSY PHZ AHZ DOB SLO; do
for pop in POR SLO; do

echo "#!/bin/bash
#SBATCH -J saf_${pop}
#SBATCH --output=../03.output/saf_${pop}.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=7
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

angsd -b ../../../inputs/bamlist_${pop}.txt -ref ../../../inputs/grasshopperRef.fasta -anc ../../../inputs/grasshopperRef.fasta -doSaf 1 -doCounts 1 -DoMaf 1 -doMajorMinor 1 -GL 1 -r chr1: -sites ../../../inputs/neutral_sites -minInd 4 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -remove_bads 1 -uniqueOnly 1 -C 50 -baq 1 -setMinDepth 10 -fold 0 -SNP_pval 1 -out ../03.output/saf_${pop}" > ../00.slurmscripts/saf_${pop}.sh

sbatch ../00.slurmscripts/saf_${pop}.sh

done
