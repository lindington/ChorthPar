#!/bin/bash
#SBATCH -J ppgom_pptar_symmig_lrt
#SBATCH --output=ppgom_pptar_symmig_lrt.out
#SBATCH --cpus-per-task=1
#SBATCH -w 'cruncher'
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python GIM_LRT.py ppgom_pptar sym_mig

