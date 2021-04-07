for pop in ERY PAR TAR GOM POR CSY PHZ AHZ DOB SLO; do 

echo "#!/bin/bash
#SBATCH -J logtheta_${pop}
#SBATCH --output=../03.output/logThetas_${pop}.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

~/programs/Angsd/angsd/misc/thetaStat print ../03.output/site_theta_${pop}.thetas.idx > ../03.output/logThetas_${pop}.chr1" > ../00.slurmscripts/logThetas_${pop}.sh

sbatch ../00.slurmscripts/logThetas_${pop}.sh

done
