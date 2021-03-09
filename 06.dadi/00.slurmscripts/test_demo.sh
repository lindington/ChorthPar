#!/bin/bash
#SBATCH -J ccpar_cppery_fold_nomig_1_snp
#SBATCH --output=cppar_cpery_no_mig_1_fold_snp
#SBATCH --cpus-per-task=1
#SBATCH --clusters=cm2
#SBATCH --partition=cm2_std
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python demo_model_run.py cppar_cpery no_mig 1 fold snp

## dadi not found on lrz -> move to crunchr (conda installed)

