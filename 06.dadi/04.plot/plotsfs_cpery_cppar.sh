#!/bin/bash
#SBATCH -J plotsfscpery_cppar
#SBATCH --output= plotsfscpery_cpparout
#SBATCH --cpus-per-task=1
#SBATCH -w 'cruncher'
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python plot_sfs.py cpery_cppar
