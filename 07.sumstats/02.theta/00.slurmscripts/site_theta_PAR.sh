#!/bin/bash
#SBATCH -J site_theta_PAR
#SBATCH --output=../03.output/site_theta_PAR.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de


~/programs/Angsd/angsd/misc/realSFS saf2theta ../../../05.SFS/01.saf/03.output/saf_PAR.saf.idx -sfs ../../../05.SFS/02.sfs/03.output/SFS_PAR.sfs -outname ../03.output/site_theta_PAR
