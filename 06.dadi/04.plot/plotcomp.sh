#!/bin/bash
#SBATCH -J plota
#SBATCH --output=plota.out
#SBATCH --cpus-per-task=1
#SBATCH -w 'cruncher'
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

#python plot_sfs.py cpery_cppar

#python Make_Plots.py ppgom_pptar no_mig
#python Make_Plots.py cpery_cppar no_mig
#python Make_Plots.py ppgom_pptar sym_mig
#python Make_Plots.py cpery_cppar sym_mig
python Make_Plots.py cpery_cppar sc_mig
