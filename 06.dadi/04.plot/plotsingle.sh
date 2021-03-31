for taxa in cpery_cppar ppgom_pptar; do

echo "#!/bin/bash
#SBATCH -J plotsfs${taxa}
#SBATCH --output= plotsfs${taxa}out
#SBATCH --cpus-per-task=1
#SBATCH -w 'cruncher'
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python plot_sfs.py ${taxa}" > plotsfs_${taxa}.sh 

sbatch plotsfs_${taxa}.sh

done
