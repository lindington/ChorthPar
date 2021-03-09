#Gives the general structure of plotting an SFS comparison with residuals. Did not really use, this code was used to check how similar an SFS produced by ANGSD all at once for the whole genome was to an SFS produced summing gene SFS (concat, now called genesum).

from numpy import array
import scipy
import matplotlib

#I don't know what this does, but if I don't do it now there are problems and I don't like problems.

matplotlib.use('agg')

import pylab

import dadi

fs = dadi.Spectrum.from_file("../01.input/2dsfs_%s_fold0_genesumbig.sfs" % (taxa))
#fs = fs.fold()

fs_concat = dadi.Spectrum.from_file("../01.input/2dsfs_%s_fold0_genesumbig.sfs" % (taxa))
fs_concat = fs_concat.fold()

import os
plot_dir = 'plots'

if not os.path.exists(plot_dir):
    os.makedirs(plot_dir)

	
	
pylab.figure()

dadi.Plotting.plot_2d_comp_multinom(fs_concat, fs, resid_range=15)

pylab.savefig('SFS_%s_concat.png' % (taxa), dpi = 300)
