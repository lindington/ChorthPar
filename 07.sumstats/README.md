## FST

#### making SAF files
I made saf files for each population in both hybrid zones(pyr: ERY, PAR; alp: GOM, TAR) using bamlists found in [input](..inputs/bamlists/). I used angsd with the usual options (/../README.md#ANGSDOPTIONS) and the following changes:



with snp-pval = 1
chr. 1 
neutral sites: yes

#### making 2dsfs files
made sfs .ml files with realSFS like this:

`realSFS [pop1].saf.idx [pop2].saf.idx > [pop1pop2].ml`

#### Global FST

I obtained the global FST estimates using the following command: 
`realSFS fst index [pop1].saf.idx [pop2].saf.idx -sfs [pop1pop2].ml -fstout [pop1pop2]`

I called the global FST estimate using
`realSFS stats [pop1pop2].fst.idx`

#### per-site FST 

I extracted the per-site FST from the global FST files using 
`realSFS fst print [pop1pop2].fst.idx > [pop1pop2].fst`

#### per-gene FST

The following command calculates the per-gene fst for each gene using the script [loopFst.pl](02.scripts/loopFst.pl).
`perl loopFst.pl grasshopperRef.positions [pop1pop2].fst > genefst_[pop1pop2]`

#### stats: Distribution, Wilcox Sum Rank, gene overlap

I used the R script [plot_gene_fst.R](02.scripts/plot_gene_fst.R) to plot the FST distribution, and calculate the Wilcox Rank Sum test.  the overlap between 5% of genes with highest FST (representation factor). I used the package [GeneOverlap]() to evaluate the significance of overlap between the genes (5%) with highest fst in the two different hybrid zones: 

    go.object <- newGeneOverlap(highest5_alp$V2,  # highest 5% genes by fst in alp
                                highest5_pyr$V2,  # highest 5% genes by fst in pyr
                                # number of shared fst genes:
                                genome.size = length(alp_fst_filtered$V1)) 

This outputs the J.. p-value etc.


##References
Shen L, Sinai ISoMaM (2020). GeneOverlap: Test and visualize gene overlaps. R package version 1.26.0, http://shenlab-sinai.github.io/shenlab-sinai/.