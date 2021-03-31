## This script is to run the likelihood ratio test with Godambe adjustment for a specified taxa pair input as an argument.
## To run this for multiple taxa pairs, simply send in all pairs as arguments in a bash loop, running one pair per loop iteration. 

import sys
import os
import csv
import dadi
import Models_2D
import dadi.Godambe

#get taxa pair as system argument
t = sys.argv[1]
m = sys.argv[2]

#import models
func_nomig = Models_2D.no_mig
func_ex_nomig = dadi.Numerics.make_extrap_log_func(func_nomig)

func_symmig = Models_2D.sym_mig
func_ex_symmig = dadi.Numerics.make_extrap_log_func(func_symmig)

func_asymmig = Models_2D.asym_mig
func_ex_asymmig = dadi.Numerics.make_extrap_log_func(func_asymmig)

func_scsymmig = Models_2D.sec_contact_sym_mig
func_ex_scsymmig = dadi.Numerics.make_extrap_log_func(func_scsymmig)

func_scasymmig = Models_2D.sec_contact_asym_mig
func_ex_scasymmig = dadi.Numerics.make_extrap_log_func(func_scasymmig)

#for t in taxa:
print(t)
print(m)

#import data SFS
fs = dadi.Spectrum.from_file('/data/home/wolfproj/wolfproj-10/02.master/01.input/corr/2dsfs_%s_fold0_genesumbig.sfs' % (t))

#fold SFS and get sample sizes
ns = fs.sample_sizes

#print SFS

print 'Printing Site Freuquency Spectrum'
print fs

#set grid points
pts = [sum(ns),sum(ns)+10,sum(ns)+20]

#import bootstraps
all_boot = [dadi.Spectrum.from_file('/data/home/wolfproj/wolfproj-10/02.master/01.input/corr/big%s/boot%s.sfs' % (t,ii)) for ii in range(1,99)]
all_boot = [b.fold() for b in all_boot]

#read in optimized parameter values for no mig
with open('/data/home/wolfproj/wolfproj-10/02.master/04.corr/%s/bigresults_summary/%s_unfold_no_mig_results_summarybig.txt' % (t,t)) as f:
    reader = csv.reader(f, delimiter = '\t')
    no_mig = list(reader)
print no_mig
no_mig = no_mig[1:4]
no_mig.sort(key = lambda x: x[4])
no_mig = no_mig[0][6:9]
no_mig = [float(i) for i in no_mig]

#read in optimized parameter values for sym mig
with open('/data/home/wolfproj/wolfproj-10/02.master/04.corr/%s/bigresults_summary/%s_unfold_sym_mig_results_summarybig.txt' % (t,t)) as f:
    reader = csv.reader(f, delimiter = '\t')
    sym_mig = list(reader)
sym_mig = sym_mig[1:4]
sym_mig.sort(key = lambda x: x[4])
sym_mig = sym_mig[0][6:10]
sym_mig = [float(i) for i in sym_mig]

#read in optimized param values for sec contact
with open('/data/home/wolfproj/wolfproj-10/02.master/04.corr/%s/bigresults_summary/%s_unfold_asym_mig_results_summarybig.txt' % (t,t)) as f:
    reader = csv.reader(f, delimiter = '\t')
    asym_mig = list(reader)
asym_mig = asym_mig[1:4]
asym_mig.sort(key = lambda x: x[4])
asym_mig = asym_mig[0][6:11]
asym_mig = [float(i) for i in asym_mig]

#read in optimized param values for sec contact
with open('/data/home/wolfproj/wolfproj-10/02.master/04.corr/%s/bigresults_summary/%s_unfold_sec_contact_sym_mig_results_summarybig.txt' % (t,t)) as f:
    reader = csv.reader(f, delimiter = '\t')
    sec_contact_sym_mig = list(reader)
sec_contact_sym_mig = sec_contact_sym_mig[1:4]
sec_contact_sym_mig.sort(key = lambda x: x[4])
sec_contact_sym_mig = sec_contact_sym_mig[0][6:11]
sec_contact_sym_mig = [float(i) for i in sec_contact_sym_mig]

#read in optimized param values for sec contact asymmetric migration
with open('/data/home/wolfproj/wolfproj-10/02.master/04.corr/%s/bigresults_summary/%s_unfold_sec_contact_asym_mig_results_summarybig.txt' % (t,t)) as f:
    reader = csv.reader(f, delimiter = '\t')
    sec_contact_asym_mig = list(reader)
sec_contact_asym_mig = sec_contact_asym_mig[1:4]
sec_contact_asym_mig.sort(key = lambda x: x[4])
sec_contact_asym_mig = sec_contact_asym_mig[0][6:12]
sec_contact_asym_mig = [float(i) for i in sec_contact_asym_mig]

#evaluate models with optimized parameters
ll_nomig = dadi.Inference.ll_multinom(func_ex_nomig(list(no_mig),ns,pts),fs)
ll_symmig = dadi.Inference.ll_multinom(func_ex_symmig(list(sym_mig),ns,pts),fs)
ll_asymmig = dadi.Inference.ll_multinom(func_ex_asymmig(list(asym_mig),ns,pts),fs)
ll_scsymmig = dadi.Inference.ll_multinom(func_ex_scsymmig(list(sec_contact_sym_mig),ns,pts),fs)
ll_scasymmig = dadi.Inference.ll_multinom(func_ex_scasymmig(list(sec_contact_asym_mig),ns,pts),fs)

