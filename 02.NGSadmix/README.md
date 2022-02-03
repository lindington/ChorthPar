## NGSadmix

To assess population admixture, I used NGSadmix as implemented in AMGSD. To obtain the highest likelihood clustering of individuals, I used a [wrapper](02.scripts/wrapper_ngsAdmix.sh) built by Filipe G. Vieira, which runs multiple replicates of each analysis (here: 50 times) and outputs the one with the highest likelihood as the final result.

I call this wrapper in my script [create_NGSadmix_jobs](02.scripts/create_NGSadmix_jobs.sh), which loops the analysis over different numbers of clusters K at the same time. 

This outputs a `.qopt` file for every number of clusters K. 

#### Plotting
To plot the results in a structure plot, I used the R script [ngsadmix.R](04.plot/ngsadmix.R). 