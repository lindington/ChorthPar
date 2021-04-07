#!/bin/bash
#SBATCH -J logtheta_CSY
#SBATCH --output=../03.output/logThetas_CSY.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

~/programs/Angsd/angsd/misc/thetaStat print ../03.output/site_theta_CSY.thetas.idx > ../03.output/logThetas_CSY.chr1
