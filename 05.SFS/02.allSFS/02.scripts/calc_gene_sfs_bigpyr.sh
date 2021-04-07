#!/bin/bash
#SBATCH -J calc_gene_sfs_pyr_big
#SBATCH --output=../03.output/calc_gene_sfs_pyr_bigrun1.out
#SBATCH --cpus-per-task=4
#SBATCH --clusters=mpp3
#SBATCH --partition=mpp3_batch
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=linda.hagberg@campus.lmu.de
#SBATCH --time=48:00:00

#Builds SFS for each gene within specified species pairs.
#These take a very long time to run. Approx. 48 hours per pair. I split this up into two runs (one per hybrid zone) for it not to take several days.


#Load list of genes from reference.
genes=`cat ../01.input/grasshopperRef_chr1genes`


#Loop over all genes
for gene in $genes; do
	
	gene_name=`echo "$gene" | cut -c 6-`
		
	if [ -f ../03.output/01.bigpyr/2dsfs_pyr_big_fold0_${gene_name}.sfs ]; then
		
		echo "Skipping ${gene}, already analyzed..."
			
	else
		
		echo ""
		echo "Building SFS for region: $gene"
		echo ""
					
		echo $gene_name
				
		realSFS ../../01.saf/03.output/saf_p_ery_big.saf.idx ../../01.saf/03.output/saf_p_fra_big.saf.idx -r $gene -P 1 > ../03.output/01.bigpyr/2dsfs_pyr_big_fold0_${gene_name}.sfs
		
	fi

done
	
	
#Delete any SFS without data
find ../03.output/01.bigpyr/ -size 0 -delete

