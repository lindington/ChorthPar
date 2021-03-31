import sys
import os
import numpy
import dadi
from dadi import Numerics, PhiManip, Integration
from dadi.Spectrum_mod import Spectrum
from datetime import datetime
import matplotlib
import pylab
import matplotlib.pyplot as plt

#Symmetric continuous migration following split

def sym_mig(params, ns, pts):
    """
    Split into two populations, with symmetric migration.

    nu1: Size of population 1 after split.                                                                                                                                      nu2: Size of population 2 after split.
    T: Time in the past of split (in units of 2*Na generations)
    m: Migration rate between populations (2*Na*m)
    """
    nu1, nu2, m, T = params

    xx = Numerics.default_grid(pts)

    phi = PhiManip.phi_1D(xx)
    phi = PhiManip.phi_1D_to_2D(xx, phi)

    phi = Integration.two_pops(phi, xx, T, nu1, nu2, m12=m, m21=m)

    fs = Spectrum.from_phi(phi, ns, (xx,xx))
    return fs

#No Migration

def no_mig(params, ns, pts):
    """
    Split into two populations, no migration.

    nu1: Size of population 1 after split.
    nu2: Size of population 2 after split.
    T: Time in the past of split (in units of 2*Na generations)
    """
    nu1, nu2, T = params

    xx = Numerics.default_grid(pts)

    phi = PhiManip.phi_1D(xx)
    phi = PhiManip.phi_1D_to_2D(xx, phi)

    phi = Integration.two_pops(phi, xx, T, nu1, nu2, m12=0, m21=0)

    fs = Spectrum.from_phi(phi, ns, (xx,xx))
    return fs

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


def collect_results(fs, sim_model, params_opt, roundrep, fs_folded):
    #--------------------------------------------------------------------------------------
    # gather up a bunch of results, return a list = [roundnum_repnum, log-likelihood, AIC, chi^2 test stat, theta, parameter values, sfs_sum] 
    
    # Arguments
    # fs: spectrum object name
    # sim_model: model fit with optimized parameters
    # params_opt: list of the optimized parameters
    # fs_folded: a Boolean (True, False) for whether empirical spectrum is folded or not
    #--------------------------------------------------------------------------------------

   #calculate likelihood
    ll = dadi.Inference.ll_multinom(sim_model, fs)
    ll = numpy.around(ll, 2)
    print("\t\t\tLikelihood = {:,}".format(ll))

    #calculate AIC 
    aic = ( -2*( float(ll))) + (2*len(params_opt))
    print("\t\t\tAIC = {:,}".format(aic))

    #calculate theta
    theta = dadi.Inference.optimal_sfs_scaling(sim_model, fs)
    theta = numpy.around(theta, 2)
    print("\t\t\tTheta = {:,}".format(theta))

    #get Chi^2
    scaled_sim_model = sim_model*theta
    if fs_folded is True:
        #calculate Chi^2 statistic for folded
        folded_sim_model = scaled_sim_model.fold()
        chi2 = numpy.sum((folded_sim_model - fs)**2/folded_sim_model)
        chi2 = numpy.around(chi2, 2)
    elif fs_folded is False:
        #calculate Chi^2 statistic for unfolded
        chi2 = numpy.sum((scaled_sim_model - fs)**2/scaled_sim_model)
        chi2 = numpy.around(chi2, 2)
    print("\t\t\tChi-Squared = {:,}".format(chi2))
    
    #get sum of sfs
    sfs_sum = numpy.around(fs.S(), 2)

    #store key results in temporary sublist, append to larger results list
    temp_results = [roundrep, ll, aic, chi2, theta, params_opt, sfs_sum]

    return temp_results

def Fit_Empirical(fs, pts, outfile, model_name, func, in_params, fs_folded=True):
    #--------------------------------------------------------------------------------------
    # Mandatory Arguments =
    #(1) fs:  spectrum object name
    #(2) pts: grid size for extrapolation, list of three values
    #(3) outfile:  prefix for output naming
    #(4) model_name: a label to slap on the output files; ex. "no_mig"
    #(5) func: access the model function from within script or from a separate python model script, ex. Models_2D.no_mig
    #(6) in_params: the previously optimized parameters to use
    #(7) fs_folded: A Boolean value indicating whether the empirical fs is folded (True) or not (False). Default is True.
    #--------------------------------------------------------------------------------------
    
    print("============================================================================\n"
              "Fitting model '{}' to empirical data...\n"
              "============================================================================\n".format(model_name))
    print("Input parameters = {}\n".format(in_params))

    # We need an output file that will store empirical results
    outname = "{0}.{1}.optimized.txt".format(outfile,model_name)
    with open(outname, 'a') as fh_out:
        fh_out.write("Model\tReplicate\tlog-likelihood\ttheta\tsfs_sum\tchi-squared\n")
        
    #create an extrapolating function 
    func_exec = dadi.Numerics.make_extrap_log_func(sec_contact_sym_mig)

    #simulate the model with the optimized parameters
    sim_model = func_exec(in_params, fs.sample_sizes, pts)

    rep_results = collect_results(fs, sim_model, in_params, "1", fs_folded)
    with open(outname, 'a') as fh_out:
        fh_out.write("{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n".format(model_name, rep_results[0],
                                                                 rep_results[1], rep_results[4],
                                                                 rep_results[6], rep_results[3]))
    
    print("\n============================================================================\n"
              "Creating plots\n============================================================================\n".format(model_name))

    return sim_model

def Plot_1D(fs, model_fit, outfile, model_name):
    #Routine for plotting with 1D sfs
    print('\nPlotting {0}_{1}.pdf'.format(outfile, model_name))
    print("\nNOTE - CLOSE PLOT TO ADVANCE.")
    outname = '{0}_{1}.pdf'.format(outfile, model_name)
    fig = pylab.figure(1)
    fig.clear()
    dadi.Plotting.plot_1d_comp_multinom(model_fit, fs)
    fig.savefig(outname)
    
def Plot_2D(fs, model_fit, outfile, model_name, vmin_val=None):
    #Routine for plotting with 2D jsfs
    print('\nPlotting {0}_{1}.pdf'.format(outfile, model_name))
    print("\nNOTE - CLOSE PLOT TO ADVANCE.")
    outname = '{0}_{1}.pdf'.format(outfile, model_name)
    fig = pylab.figure(1)
    fig.clear()
    if vmin_val is None:
        dadi.Plotting.plot_2d_comp_multinom(model_fit, fs, resid_range = 3)
    else:
        dadi.Plotting.plot_2d_comp_multinom(model_fit, fs, resid_range = 3, vmin = vmin_val)
    fig.savefig(outname)
    
def Plot_3D(fs, model_fit, outfile, model_name, vmin_val=None):
    #Routine for plotting with 3D jsfs
    print('\nPlotting {0}_{1}.pdf'.format(outfile, model_name))
    print("\nNOTE - CLOSE PLOT TO ADVANCE.")
    outname = '{0}_{1}.pdf'.format(outfile, model_name)
    fig = pylab.figure(1)
    fig.clear()
    if vmin_val is None:
        dadi.Plotting.plot_3d_comp_multinom(model_fit, fs, resid_range = 3)
    else:
        dadi.Plotting.plot_3d_comp_multinom(model_fit, fs, resid_range = 3, vmin = vmin_val)
    fig.savefig(outname)
