## Demographic Analysis (δaδi)
δaδi is a demographic inference tool developed by Gutenkunst et al. (2009). It uses diffusion approximation to fit an estimated SFS to your data SFS. Using an optimisation algorithm, it explores the parameters in the demographic model, allowing it to find the maximum likelihood parameter values. This maximum likelihood can be used to select the best fitting demographi
c model from a set of candidate models, and these parameter estimates can be used to infer demographic history.

Fitting demographic models allows multiple hypotheses to be tested. For instance, I am comparing a models with and without migration between two populations to see which is more likely. First, you choose models that are appropriate to answer your question. For this thesis, I use the four models pictured below: (1) Divergence without Gene Flow (no_mig), (2) Divergence with Symmetric Gene Flow (sym_mig), (3) Secondary Contact with Symmetric Gene Flow (anc_sym_mig), and (4) Secondary Contact with Asymmetric Gene Flow.

#### Producing SFS

I built 2D SFS for the two hybrid zone comparisons. The protocol for this can be found in the [SFS section](../05.SFS/) of this repository. Unlike [Zach](https://github.com/zjnolen/chorthippus_demography/tree/master/dadi#sfs-production), I only made linked SFS. These were used for all downstream analyses. To ensure I used as much data as possible for the parameter estimation, I used traditional bootstrap fits of our non-parametric bootstraps for uncertainties.

#### Model Fitting (Optimisation)

I used the dadi_pipeline developed by Portik et al. (2017) with adjustments from Nolen et al. (2020) for model fitting. Zach built a script [demo_model_run.py](/06.dadi/02.scripts/demo_model_run.py) which can be called from the command line to run one dadi_pipeline optimisation run on an SFS. Unlike Zach, I did not fold the SFS.

This optimisation run had the following pipeline parameters:


    initials = {
	    "no_mig":[0.5,1.5,0.3],
	    "sym_mig":[1,2,0.5,1],
        "asym_mig":[1,1,0.5,0.5,0.5],
        "sec_contact_sym_mig":[1,1,0.5,0.5,0.5],
        "sec_contact_asym_mig":[1,1,0.5,0.5,0.5,0.5]
        }

    uppers = {
        "no_mig":[5,5,2],
        "sym_mig":[5,5,2,2],
        "asym_mig":[3,3,2,2,2],
        "sec_contact_sym_mig":[3,3,2,2,2],
        "sec_contact_asym_mig":[3,3,2,2,2,2]
            }	

	
    param_labels = {
        "no_mig":"nu1, nu2, T",
        "sym_mig":"nu1, nu2, m, T",
        "asym_mig":"nu1, nu2, m12, m21, T",
        "sec_contact_sym_mig":"nu1,nu2,m,T1,T2",
        "sec_contact_asym_mig":"nu1,nu2,m12,m21,T1,T2"
        }

    lowers = {
        "no_mig":[0.01,0.01,0.01],
        "sym_mig":[0.01,0.01,0.01,0.01],
        "asym_mig":[0.01,0.01,0.01,0.01,0.01],
        "sec_contact_sym_mig":[0.01,0.01,0.01,0.01,0.01],
        "sec_contact_asym_mig":[0.01,0.01,0.01,0.01,0.01,0.01]
        }

    # Set priors that are constant regardless of model
    pts_start = sum(ns)
    pts = [pts_start, pts_start + 10, pts_start + 20]
    reps = [10,10,5,5]
    folds = [3,2,1,1]
    maxiters = [5,20,125,200]
    func = getattr(Models_2D, model)
    p_labels = param_labels[model]
    in_params = initials[model]
    upper = uppers[model]
    lower = lowers[model]

The script then uses dadi_pipeline to fit the SFS to the model, outputing the maximum likelihood results to a summary file (stored in `03.output/taxa_pair/results_summary/*_summarybig.txt`).

I used a bash script ([batch_demo_model_run.sh](02.scripts/batch_demo_model_run.sh)) to loop over both taxa pairs, folding and not folding and all models, with three runs for each combination. This submitted SLURM jobs of demo_model_run.py for all three runs of all combinations found in [00.slurmscripts](00.slurmscripts/).

Once all jobs were completed, each `summary.txt` file had three replicate maximum likelihood results containing, amongst others, the model likelihood, theta, and the parameter estimates. I manually checked these values for convergence before proceeding with the results. 

#### Model Selection

I used the likelihood ratio test (LRT) to find the best model. I used the script [GIM_LRT.py](02.scripts/GIM_LRT.py), and called it with [batch_lrt](02.scripts/batch_lrt.sh), which loops both population pairs over all models. The submitted slurm scripts can be found in [00.slurmscripts](00.slurmscripts/). 

#### Parameter Uncertainty Estimation

After selecting the best model using the LRT, I calculated the uncertainties for the estimated parameters of this model using the sfs bootstraps created in [the SFS section](../05.SFS/README.md). 

#### Plotting 

I plotted both the likelihoods of each model for both population pairs using the R script [plot_likelihoods.R](04.plot/plot_likelihoods.R) and the model of both hybrid zones with all parameters to scale using this script. I used functions from [Make_Plots.py](04.plot/Make_Plots.py) created by Portik et al. (2017) called with [plot_sfs.py](04.plot/plot_sfs.py) and [plot_2dsfs_compare.py](04.plot/plot_2dsfs_compare.py) to plot SFS without and with residuals, respectively.

## REFERENCES

Nolen, Z. J., Yildirim, B., Irisarri, I., Liu, S., Groot Crego, C., Amby, D. B., ... & Pereira, R. J. 2020. "Historical isolation facilitates species radiation by sexual selection: Insights from Chorthippus grasshoppers." *Molecular Ecology*, 29 (24), 4985-5002. doi:[10.1111/mec.15695](https://doi.org/10.1111/mec.15695).

Portik, Daniel M., Adam D. Leaché, Danielle Rivera, Michael F. Barej, Marius Burger, Mareike Hirschfeld, Mark-Oliver Rödel, David C. Blackburn, and Matthew K. Fujita. 2017. “Evaluating Mechanisms of Diversification in a Guineo-Congolian Tropical Forest Frog Using Demographic Model Selection.” *Molecular Ecology* 26 (19): 5245–63. doi:[10.1111/mec.14266](https://doi.org/10.1111/mec.14266).