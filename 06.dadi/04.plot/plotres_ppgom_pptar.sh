#!/bin/bash
#SBATCH -J plotres_ppgom_pptar
#SBATCH --output=plotres_ppgom_pptar.out
#SBATCH --cpus-per-task=1
#SBATCH -w 'cruncher'
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python Make_Plots.py ppgom_pptar sym_mig
