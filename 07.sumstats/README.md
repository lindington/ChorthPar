## Summary Statistics

In this section, I calculated different summary statistics. These include:

- theta (Watterson's)
- Tajima's D
- pi
- FST
- dXY

## FST

#### making SAF files
I made saf files for each population in both hybrid zones(pyr: ERY, PAR; alp: GOM, TAR) using bamlists found in the [input folder](..inputs/bamlists/). I used angsd with the usual options (/../README.md#ANGSDOPTIONS) and the following changes:



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

## Theta (Watterson's), Tajima's D, and pi

To calculate these summary statistics, I first made saf files for every population. I used the same options as in the [saf production for the FST files](/05.SFS/01.SAF/02.scripts/saf_all.sh). Then, I made 1D-SFS for each population using realSFS. 

```
for pop in POR CSY ERY PHZ PAR TAR AHZ GOM DOB SLO ; do 
        realSFS -P 24 ../../01.saf/03.output/saf_${pop}.saf.idx > ../03.output/SFS_${pop}.sfs 

done
```

With the saf files and the 1D-sfs files as input, I used realSFS to create the per-site .theta files for each population like this: 

```
for pop in POR CSY ERY PHZ PAR TAR AHZ GOM DOB SLO ; do 
        realSFS saf2theta ../../../05.SFS/01.saf/03.output/saf_${pop}.saf.idx -sfs ../../../05.SFS/02.sfs/03.output/SFS_${pop}.sfs -outname ../03.output/site_theta_${pop} 
done
``` 

Based on the per site thetas, I calculated the per gene values of watterson's theta, tajima's D, and pi for each population using the R script [gene_thetas.R](02.theta/02.scripts/gene_thetas.R). 

#### Plotting

I plotted the distributions of genes for the different statistics for each population using the R script [plot_gene_thetas.R]().


##References
Shen L, Sinai ISoMaM (2020). GeneOverlap: Test and visualize gene overlaps. R package version 1.26.0, http://shenlab-sinai.github.io/shenlab-sinai/.