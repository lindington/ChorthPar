'''
Usage: python Make_Plots.py

This is meant to be a general use script to fit a demographic model and create
plots of the data and model sfs. The user will have to edit information about
their allele frequency spectrum and provide a custom model. The instructions
are annotated below, with a #************** marking sections that will have to
be edited.

This script must be in the same working directory as Plotting_Functions.py, which
contains all the functions necessary for generating simulations and optimizing the model.

General workflow:
 The user provides a model and the previously optimized parameters for their empirical 
 data. The model is fit using these parameters, and the resulting model SFS is used to
 create the plot comparing the data to the model. 
 
Outputs:
 A summary file of the model fit will be created, along with a pdf of the plot.
 
Notes/Caveats:
 Sometimes you may see the following error when plotting 2D or 3D:
 
 "ValueError: Data has no positive values, and therefore can not be log-scaled."
 
 To deal with this, you can change the optional argument vmin_val to a value
 between 0 and 0.05 (0.05 is the default). I have used values from 0.005-0.01
 with good visual results.

Citations:
 If you use these scripts for your work, please cite the following publications.
 
 For the general optimization routine:
    Portik, D.M., Leache, A.D., Rivera, D., Blackburn, D.C., Rodel, M.-O.,
    Barej, M.F., Hirschfeld, M., Burger, M., and M.K.Fujita. 2017.
    Evaluating mechanisms of diversification in a Guineo-Congolian forest
    frog using demographic model selection. Molecular Ecology 26: 52455263.
    doi: 10.1111/mec.14266
    
-------------------------
Written for Python 2.7 and 3.7
Python modules required:
-Numpy
-Scipy
-dadi
-------------------------

Daniel Portik
daniel.portik@gmail.com
https://github.com/dportik
Updated September 2019
'''
###LH: adapted for master thesis plotting. changes are commented with LH
import sys
import os
import numpy
import dadi
import Plotting_Functions
from dadi import Numerics, PhiManip, Integration, Misc
from dadi.Spectrum_mod import Spectrum
import Models_2D
from datetime import datetime
import time
import pylab
from pylab import show, title, figure
import csv
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

taxa = sys.argv[1]
model = sys.argv[2]
t1 = taxa[:(len(taxa)/2)]
t2 = taxa[-(len(taxa)/2):]


#===========================================================================
# Import data to create joint-site frequency spectrum
#===========================================================================

#**************
#path to your input file
#snps = "/Users/portik/Documents/GitHub/dadi_pipeline/Two_Population_Pipeline/Example_Data/dadi_2pops_North_South_snps.txt"

#Create python dictionary from snps file
#dd = Misc.make_data_dict(snps)

#**************
#pop_ids is a list which should match the populations headers of your SNPs file columns
#pop_ids=["North", "South"]

#**************
#projection sizes, in ALLELES not individuals
#proj = [16, 32]

#Convert this dictionary into folded AFS object
#[polarized = False] creates folded spectrum object
#fs = Spectrum.from_data_dict(dd, pop_ids=pop_ids, projections = proj, polarized = False)

###LH: importing sfs format data, only conversion into dadi format is needed:

fs = dadi.Spectrum.from_file("../01.input/2dsfs_%s_fold0_genesumbig.sfs" % (taxa))
ns = fs.sample_sizes

#print some useful information about the sfs
print("\n\n============================================================================")
print("\nData for site frequency spectrum:\n")
print("Sample sizes: {}".format(fs.sample_sizes))
print("Sum of SFS: {}".format(numpy.around(fs.S(), 2)))
print("\n============================================================================\n")


#================================================================================
# Fit the empirical data based on prior optimization results, obtain model SFS
#================================================================================
''' 
 We will use a function from the Plotting_Functions.py script:
 	Fit_Empirical(fs, pts, outfile, model_name, func, in_params, fs_folded)

Mandatory Arguments =
 	fs:  spectrum object name
 	pts: grid size for extrapolation, list of three values
 	outfile: prefix for output naming
 	model_name: a label to help name the output files; ex. "sym_mig"
 	func: access the model function from within script
 	in_params: the previously optimized parameters to use
    fs_folded: A Boolean value indicating whether the empirical fs is folded (True) or not (False).
'''

