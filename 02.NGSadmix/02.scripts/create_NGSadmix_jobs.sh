Yes_No ()
{
  # print question
  echo -n "This runs the NGSadmix replication wrapper for specified K values and beagle files, submitting each as a SLURM job. Ensure that you have backed up any previous outputs with matching names as they will be overwritten. Would you like to continue? (yes/no)."

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

#Set the output directory.
OUTPUT_DIR="outputs_50reps"

if [ ! -d ${OUTPUT_DIR} ]; then

	mkdir ${OUTPUT_DIR}

fi

if [ ! -d slurm_scripts ]; then

	mkdir slurm_scripts
	
fi

#Set which K values you would like to run the analysis for.
for K in {7..11};

	do
		
		#Set the beagle files you would like to run the analysis on. Do not include the .beagle.gz extension.
		for beagle_file in "new"

			do
			
				sbatch -J K${K}_${beagle_file} -M serial -p serial_long --mail-type=FAIL --mail-user=linda.hagberg@campus.lmu.de -o slurm_scripts/${beagle_file}_K${K}_50reps.out -- wrapper_ngsAdmix.sh -likes ../01.input/${beagle_file}.beagle.gz -K ${K} -P 4 -o ${OUTPUT_DIR}/${beagle_file}_K${K}_50reps -minMaf 0.05 
			done

	done

echo "done..."

}

Yes_No
