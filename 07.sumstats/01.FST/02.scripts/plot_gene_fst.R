install.packages("data.table")
library(data.table)
install.packages("ggplot2")
library(ggplot2)
install.packages("plyr")
library(plyr)
install.packages("tidyverse")
library(tidyverse)

#This script is used to produce pairwise Fst distributions for population comparisons of Chorthippus species.
setwd("C:/Users/Jag/Documents/GitHub/ChorthPar/07.FST/03.output/")
#Read in global Fst estimates for all comparisons.
glob_fst <- fread("glob_weighted_fst.txt", header = FALSE)
View(glob_fst)
colnames(glob_fst) <- c("HZs", "fst")

#Read in population level pairwise Fst
pyr_fst <- fread("../03.output/genefst_pyr.csv", header = FALSE)
length(pyr_fst$V2)
#12431 genes
alp_fst <- fread("../03.output/genefst_alp.csv", header = FALSE)
length(alp_fst$V2)
#11567 genes
pyr_allsites_fst <- fread("../03.output/genefst_pyr_allsites.csv", header = FALSE)

#put all the genes in the same matrix
fst_genes <- cbind(pyr_fst$V5,alp_fst$V5)
View(fst_genes)
colnames(fst_genes) <- c("pyr","alp")

a <- as.data.frame(fst_genes)
as <- stack(a)
#plot the distribution of genes by fst values
ggplot(data=as, aes(x=values)) + geom_density(aes(group=ind, colour=ind))

#find genes that are in both pyr and alps:
only_pyr <- pyr_fst$V2[!(pyr_fst$V2 %in% alp_fst$V2)]
#928 genes present in pyr but not in alp

only_alp <- alp_fst$V2[!(alp_fst$V2 %in% pyr_fst$V2)]
#64 genes present in alp but not in pyr


alpandpyr <- alp_fst$V2[(alp_fst$V2 %in% pyr_fst$V2)]
#[1] 11503


pyrandalp <- pyr_fst$V2[(pyr_fst$V2 %in% alp_fst$V2)]
#[1] 11503

#filter hybridzones by genes found in both

pyr_fst_filtered <- pyr_fst %>%
  filter(V2 %in% alpandpyr)
length(pyr_fst_filtered$V2)
#[1] 11503

alp_fst_filtered <- alp_fst %>%
  filter(V2 %in% alpandpyr)
View(alp_fst_filtered)
length(alp_fst_filtered$V2)
#[1] 11503

#make sure the genes are in the same order
sum(alp_fst_filtered$V2==pyr_fst_filtered$V2)
#[1] 11503

#include the positions in the matrix
fst_genes_filteredplot <- cbind(pyr_fst_filtered$V5, alp_fst_filtered$V5)
View(fst_genes_filteredplot)


b <- as.data.frame(fst_genes_filteredplot)
bs <- stack(b)
#plot the distribution of genes in both hzs by fst values
ggplot(data=bs, aes(x=values)) + geom_density(aes(group=ind, colour=ind))




# Hartl & Clark (1997)
#<0.05 = little gen. diff
# 0.05-0.15 = moderate gen. diff.
# 0.15-0.25 = great gen. diff.
#>0.25 = very great gen. diff.

fst_genes_filtered <- cbind(pyr_fst_filtered$V2, pyr_fst_filtered$V5, alp_fst_filtered$V5)
colnames(fst_genes_filtered) <- c("locus","pyr","alp")

# wilcox

pyr_genes <- as.vector(fst_genes_filtered[,2])
alp_genes <- as.vector(fst_genes_filtered[,3])

as.numeric(pyr_genes)
wilcox.test(as.numeric(pyr_genes),as.numeric(alp_genes))


#Wilcoxon rank sum test with continuity correction#
#
#data:  as.numeric(pyr_genes) and as.numeric(alp_genes)
#W = 90299170, p-value < 2.2e-16
#alternative hypothesis: true location shift is not equal to 0


#soll in both: 5
fst_genes_little <- fst_genes_filtered %>%
  as.data.frame(fst_genes_filtered) %>%
  filter(pyr<0.05 & alp<0.05) 
length(fst_genes_little$locus)

#smoll in pyr: 47
fst_genes_pyr_little <- fst_genes_filtered %>%
  as.data.frame(fst_genes_filtered) %>%
  filter(pyr<0.05)
view(fst_genes_pyr_little)
length(fst_genes_pyr_little$locus)

#smoll in alp: 169
fst_genes_alp_little <- fst_genes_filtered %>%
  as.data.frame(fst_genes_filtered) %>%
  filter(alp<0.05)
length(fst_genes_alp_little$locus)

#lorge in both: 4304
fst_genes_vgreat <- fst_genes_filtered %>%
  as.data.frame(fst_genes_filtered) %>%
  filter(pyr>0.25 & alp>0.25)
length(fst_genes_vgreat$locus)
#lorge in pyr: 8455
fst_genes_pyr_vgreat <- fst_genes_filtered %>%
  as.data.frame(fst_genes_filtered) %>%
  filter(pyr>0.25)
length(fst_genes_pyr_vgreat$locus)
#lorge in alp: 5304
fst_genes_alp_vgreat <- fst_genes_filtered %>%
  as.data.frame(fst_genes_filtered) %>%
  filter(alp>0.25)
length(fst_genes_alp_vgreat$locus)


#xlorge in both: 1
fst_genes_xgreat <- fst_genes_filtered %>%
  as.data.frame(fst_genes_filtered) %>%
  filter(pyr>0.95 & alp>0.95)
length(fst_genes_xgreat$locus)
view(fst_genes_xgreat)
#xlorge in pyr: 14
fst_genes_pyr_xgreat <- fst_genes_filtered %>%
  as.data.frame(fst_genes_filtered) %>%
  filter(pyr>0.95)
length(fst_genes_pyr_xgreat$locus)
#xlorge in alp: 5
fst_genes_alp_xgreat <- fst_genes_filtered %>%
  as.data.frame(fst_genes_filtered) %>%
  filter(alp>0.95)
length(fst_genes_alp_xgreat$locus)