#**************
#COPY AND PASTE YOUR MODEL HERE, do not use this one!
#you can copy/paste directly from the Models_2D.py or Models_3D.py scripts

#No Migration

#def no_mig(params, ns, pts):
#    """
#    Split into two populations, no migration.
#
#    nu1: Size of population 1 after split.
#    nu2: Size of population 2 after split.
#    T: Time in the past of split (in units of 2*Na generations)
#    """
#    nu1, nu2, T = params
#
#    xx = Numerics.default_grid(pts)
#
#    phi = PhiManip.phi_1D(xx)
#    phi = PhiManip.phi_1D_to_2D(xx, phi)
#
#    phi = Integration.two_pops(phi, xx, T, nu1, nu2, m12=0, m21=0)
#
#    fs = Spectrum.from_phi(phi, ns, (xx,xx))
#    return fs


#def sym_mig(params, ns, pts):
#    """
#    Split into two populations, with symmetric migration.
#
#    nu1: Size of population 1 after split.
#    nu2: Size of population 2 after split.
#    T: Time in the past of split (in units of 2*Na generations) 
#    m: Migration rate between populations (2*Na*m)
#    """
#    nu1, nu2, m, T = params

#    xx = Numerics.default_grid(pts)
#    phi = PhiManip.phi_1D(xx)
#    phi = PhiManip.phi_1D_to_2D(xx, phi)
#    phi = Integration.two_pops(phi, xx, T, nu1, nu2, m12=m, m21=m)
#    fs = Spectrum.from_phi(phi, ns, (xx,xx))
#    return fs

#Symmetric discontinuous migration following split (period of no migration followed by period of symmetric migration)

def sec_contact_sym_mig(params, ns, pts):
    """
    Split with no gene flow, followed by period of symmetrical gene flow.

    nu1: Size of population 1 after split.
    nu2: Size of population 2 after split.
    m: Migration between pop 2 and pop 1.
    T1: The scaled time between the split and the secondary contact (in units of 2*Na generations).
    T2: The scaled time between the secondary contact and present.
    """
    nu1, nu2, m, T1, T2 = params

    xx = Numerics.default_grid(pts)

    phi = PhiManip.phi_1D(xx)
    phi = PhiManip.phi_1D_to_2D(xx, phi)

    phi = Integration.two_pops(phi, xx, T1, nu1, nu2, m12=0, m21=0)

    phi = Integration.two_pops(phi, xx, T2, nu1, nu2, m12=m, m21=m)

    fs = Spectrum.from_phi(phi, ns, (xx,xx))
    return fs



#create a prefix based on the population names to label the output files
#ex. Pop1_Pop2
#DO NOT EDIT THIS
prefix = "%s" % (taxa)

#**************
#Make sure to define your extrapolation grid size.
pts_start = sum(ns)
pts = [pts_start, pts_start + 10, pts_start + 20]

#**************
#Provide best optimized parameter set for empirical data.
#These will come from previous analyses you have already completed.

#read in optimized parameter values for no mig
with open('/data/home/wolfproj/wolfproj-10/02.master/03.output/%s/bigresults_summary/%s_unfold_no_mig_results_summarybig.txt' % (taxa,taxa)) as f:
    reader = csv.reader(f, delimiter = '\t')
    pno_mig = list(reader)
pno_mig = pno_mig[1:4]
pno_mig.sort(key = lambda x: x[4])
pno_mig = pno_mig[0][6:9]
pno_mig = [float(i) for i in pno_mig]
#print pno_mig

#read in optimized parameter values for sym mig
with open('/data/home/wolfproj/wolfproj-10/02.master/03.output/%s/bigresults_summary/%s_unfold_sym_mig_results_summarybig.txt' % (taxa,taxa)) as f:
    reader = csv.reader(f, delimiter = '\t')
    psym_mig = list(reader)
