
#specify taxa pairs
for taxa in cpery_cppar ppgom_pptar; do

#Make directories if they don't exist
	SCRIPTS_DIR="../00.slurmscripts/${taxa}/"
	OUT_DIR="../03.output/${taxa}/"
		

	if [ ! -d $SCRIPTS_DIR ]; then

		mkdir -p $SCRIPTS_DIR

	fi

	if [ ! -d $OUT_DIR ]; then

		mkdir -p $OUT_DIR

	fi
    
    #specify model
	for model in no_mig sym_mig asym_mig sec_contact_sym_mig sec_contact_asym_mig; do

#make slurmscript
echo "#!/bin/bash
#SBATCH -J ${taxa}_${model}_lrt
#SBATCH --output=${taxa}_${model}_lrt.out
#SBATCH --cpus-per-task=1
#SBATCH -w 'cruncher'
#SBATCH --partition=usual
#SBATCH --mem=200mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH --time=24:00:00

module load dadi

python GIM_LRT.py ${taxa} ${model}" > ${SCRIPTS_DIR}/${taxa}_${model}_lrt.sh

#submit slurmscript
sbatch ${SCRIPTS_DIR}/${taxa}_${folding}_${model}_optrun${runs}.sh

    done
done
