import sys
import os
from datetime import datetime
import time
import matplotlib
matplotlib.use('agg')
import numpy
import dadi
import pylab
import Optimize_Functions
import Models_2D
from pylab import show, title, figure


#In this script, a single demographic model will be tested for one pair of taxa. This performs one replicate of a full optimization run. It will add the optimized parameter and maximum likelihood to compiled output file for this taxa pair and model.

#argument order: taxa_pair demo_model run_number fold/unfold sfs_type

#taxa_pair - The two populations to be analyzed, in the format of their sfs file name
#demo_model - The demographic model to fit the data to, leave out the 'Models_2D.'
#run_number - Number to append to the output names to differentiate parallel runs.
#fold/unfold - Whether the SFS is folded or not. Use 'fold' or 'unfold'
#sfs_type - Whether to use the spectra produced by the full genotype likelihood data, or use the first bootstrap which is sampled at one site per gene. Can only take values 'gl' or 'snp'.

taxa = sys.argv[1]
model = sys.argv[2]
run_num = int(sys.argv[3])
is_folded = sys.argv[4]
t1 = taxa[:(len(taxa)/2)]
t2 = taxa[-(len(taxa)/2):]

#Set output directory and make it if it doesn't exist.

if not run_num == 1:
	time.sleep(5)

out_dir = "../04.corr/%s" % (taxa)

if not os.path.exists(out_dir):
    os.makedirs(out_dir)

if not os.path.exists("%s/bigresults_summary" % (out_dir)):
    os.makedirs("%s/bigresults_summary" % (out_dir))

#Set temp log file directory and make it if it doesn't exist.
temp_dir = "temp/%s" % (out_dir)
	
if not os.path.exists(temp_dir):
	os.makedirs(temp_dir)

#Import sfs.
print "\n\nImporting frequency spectra..."

fs_gl = dadi.Spectrum.from_file("../01.input/corr/2dsfs_%s_fold0_genesumbig.sfs" % (taxa))

ns = fs_gl.sample_sizes

fs = fs_gl

#Show SFS to double check
print "Site Freq Spectrum:"

print fs

#Fold if required
if is_folded == "fold":
	print "\n\nFolding frequency spectra..."
	fs = fs.fold()
elif is_folded == "unfold":
	print "\n\nContinuing with unfolded spectra..."
else:
	print "\n\nSyntax incorrect for folding argument, please use 'fold' or 'unfold'"

#Set priors

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

#Set priors that are constant regardless of model
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

#Create results_summary.txt file if this is the first run.
if not os.path.isfile("%s/bigresults_summary/%s_%s_%s_results_summarybig.txt" % (out_dir,taxa,is_folded,model)):
	summary_file = open("%s/bigresults_summary/%s_%s_%s_results_summarybig.txt" % (out_dir,taxa,is_folded,model), "a+")
	param_list = '\t'.join(map(str,param_labels[model].replace(" ","").split(",")))
	summary_file.write("run_num\ttaxa\tmodel\tlog-likelihood\taic\ttheta\t%s\n" % (param_list))
	summary_file.close()	

#Show grid points in case they need to be checked in the standard output file
print "\n\nGrid points: {}".format(pts)

print "\n\nBeginning optimization run {}".format(run_num)

#Set filename prefix
prefix = "%s/%s_%s_run%s_big" % (out_dir,taxa,is_folded,run_num)

#Run optimization run with dadi_pipeline
if is_folded == "fold":
	params = Optimize_Functions.Optimize_Routine(fs, pts, prefix, model, func, 4, len(upper), fs_folded = True, param_labels = p_labels, reps = reps, folds = folds, in_params = in_params, in_upper = upper, in_lower = lower, maxiters = maxiters)
elif is_folded == "unfold":
	params = Optimize_Functions.Optimize_Routine(fs, pts, prefix, model, func, 4, len(upper), fs_folded = False, param_labels = p_labels, reps = reps, folds = folds, in_params = in_params, in_upper = upper, in_lower = lower, maxiters = maxiters)
else:
	print "\n\nSyntax incorrect for folding argument, please use 'fold' or 'unfold'"

#Print notable results and where they are saved to.
print "\n\nHighest likelihood of run: {}".format(params[0])
print "\nOptimized parameter values: {}".format(params[1])
print "\nAdding run results to analysis summary file: %s/bigresults_summary/%s_%s_%s_results_summarybig.txt" % (out_dir,taxa,is_folded,model)

#Once again make sure summary file is there.
if not os.path.isfile("%s/bigresults_summary/%s_%s_%s_results_summarybig.txt" % (out_dir,taxa,is_folded,model)):
	summary_file = open("%s/bigresults_summary/%s_%s_%s_results_summarybig.txt" % (out_dir,taxa,is_folded,model), "a+")
	param_list = '\t'.join(map(str,param_labels[model].replace(" ","").split(",")))
	summary_file.write("run_num\ttaxa\tmodel\tlog-likelihood\taic\ttheta\t%s\n" % (param_list))
	summary_file.close()

#Write results to summary file.
summary_file = open("%s/bigresults_summary/%s_%s_%s_results_summarybig.txt" % (out_dir,taxa,is_folded,model),'a')
tab_params = '\t'.join(map(str,params[1]))
summary_file.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\n" % (run_num,taxa,model,params[0],params[2],params[3],tab_params))
summary_file.close()


print "\nRun complete..."
