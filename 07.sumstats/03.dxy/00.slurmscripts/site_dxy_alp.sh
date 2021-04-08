#!/bin/bash
#SBATCH -J site_dxy_alp
#SBATCH --output=../03.output/site_dxy_alp.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

module load r 

Rscript calcDxy.R -p ../../../05.SFS/01.SAF/03.output/saf_TAR.mafs.gz -q ../../../05.SFS/01.SAF/03.output/saf_GOM.mafs.gz -t 163091 