#print results
if m == 'sym_mig':

    lrt_file = open('../04.corr/lrt_sym_mig.tsv', 'a+')
    #lrt_file.write('pair\tll_nomig\tll_symmig\tpvalGIM\n')

    print('no mig vs. sym mig')

    print('likelihood of no mig: {}'.format(ll_nomig))
    print('likelihood of sym mig: {}'.format(ll_symmig))

    p_lrt_sym = list(no_mig)
    p_lrt_sym.insert(2,0)

    #nested indeces [2] find, pval_adj find weights?

    adj_sym = dadi.Godambe.LRT_adjust(func_ex_symmig, pts, all_boot, p_lrt_sym, fs, nested_indices=[2], multinom=True)
    D_sym = 2*(ll_symmig - ll_nomig)
    D_adj_sym = D_sym*adj_sym
    pval_adj_sym = dadi.Godambe.sum_chi2_ppf(D_adj_sym, weights=(0.5,0.5))

    print('p-value for rejecting no_mig with sym_mig (GIM adjust): {0:.4f}\n'.format(pval_adj_sym))
    lrt_file.write('%s\t%s\t%s\t%s\n' % (t,ll_nomig,ll_symmig,pval_adj_sym))
    lrt_file.close

elif m == 'asym_mig':

    lrt_file = open('../04.corr/lrt_asym_mig.tsv', 'a+')
    #lrt_file.write('pair\tll_symmig\tll_scsymmig\tpvalGIM\n')

    print('sym mig vs. asym mig')

    print('likelihood of symmetric migration model: {}'.format(ll_symmig))
    print('likelihood of asymmetric migration model: {}'.format(ll_asymmig))

    p_lrt_asym = list(sym_mig)
    p_lrt_asym.insert(3,0)

    adj_asym = dadi.Godambe.LRT_adjust(func_ex_asymmig, pts, all_boot, p_lrt_asym, fs, nested_indices=[3], multinom=True)
    D_asym = 2*(ll_asymmig - ll_symmig)
    D_adj_asym = D_asym*adj_asym
    pval_adj_asym = dadi.Godambe.sum_chi2_ppf(D_adj_asym, weights=(0.5,0.5))

    print('p-value for rejecting sym_mig with asym_mig (GIM adjust): {0:.4f}\n'.format(pval_adj_asym))
    lrt_file.write('%s\t%s\t%s\t%s\n' % (t,ll_symmig,ll_asymmig,pval_adj_asym))
    lrt_file.close

elif m == 'sec_contact_sym_mig':

    lrt_file = open('../04.corr/lrt_sc_sym_mig.tsv', 'a+')
    #lrt_file.write('pair\tll_symmig\tll_scsymmig\tpvalGIM\n')

    print('sym mig vs. sc sym mig')

    print('likelihood of symmetric migration model: {}'.format(ll_symmig))
    print('likelihood of secondary contact model: {}'.format(ll_scsymmig))

    p_lrt_sc = list(sym_mig)
    p_lrt_sc.insert(3,0)

    adj_sc = dadi.Godambe.LRT_adjust(func_ex_scsymmig, pts, all_boot, p_lrt_sc, fs, nested_indices=[3], multinom=True)
    D_sc = 2*(ll_scsymmig - ll_symmig)
    D_adj_sc = D_sc*adj_sc
    pval_adj_sc = dadi.Godambe.sum_chi2_ppf(D_adj_sc, weights=(0.5,0.5))

    print('p-value for rejecting sym_mig with sec_contact_sym_mig (GIM adjust): {0:.4f}\n'.format(pval_adj_sc))
    lrt_file.write('%s\t%s\t%s\t%s\n' % (t,ll_symmig,ll_scsymmig,pval_adj_sc))
    lrt_file.close

elif m == 'sec_contact_asym_mig':

    lrt_file = open('../04.corr/lrt_sca_sym_mig.tsv', 'a+')
    #lrt_file.write('pair\tll_symmig\tll_scsymmig\tpvalGIM\n')

    print('sc sym mig vs. sc asym mig')

    print('likelihood of sec contact symmig model: {}'.format(ll_scsymmig))
    print('likelihood of sec contact asymmig model: {}'.format(ll_scasymmig))

    p_lrt_sca = list(sec_contact_sym_mig)
    p_lrt_sca.insert(4,0)

    adj_sca = dadi.Godambe.LRT_adjust(func_ex_scasymmig, pts, all_boot, p_lrt_sca, fs, nested_indices=[4], multinom=True)
    D_sca = 2*(ll_scasymmig - ll_scsymmig)
    D_adj_sca = D_sca*adj_sca
    pval_adj_sca = dadi.Godambe.sum_chi2_ppf(D_adj_sca, weights=(0.5,0.5))

    print('p-value for rejecting sec_contact_sym_mig with sec_contact_asym_mig (GIM adjust): {0:.4f}\n'.format(pval_adj_sca))
    lrt_file.write('%s\t%s\t%s\t%s\n' % (t,ll_scsymmig,ll_scasymmig,pval_adj_sca))
    lrt_file.close

