install.packages("data.table")
library(data.table)
install.packages("ggplot2")
library(ggplot2)
install.packages("plyr")
library(plyr)
install.packages("tidyverse")
library(tidyverse)
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("GeneOverlap")
library(GeneOverlap)
library(boot)
install.packages("overlapping")
library(overlapping)

#This script is used to produce pairwise Fst distributions for population comparisons of Chorthippus species.
setwd("C:/Users/Jag/Documents/GitHub/ChorthPar/07.FST/03.output/")
#Read in global Fst estimates for all comparisons.
glob_fst <- fread("glob_weighted_fst.txt", header = FALSE)
#View(glob_fst)
colnames(glob_fst) <- c("HZs", "fst")

#Read in population level pairwise Fst
pyr_fst <- fread("../03.output/genefst_pyr.csv", header = FALSE)
#length(pyr_fst$V2)
#12431 genes -> more reads 
alp_fst <- fread("../03.output/genefst_alp.csv", header = FALSE)
#length(alp_fst$V2)
#11567 genes
pyr_allsites_fst <- fread("../03.output/genefst_pyr_allsites.csv", header = FALSE)

#put all the genes in the same matrix
fst_genes <- cbind(pyr_fst$V5,alp_fst$V5)
#View(fst_genes)
colnames(fst_genes) <- c("pyr","alp")

a <- as.data.frame(fst_genes)
as <- stack(a)

#plot the distribution of genes by fst values
ggplot(data=as, aes(x=values)) + geom_density(aes(group=ind, colour=ind))


#plot fst per gene length
#ggplot(data = pyr_fst, aes(x=V3,y=V5)) + geom_point()
#ggplot(data = alp_fst, aes(x=V3,y=V5)) + geom_point()



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
#length(pyr_fst_filtered$V2)
#[1] 11503

alp_fst_filtered <- alp_fst %>%
  filter(V2 %in% alpandpyr)
#View(alp_fst_filtered)
#length(alp_fst_filtered$V2)
#[1] 11503

#make sure the genes are in the same order
#sum(alp_fst_filtered$V2==pyr_fst_filtered$V2)
#[1] 11503

#include the positions in the matrix
fst_genes_filteredplot <- cbind(pyr_fst_filtered$V5, alp_fst_filtered$V5)
#View(fst_genes_filteredplot)


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

# wilcoxon

pyr_genes <- as.vector(fst_genes_filtered[,2])
alp_genes <- as.vector(fst_genes_filtered[,3])

#as.numeric(pyr_genes)

wilcox.test(as.numeric(pyr_genes),as.numeric(alp_genes),paired = TRUE)

#Wilcoxon signed rank test with continuity correction
#
#data:  as.numeric(pyr_genes) and as.numeric(alp_genes)
#V = 51083963, p-value < 2.2e-16
#alternative hypothesis: true location shift is not equal to 0

wilcox.test(as.numeric(pyr_genes),as.numeric(alp_genes),paired = FALSE)
#Wilcoxon rank sum test with continuity correction#
#
#data:  as.numeric(pyr_genes) and as.numeric(alp_genes)
#W = 90299170, p-value < 2.2e-16
#alternative hypothesis: true location shift is not equal to 0



#find highest 5% of genes
fst_highest5_pyr <- pyr_fst %>%
  as.data.frame(pyr_fst) %>%
  slice_max(pyr_fst$V5,prop=0.05)
# length: 621

fst_highest5_alp <- alp_fst %>%
  as.data.frame(alp_fst) %>%
  slice_max(alp_fst$V5,prop=0.05)
#view(fst_highest5_alp)
# length: 578

fst_highest5inboth_pyr <- fst_highest5_pyr %>%
  filter(fst_highest5_pyr$V2 %in% fst_highest5_alp$V2)
#view(fst_highest5inboth_pyr)
#length(fst_highest5inboth_pyr$V2)
#[1] 118

fst_highest5inboth_alp <- fst_highest5_alp %>%
  filter(fst_highest5_alp$V2 %in% fst_highest5_pyr$V2)
#view(fst_highest5inboth_alp)
#length(fst_highest5inboth_alp$V2)
#[1] 118

#find overlap between top5 datasets:
#representation factor
r_factor=(length(fst_highest5inboth_alp$V1)*length(alp_fst_filtered$V1))/(length(fst_highest5_alp$V1)*length(fst_highest5_pyr$V1))
#view(r_factor)

