# As all population pair models converged on symmetric migration, we evaluated parameter values under this model.

# We calculated uncertainty using the Godambe Information Matrix method implemented in dadi. This outputs parameter uncertainties for all parameters including theta. From these parameters, real values can be calculated and real uncertainties can be calculated by propogating uncertainty from the parameter uncertainties.

import sys
import os
import csv
import dadi
import Models_2D
import dadi.Godambe
import math

#Define taxa pairs, demographic model, and mutation rate
taxa = ['cpery_cppar','ppgom_pptar']

func_symmig = Models_2D.sym_mig
func_ex_symmig = dadi.Numerics.make_extrap_log_func(func_symmig)

mu = 1
#mu = (2.8*10**-9)

#Build file to output parameter values
param_file = open('../03.output/pop_pairs_params.txt', 'w')
param_file.write('sfs_type\ttaxa\tnref\tn1\tn2\tm\ttsplit\tnref_sd\tn1_sd\tn2_sd\tm_sd\ttsplit_sd\n')

#Loop process over all pairs
for t in taxa:
    #Read in SFS 
    fs = dadi.Spectrum.from_file('../01.input/2dsfs_%s_fold0_genesumbig.sfs' % (t))
        
    #Get sample size
    ns = fs.sample_sizes
    
    #Fold SFS
    fs = fs.fold()
    
    #Set grid points from sample size
    pts = [sum(ns),sum(ns)+10,sum(ns)+20]
    
    #Load in bootstraps
    all_boot = [dadi.Spectrum.from_file('../01.input/big%s/boot%s.sfs' % (t,ii)) for ii in range(1,101)]
    all_boot = [b.fold() for b in all_boot]
    
    #Read in optimized parameters
    with open('../03.output/%s/bigresults_summary/%s_unfold_sym_mig_results_summarybig.txt' % (t,t)) as f:
        reader = csv.reader(f, delimiter = '\t')
        sym_mig = list(reader)
    sym_mig = sym_mig[1:4]
    sym_mig.sort(key = lambda x: x[4])
    sym_mig = sym_mig[0]
    sym_mig = map(sym_mig.__getitem__, [6,7,8,9,5])
    popt = [float(i) for i in sym_mig]
    
    print('Calculating parameter values and uncertainties for %s\n' % (t))
    
    print('Best fit model parameters (n1,n2,m,t) under symmetric migration model + theta: %s\n' % (popt))
    
    uncerts = dadi.Godambe.GIM_uncert(func_ex_symmig, pts, all_boot, popt[0:4], fs, multinom=True, return_GIM=True)
    
    print('Estimated parameter standard deviations from GIM: %s\n' % (uncerts[0]))
    print(uncerts)  
    # Get effective sequencing length
    with open('../01.input/corr/2dsfs_%s_fold0_genesumbig.sfs' % (t)) as f:
            reader = csv.reader(f, delimiter = ' ')
            plain_sfs = list(reader)
    plain_sfs = plain_sfs[1]
    plain_sfs = [float(i) for i in plain_sfs]
    L = sum(plain_sfs)
    print('Effective sequencing length: {0}\n'.format(L))
    
    # Calculate real params
    Nref = popt[4]/(4*mu*L)
    N1 = Nref * popt[0]
    N2 = Nref * popt[1]
    M = popt[2]/(2*Nref)
    Tsplit = (popt[3]*popt[4])/(2*mu*L)
    
    preal = [Nref,N1,N2,M,Tsplit]
    
    print('Real parameter values (Nref, N1, N2, m, Tsplit): {0}\n'.format(preal))
    
    #Extrapolate uncertainty for each value
       
    import numpy.linalg
    covarmatrix = numpy.linalg.inv(uncerts[1])
    
    #dtheta = popt[3]/(2*L*mu)
    #dt = popt[4]/(2*L*mu)
    
    #firstmat = numpy.dot([[dtheta,dt,dt]],[[covarmatrix[5][5],covarmatrix[5][3],covarmatrix[5][4]],[covarmatrix[5][3],covarmatrix[3][3],covarmatrix[3][4]],[covarmatrix[5][4],covarmatrix[4][3],covarmatrix[4][4]]])
    #print firstmat
    
    #secondmat = numpy.dot(firstmat,numpy.matrix.transpose(numpy.array([dtheta,dt,dt])))
    #print secondmat
    
    Nref_sd = uncerts[0][4] * (1/(4*mu*L))
    N1_sd = N1*(math.sqrt((uncerts[0][4]/popt[4]) ** 2 + (uncerts[0][0]/popt[0]) ** 2 + (2*(covarmatrix[0][4]/(popt[4]*popt[0])))))
    N2_sd = N2*(math.sqrt((uncerts[0][4]/popt[4]) ** 2 + (uncerts[0][1]/popt[1]) ** 2 + (2*(covarmatrix[1][4]/(popt[4]*popt[1])))))
    M_sd = M*(math.sqrt((uncerts[0][4]/popt[4]) ** 2 + (uncerts[0][2]/popt[2]) ** 2 - (2*(covarmatrix[2][4]/(popt[4]*popt[2])))))
    Tsplit_sd = Tsplit*(math.sqrt((uncerts[0][4]/popt[4]) ** 2 + (uncerts[0][3]/popt[3]) ** 2 + (2*(covarmatrix[3][4]/(popt[4]*popt[3])))))
        
    #new_sd = math.sqrt(secondmat)
    
    print(Nref_sd,N1_sd,N2_sd,M_sd,Tsplit_sd)
    
    param_file.write('gl\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' % (t,Nref,N1,N2,M,Tsplit,Nref_sd,N1_sd,N2_sd,M_sd,Tsplit_sd))

param_file.close()