psym_mig = psym_mig[1:4]
psym_mig.sort(key = lambda x: x[4])
psym_mig = psym_mig[0][6:10]
psym_mig = [float(i) for i in psym_mig]
#print psym_mig

#read in optimized param values for sec contact
with open('/data/home/wolfproj/wolfproj-10/02.master/03.output/%s/bigresults_summary/%s_unfold_asym_mig_results_summarybig.txt' % (taxa,taxa)) as f:
    reader = csv.reader(f, delimiter = '\t')
    pasym_mig = list(reader)
pasym_mig = pasym_mig[1:4]
pasym_mig.sort(key = lambda x: x[4])
pasym_mig = pasym_mig[0][6:11]
pasym_mig = [float(i) for i in pasym_mig]

#read in optimized param values for sec contact
with open('/data/home/wolfproj/wolfproj-10/02.master/03.output/%s/bigresults_summary/%s_unfold_sec_contact_sym_mig_results_summarybig.txt' % (taxa,taxa)) as f:
    reader = csv.reader(f, delimiter = '\t')
    psec_contact_sym_mig = list(reader)
psec_contact_sym_mig = psec_contact_sym_mig[1:4]
psec_contact_sym_mig.sort(key = lambda x: x[4])
psec_contact_sym_mig = psec_contact_sym_mig[0][6:11]
psec_contact_sym_mig = [float(i) for i in psec_contact_sym_mig]
print psec_contact_sym_mig

#read in optimized param values for sec contact asymmetric migration
with open('/data/home/wolfproj/wolfproj-10/02.master/03.output/%s/bigresults_summary/%s_unfold_sec_contact_asym_mig_results_summarybig.txt' % (taxa,taxa)) as f:
    reader = csv.reader(f, delimiter = '\t')
    sec_contact_asym_mig = list(reader)
sec_contact_asym_mig = sec_contact_asym_mig[1:4]
sec_contact_asym_mig.sort(key = lambda x: x[4])
sec_contact_asym_mig = sec_contact_asym_mig[0][6:12]
sec_contact_asym_mig = [float(i) for i in sec_contact_asym_mig]

#LH:print optimized parameters
emp_params = psec_contact_sym_mig

print emp_params


#emp_params = [0.1487,0.1352,0.2477,0.1877]

#**************
#Fit the model using these parameters and return the model SFS.
#Here, you will want to change the "sym_mig" and sym_mig arguments to match your model, but
#everything else can stay as it is. See above for argument explanations.
model_fit = Plotting_Functions.Fit_Empirical(fs, pts, prefix, sec_contact_sym_mig, "sec_contact_sym_mig", emp_params, fs_folded=False)


#================================================================================
# Plotting a 2D spectrum
#================================================================================
'''
 We will use a function from the Plotting_Functions.py script to plot:
 	Plot_2D(fs, model_fit, outfile, model_name, vmin_val=None)

Mandatory Arguments =
	fs:  spectrum object name
    model_fit:  the model spectrum object name
 	outfile: prefix for output naming
 	model_name: a label to help name the output files; ex. "sym_mig"

Optional Arguments =
     vmin_val: Minimum values plotted for sfs, default is 0.05 and to fix the common error this should
               be changed to something between 0 and 0.05.
'''
#**************
#Now we simply call the function with the correct arguments (notice many are the same from the
#empirical fit).
fig = Plotting_Functions.Plot_2D(fs, model_fit, prefix, model_name = "scsymmig")
title("SFS of %s for %s" % (model,taxa))
show(fig)
plt.savefig('SFS_%s_%s_comp' % (taxa, model))  
fig = plt.gcf()
plt.close(fig)

print "\nPlotting complete..."

#**************
#Although the above function does not produce an error, let's pretend it did and
#change the vmin value. You can see the effect on the colors in the plot. We will
#edit the "model_name" string so the output file will be called something different.  
#vmin = float(0.01)
#Plotting_Functions.Plot_2D(fs, model_fit, prefix, "%s_vmin", vmin_val = vmin % (model))


