for hz in pyr alp; do
       if [ ${hz} == "pyr" ] ; then 
	       pop1="ERY"
	       pop2="PAR"
	       length="177622"

# guessing i should use shortest length, but why? 	      
#177622 saf_ERY.mafs.gz
#182455 saf_PAR.mafs.gz
#163091 saf_GOM.mafs.gz
#166805 saf_TAR.mafs.gz

       elif [ ${hz} == "alp" ] ; then
	       pop1="TAR"
	       pop2="GOM"
	       length="163091"

       else echo "pop makes no sense"
       fi
	      
echo "#!/bin/bash
#SBATCH -J site_dxy_${hz}
#SBATCH --output=../03.output/site_dxy_${hz}.out
#SBATCH --clusters=serial
#SBATCH --partition=serial_std
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de

module load r 

Rscript calcDxy.R -p ../../../05.SFS/01.SAF/03.output/saf_${pop1}.mafs.gz -q ../../../05.SFS/01.SAF/03.output/saf_${pop2}.mafs.gz -t ${length} " > ../00.slurmscripts/site_dxy_${hz}.sh 

sbatch ../00.slurmscripts/site_dxy_${hz}.sh

done
