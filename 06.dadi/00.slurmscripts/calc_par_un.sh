#!/bin/bash
#SBATCH -J calc_param_uncert
#SBATCH --output=calc_par_un.out
#SBATCH --cpus-per-task=1
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00


python calc_params_uncert.py
