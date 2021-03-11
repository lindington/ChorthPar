#This is used to submit batch jobs for demographic model runs using demo_model_run.py. Can specify taxa, model, folding, and number of replicate runs.

Yes_No ()
{
  # print question
  echo -n "This will begin optimization runs for the taxa and model combinations defined in the loops below. Once these begin, all previous results and log files will be overwritten, including summary files of parallel runs. Please back up any files you do not wish to overwrite. Would you like to continue? (yes/no)"

  echo

  # read answer
  read YnAnswer

  # all to lower case
  YnAnswer=$(echo $YnAnswer | awk '{print tolower($0)}')

  # check and act on given answer
  case $YnAnswer in
    "yes")  Start_Install ;;
	"y") Start_Install ;;
	"no") exit 0 ;;
	"n") exit 0 ;;
    *)      echo "Please answer yes or no" ; Yes_No ;;
  esac
}

Start_Install ()
{

#Specify taxa pairs
for taxa in cpery_cppar ppgom_pptar; do

    #Make directories if they don't exist
	
	SCRIPTS_DIR="../00.slurmscripts/${taxa}/"
	OUT_DIR="../03.output/${taxa}/"
	TEMP_DIR="../99.temp/${taxa}"
	

	if [ ! -d $SCRIPTS_DIR ]; then

		mkdir -p $SCRIPTS_DIR

	fi

	if [ ! -d $OUT_DIR ]; then

		mkdir -p $OUT_DIR

	fi

	if [ ! -d $TEMP_DIR ]; then

		mkdir -p $TEMP_DIR

	fi
	#Specify demographic models

	for model in no_mig sym_mig asym_mig sec_contact_sym_mig sec_contact_asym_mig; do

		#Specify folding 'fold' or 'unfold'
		for folding in fold unfold; do

			#If you would like to keep the result summary file and simply add to it, either run the demo_model_run.py script directly from the command line, or comment out the if statement below.
			#if [ -e ${OUT_DIR}/results_summary/${taxa}_${folding}_${model}_results_summary.txt ]; then

			#	rm ${OUT_DIR}/results_summary/${taxa}_${folding}_${model}_results_summary.txt

			#fi
			#Specify how many replicate runs
			for runs in 3; do

#Build batch script
echo "#!/bin/bash
#SBATCH -J ${taxa}_${folding}_${model}_run${runs}
#SBATCH --output=${SCRIPTS_DIR}/${taxa}_${folding}_${model}_run${runs}.out
#SBATCH --cpus-per-task=1
#SBATCH --partition=usual
#SBATCH -w cruncher
#SBATCH --mem=500mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=Linda.Hagberg@gmail.com
#SBATCH --time=24:00:00

python demo_model_run.py ${taxa} ${model} ${runs} ${folding}" > ${SCRIPTS_DIR}/${taxa}_${folding}_${model}_optrun${runs}.sh

#Submit batch script
sbatch ${SCRIPTS_DIR}/${taxa}_${folding}_${model}_optrun${runs}.sh

#Slow it down so SLURM has time to breathe
sleep 1

			done

		done

	done

done

}

Yes_No