#!/bin/bash
#SBATCH -J cpery_cppar_scasymmig_lrt
#SBATCH --output=cpery_cppar_scasymmig_lrt.out
#SBATCH --cpus-per-task=1
#SBATCH -w 'cruncher'
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python GIM_LRT.py cpery_cppar sec_contact_asym_mig

