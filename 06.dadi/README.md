## Demographic Analysis (δaδi)
δaδi is a demographic inference tool developed by Gutenkunst et al. (2009). It uses diffusion approximation to fit an estimated SFS to your data SFS. Using an optimisation algorithm, it explores the parameters in the demographic model, allowing it to find the maximum likelihood parameter values. This maximum likelihood can be used to select the best fitting demographic model from a set of candidate models, and these parameter estimates can be used to infer demographic history.

Fitting demographic models allows multiple hypotheses to be tested. For instance, I am comparing a models with and without migration between two populations to see which is more likely. First, you choose models that are appropriate to answer your question. For this thesis, I use the four models pictured below: (1) Divergence without Gene Flow (no_mig), (2) Divergence with Symmetric Gene Flow (sym_mig), (3) Secondary Contact with Symmetric Gene Flow (anc_sym_mig), and (4) Secondary Contact with Asymmetric Gene Flow.

#### Producing SFS

I built 2D SFS for the two hybrid zone comparisons. The protocol for this can be found in the [SFS section](../05.SFS/) of this repository. Unlike [Zach][https](https://github.com/zjnolen/chorthippus_demography/tree/master/dadi#sfs-production), I only made linked SFS. These were used for all downstream analyses. To ensure I used as much data as possible for the parameter estimation, I used traditional bootstrap fits of our non-parametric bootstraps for uncertainties.

#### Model Fitting (Optimisation)

I used the dadi_pipeline developed by Portik et al. (2017) with adjustments from Nolen et al. (2020) for model fitting. Zach built a script [demo_model_run.py](/06.dadi/02.scripts/demo_model_run.py) which can be called from the command line to run one dadi_pipeline optimisation run on an SFS. Unlike Zach, I did not fold the SFS.

This optimisation run had the following pipeline parameters:




#### Model Selection

I used the likelihood ratio test (LRT) to find the best model.

#### Parameter Estimation