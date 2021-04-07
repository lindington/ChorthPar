#!/bin/bash
#SBATCH -J gene_theta
#SBATCH --output=../03.output/gene_theta.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --mem=10000mb
#SBATCH --cpus-per-task=7
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

module load r

Rscript per_gene_.R
