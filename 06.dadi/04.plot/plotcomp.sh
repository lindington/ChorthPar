for taxa in cpery_cppar ppgom_pptar; do

echo "#!/bin/bash
#SBATCH -J plotres_${taxa}
#SBATCH --output=plotres_${taxa}.out
#SBATCH --cpus-per-task=1
#SBATCH -w 'cruncher'
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python Make_Plots.py ${taxa} sym_mig" > plotres_${taxa}.sh

sbatch plotres_${taxa}.sh

done
