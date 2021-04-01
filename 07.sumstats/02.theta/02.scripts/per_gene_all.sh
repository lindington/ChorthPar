for pop in ERY PAR TAR GOM POR CSY PHZ AHZ DOB SLO; do 

echo "#!/bin/bash
#SBATCH -J site_theta_${pop}
#SBATCH --output=../03.output/site_theta_${pop}.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de


Rscript per_gene.R" > ../00.slurmscripts/gene_theta_${pop}.sh

sbatch ../00.slurmscripts/gene_theta_${pop}.sh

done