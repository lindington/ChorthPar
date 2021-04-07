#!/bin/bash
#SBATCH -J calc_gene_sfs_pyr
#SBATCH --output=../03.output/calc_gene_sfs_pyr_run3.out
#SBATCH --cpus-per-task=4
#SBATCH --clusters=serial
#SBATCH --partition=serial_long
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=linda.hagberg@campus.lmu.de

#Builds SFS for each gene within specified species pairs.
#These take a very long time to run. Approx. 24 hours per pair. I split this up into 2 runs (one per hybrid zone) for it not to take several days.
#conda activate pca for this version of angsd doenst work?

#Load list of genes from reference.
genes=`cat ../01.input/grasshopperRef_chr1genes`


#Loop over all genes
for gene in $genes; do
	
	gene_name=`echo "$gene" | cut -c 6-`
		
	if [ -f ../03.output/03.pyr_allsites/2dsfs_pyr_${gene_name}.sfs ]; then
		
		echo "Skipping ${gene}, already analyzed..."
			
	else
		
		echo ""
		echo "Building SFS for region: $gene"
		echo ""
					
		echo $gene_name
				
		#realSFS ../01.input/saf_p_ery_allsites.saf.idx ../01.input/saf_p_fra_allsites.saf.idx -r $gene -P 1 > ../03.output/2dsfs_pyr_${gene_name}.sfs
		#try with .ml file instead of .sfs
		realSFS ../../01.saf/03.output/saf_p_ery_allsites.saf.idx ../../01.saf/03.output/saf_p_fra_allsites.saf.idx -r $gene -P 1 > ../03.output/03.pyr_allsites/2dsfs_pyr_${gene_name}.sfs
		
	fi

done
	
	
#Delete any SFS without data
find ../03.output/03.pyr_allsites/ -size 0 -delete

