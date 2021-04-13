#!/bin/bash
#SBATCH -J site_dxy_all
#SBATCH --output=../03.output/site_dxy_all.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

module load r 

Rscript calcDxy.R
