#!/bin/bash
#SBATCH -J site_theta_DOB
#SBATCH --output=../03.output/site_theta_DOB.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de


~/programs/Angsd/angsd/misc/realSFS saf2theta ../../../05.SFS/01.saf/03.output/saf_DOB.saf.idx -sfs ../../../05.SFS/02.sfs/03.output/SFS_DOB.sfs -outname ../03.output/site_theta_DOB
