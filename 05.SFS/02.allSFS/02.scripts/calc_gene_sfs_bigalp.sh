#!/bin/bash
#SBATCH -J calc_gene_sfs_alp_big
#SBATCH --output=../03.output/calc_gene_sfs_alp_bigrun1.out
#SBATCH --cpus-per-task=1
#SBATCH --clusters=mpp3
#SBATCH --partition=mpp3_batch
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=linda.hagberg@campus.lmu.de
#SBATCH --time=48:00:00

#Builds SFS for each gene within specified species pairs.
#These take a very long time to run. Approx. 24 hours per pair. I split this up into 2 runs (one per hybrid zone) for it not to take several days.


#Load list of genes from reference.
genes=`cat ../01.input/grasshopperRef_chr1genes`


#Loop over all genes
for gene in $genes; do
	
	gene_name=`echo "$gene" | cut -c 6-`
		
	if [ -f ../03.output/02.bigalp/2dsfs_alp_big_fold0_${gene_name}.sfs ]; then
		
		echo "Skipping ${gene}, already analyzed..."
			
	else
		
		echo ""
		echo "Building SFS for region: $gene"
		echo ""
					
		echo $gene_name
				
		realSFS ../../01.saf/03.output/saf_a_gom_big.saf.idx ../../01.saf/03.output/saf_a_tar_big.saf.idx -r $gene -P 1 > ../03.output/02.bigalp/2dsfs_alp_big_fold0_${gene_name}.sfs
		
	fi

done
	
	
#Delete any SFS without data
find ../03.output/02.bigalp/ -size 0 -delete