fst_highest1_alp <- fst_highest5_alp %>%
  slice_max(fst_highest5_alp, prop = 0.2)
fst_highest1_pyr <- fst_highest5_pyr %>%
  slice_max(fst_highest5_pyr, prop=0.2)

length(fst_highest1_alp$V1)
length(fst_highest1_pyr$V1)

fst_highest1inboth_pyr <- fst_highest1_pyr %>%
  filter(fst_highest1_pyr$V2 %in% fst_highest1_alp$V2)
#length(fst_highest1inboth_pyr$V2)
#[1] 27
fst_highest1inboth_alp <- fst_highest1_alp %>%
  filter(fst_highest1_alp$V2 %in% fst_highest1_pyr$V2)
#length(fst_highest1inboth_alp$V1)
#[1] 27


go.obj <- newGeneOverlap(fst_highest5_alp$V2, fst_highest5_pyr$V2, genome.size = length(alp_fst_filtered$V1))


go.obj_test <- testGeneOverlap(go.obj)
print(go.obj_test)
#Detailed information about this GeneOverlap object:
#  listA size=578, e.g. chr1:20604575-20605685 chr1:34490076-34495534 chr1:25043042-25043833
#listB size=621, e.g. chr1:22186654-22187815 chr1:14347355-14348991 chr1:6375039-6379241
#Intersection size=118, e.g. chr1:20604575-20605685 chr1:15208630-15212469 chr1:40894101-40896577
#Union size=1081, e.g. chr1:20604575-20605685 chr1:34490076-34495534 chr1:25043042-25043833
#Genome size=11503
# Contingency Table:
#notA inA
#notB 10422 460
#inB    503 118
#Overlapping p-value=1.1e-38
#Odds ratio=5.3
#Overlap tested using Fisher's exact test (alternative=greater)
#Jaccard Index=0.1

go.obj1 <- newGeneOverlap(fst_highest1_alp$V2, fst_highest1_pyr$V2, genome.size = length(alp_fst_filtered$V1))


go.obj_test1 <- testGeneOverlap(go.obj1)
print(go.obj_test1)

install.packages("devtools")
library(devtools)
install.packages("VennDiagram")
library(VennDiagram)
devtools::install_github("jeromefroe/circlepackeR")
library(circlepackeR)
install.packages("RColorBrewer")
library(RColorBrewer)

myColours <- brewer.pal(3, "RdYlBu")

venn.diagram(
  x= list(alp_fst_filtered$V2, fst_highest1_alp$V2,fst_highest1_pyr$V2),
  category.names = c("all genes", "highest 1% alps","highest 1% pyrs"),
  filename = 'Venn_1percent_Overlap.png',
  output = TRUE,
  
  imagetype = "png",
  
)
venn.diagram(
  x= list(alp_fst_filtered$V2, fst_highest5_alp$V2,fst_highest5_pyr$V2),
  category.names = c("all genes", "highest 5% alps","highest 5% pyrs"),
  filename = 'Venn_5percent_Overlap.png',
  output = TRUE,
  
  imagetype = "png",
  fill = myColours
  
)
  



#f<-function(data,indices){
#  boots <- data[indices,]
#  boots5_alp <- alp_fst %>% as.data.frame(alp_fst) %>% slice_sample(alp_fst$V2,prop=0.05)
#  boots5_pyr <- pyr_fst %>% as.data.frame(pyr_fst) %>% slice_sample(pyr_fst$V2,prop=0.05)
#  bootsinboth <- boots5_pyr %>% filter(boots5_pyr$V2 %in% boots5_alp$V2)
#  r_bootfactor <- (length(bootsinboth$V1)*length(alp_fst_filtered$V1))/(length(boots5_alp$V1)*length(boots5_pyr$V1))
#  return(r_bootfactor)
#}
#

#bootstraps <- boot(data = alp_fst_filtered$V2,statistic = f, R=100)




#t-test?

t.test(pyr_fst$V5,alp_fst$V5)
#Welch Two Sample t-test
# 
#data:  pyr_fst$V5 and alp_fst$V5
#t = 44.936, df = 23987, p-value < 2.2e-16
#alternative hypothesis: true difference in means is not equal to 0
#95 percent confidence interval:
#  0.09949944 0.10857546
#sample estimates:
#  mean of x mean of y 
#0.3805143 0.2764769 


#smoll in both: 5
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

