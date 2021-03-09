#!/bin/bash
#SBATCH -J ppgom_pptar_unfold_no_mig_3
#SBATCH --output=ppgom_pptar_no_mig_3_unfold
#SBATCH -w 'cruncher'
#SBATCH --cpus-per-task=4
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python demo_model_run_big.py ppgom_pptar no_mig 3 unfold
