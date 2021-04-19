install.packages("data.table")
install.packages("ggplot2")
install.packages("plyr")
install.packages("tidyverse")
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("GeneOverlap")
install.packages("overlapping")


library(data.table)
library(ggplot2)
library(plyr)
library(tidyverse)
library(GeneOverlap)
library(boot)
library(overlapping)

getwd()
setwd("C:/Users/Jag/Documents/GitHub/ChorthPar/07.sumstats")

## finding correlation between genes with high fst and genes with high dxy
#read in fst values for each pop
pyr_fst <- fread("01.FST/03.output/genefst_pyr.csv", header = FALSE)
alp_fst <- fread("01.FST/03.output/genefst_alp.csv", header = FALSE)
#read in dxy values
pyr_dxy <- fread("03.dxy/03.output/per_gene_dxy_pyr.csv", header = TRUE)
pyr_dxy <- pyr_dxy %>%
  filter(pyr_dxy$siteswithdata > 1000)
alp_dxy <- fread("03.dxy/03.output/per_gene_dxy_alp.csv", header = TRUE)
alp_dxy <- alp_dxy %>%
  filter(alp_dxy$siteswithdata > 1000)

# only keep genes that exist in both sumstats for both hz:
pyr_fstdxy <- pyr_dxy$V1[(pyr_dxy$V1 %in% pyr_fst$V2)]
alp_fstdxy <- alp_dxy$V1[(alp_dxy$V1 %in% alp_fst$V2)]

# length(pyr_fstdxy)
# [1] 12392 genes in both sumstats for both Hzs
pyr_dxy_filtered <- pyr_dxy %>%
  filter(V1 %in% pyr_fstdxy)
pyr_fst_filtered <- pyr_fst %>%
  filter(V2 %in% pyr_fstdxy)

alp_dxy_filtered <- alp_dxy %>%
  filter(V1 %in% alp_fstdxy)
alp_fst_filtered <- alp_fst %>%
  filter(V2 %in% alp_fstdxy)


pyr_genes <- cbind.data.frame(pyr_dxy_filtered$V1,pyr_dxy_filtered$dxy,pyr_fst_filtered$V5)
alp_genes <- cbind.data.frame(alp_dxy_filtered$V1,alp_dxy_filtered$dxy,alp_fst_filtered$V5)
colnames(pyr_genes) <- c("gene","dxy","fst")
colnames(alp_genes) <- c("gene","dxy","fst")

cs<-stack(pyr_genes)
reg1 <- lm(pyr_genes$dxy~pyr_genes$fst,data=pyr_genes) 
summary(reg1)
with(pyr_genes,plot(fst,dxy))
abline(reg1,col="#D10000")


ds<-stack(alp_genes)
reg2 <- lm(alp_genes$dxy~alp_genes$fst,data=alp_genes)
summary(reg2)
with(alp_genes,plot(fst,dxy))
abline(reg2,col="#489CDA")
#quick correlation test with no filters:
