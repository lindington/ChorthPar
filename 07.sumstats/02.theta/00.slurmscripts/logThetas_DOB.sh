#!/bin/bash
#SBATCH -J logtheta_DOB
#SBATCH --output=../03.output/logThetas_DOB.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

~/programs/Angsd/angsd/misc/thetaStat print ../03.output/site_theta_DOB.thetas.idx > ../03.output/logThetas_DOB.chr1
