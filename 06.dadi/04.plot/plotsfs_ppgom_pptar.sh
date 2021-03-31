#!/bin/bash
#SBATCH -J plotsfsppgom_pptar
#SBATCH --output= plotsfsppgom_pptarout
#SBATCH --cpus-per-task=1
#SBATCH -w 'cruncher'
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python plot_sfs.py ppgom_pptar
