## Principle component analysis (PCA)

PCA's are a common way to visualise differences of samples in a two dimensions. I used Angsd to calculate the components and visualised them using R.

### Creating a beagle file

beagle files are the main input for PCA and [NGSadmix](../02.NGSadmix/). It contains genotype likelihoods, rather than genotype calls. The command to make this beagle file will als create .geno and .mafs file, which contain the genotype calls and allele frequencies, respectively.

#### Making a bamlist

Because a beagle file is created on the population level, one single ile will be generated for all samples used in the PCA. The individuals included in the PCA have to be specified in a bamllist used as an input for the beagle file. A bamlist consists only of the paths to each bam file. Each line is a new path. Importantly, empty lines will also be counted as individuals. The bamlist I used for the PCA contained all 50 *C. parallelus* individuals. I excluded the *C. biguttulus* outgroup, because the variance within them was so large that it drowned out all variance in *C. parallelus*. Below is an example of a bamlist containing 5 individuals:

```
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm1.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm2.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm3.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm4.grasshopperRef.realigned.bam
/dss/dssfs02/lwp-dss-0001/pr62ba/pr62ba-dss-0000/di76yos2/paleomix/jobs/Cery/Cery_PORm5.grasshopperRef.realigned.bam
```

#### Submitting the command to slurm

The slurm script I submitted the angsd command with looks like this: 

```
#!/bin/bash
#SBATCH -J beagle50_output
#SBATCH --output=beagle50.out
#SBATCH --clusters=mpp3
#SBATCH --partition=mpp3_batch
#SBATCH --mem=200000mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=linda.hagberg@campus.lmu.de

angsd -b ../../inputs/bam_list50.txt -ref ../../inputs/grasshopperRef.fasta -doMajorMinor 1 -GL 1 -doGlf 2 -SNP_pval 1e-2 -doMaf 1 -nThreads 2 -r chr1: -sites ../../inputs/neutral_sites -baq 1 -remove_bads 1 -uniqueOnly 1 -C 50 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -doCounts 1 -doPost 2 -doGeno 32 -minInd 40 -setMinDepth 100 -out ../03.output/beagle50
```
The angsd options I use here are explained in [general Angsd options](../README.md)

### PCA

#### Making a Covariance Table
First, unzip the .geno.gz file generated along with the beagle file. 
`gunzip -d [name of genofile].geno.gz`
Count the variable sites in the dataset using
`zcat [name of mafsfile].mafs.gz | tail -n+2 | wc -l`

Finally, to make the covariance table, I used ngsCovar, which is part of angsd. 
```
ngsCovar -probfile [name of genofile].geno     
         -outfile [name of covar table].covar 
         -nind 50 
         -nsites 1494335 
         -call 0 
         -norm 0
```

#### Making a PLINK cluster file
Because the covariance table doesn't assign the individual samples to each datapoint, I had to make a plink cluster file. This file assigns each bam file to their respective data point, which means the order of individuals in your bamlist has to be respected. 

```
Rscript -e 'write.table(cbind(seq(1,50),
                              rep(1,50),
                              c(rep("COR",3),rep("LAT",2),rep("CSY",5),rep("POR",5),rep("ESC",2),
                              rep("BIE",3),rep("DOB",5),rep("ARU",3),rep("GAB",2),rep("PAS",5),
                              rep("SVI",1),rep("VRE",3),rep("SVI",1),rep("GOM",5),rep("TAR",5))),
                        row.names=F,
                        col.names=c("FID","IID","CLUSTER"),
                        sep ="\t",file="plink_all55.clst",quote=F)'
```

#### Making a PCA plot

I made plots of the components 1 through 4, in two plots. An R script comes with angsd can do this for you. Because I wanted to adapt the colours to match the rest of the figures in the paper, I changed it a little. The script I used can be found [here](02.scripts/pca.R). 