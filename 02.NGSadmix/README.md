## NGSadmix

To assess population admixture, I used NGSadmix as implemented in angsd. To obtain the highest likelihood clustering of individuals, I used a [wrapper](02.scripts/wrapper_ngsAdmix.sh) built by Filipe G. Vieira, which runs multiple replicates of each analysis (here: 50 times) and outputs the one with the highest likelihood as the final result.

I call this wrapper in my script [create_NGSadmix_jobs](02.scripts/create_NGSadmix_jobs.sh), which loops the analysis over different numbers of clusters K at the same time. 

#### Plotting
To plot the results, I used [this script](04.plot/ngsadmix.R). 