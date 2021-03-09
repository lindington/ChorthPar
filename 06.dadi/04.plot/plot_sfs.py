import sys
import os
from datetime import datetime
import time
import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
import numpy
import dadi
import pylab
import Optimize_Functions
import Models_2D
from pylab import show, title, figure


taxa = sys.argv[1]
t1 = taxa[:(len(taxa)/2)]
t2 = taxa[-(len(taxa)/2):]
print t1
print t2


#Import sfs.
print "\n\nImporting frequency spectra..."

#As SNP file
#dd = dadi.Misc.make_data_dict("../../01.convert/03.output/islands_snp" )
#fs = dadi.Spectrum.from_data_dict(dd, [t1,t2], [16,44] , polarized=True)

#As SFS file

fs_gl = dadi.Spectrum.from_file("../01.input/2dsfs_%s_fold0_genesumbig.sfs" % (taxa))
ns = fs_gl.sample_sizes
print ns
fs = fs_gl


#Show SFS to double check
print "Site Freq Spectrum:"

print fs

# Plot sfs nicely
fig = dadi.Plotting.plot_single_2d_sfs(fs, vmin=150)
title("SFS of %s" % (taxa))
show(fig)
plt.savefig('SFS_%s_pretty' % (taxa))  
fig = plt.gcf()
plt.close(fig)

print "\nPlotting complete..."
