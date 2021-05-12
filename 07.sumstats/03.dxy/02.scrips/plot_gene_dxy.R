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

#This script is used to produce pairwise Dxy distributions for population comparisons of Chorthippus parallelus
getwd()
setwd("03.dxy/03.output/")

#Read in hz level pairwise Dxy
pyr_dxy <- fread("per_gene_dxy_pyr.csv", header = TRUE)
#length(pyr_dxy$V2)
#filter by sites > 20 vs > 1000 
pyr_dxy <- pyr_dxy %>%
  filter(pyr_dxy$siteswithdata > 1000)
#length(pyr_dxy$V2)
# min   20: 12392
# min 1000: 6077

alp_dxy <- fread("per_gene_dxy_alp.csv", header = TRUE)
#filter by sites > 20 vs > 1000
alp_dxy <- alp_dxy %>%
  filter(alp_dxy$siteswithdata > 1000)
#length(alp_dxy$V2)
# min   20: 11404
# min 1000: 5813


#put all the genes in the same matrix
dxy_genes <- cbind(pyr_dxy$dxy,alp_dxy$dxy)
#View(dxy_genes)
colnames(dxy_genes) <- c("pyr","alp")
hzcolours<-c("red","#489CDA")


a<-as.data.frame(dxy_genes)
as <- stack(a)
view(as)
#plot the distribution of genes by fst values
ggplot(data=as, aes(x=values, fill=ind)) + 
  geom_density(aes(group=ind), alpha=0.3) +
  scale_fill_manual(values=hzcolours, name = "Hybrid Zones", labels=c("Pyrenees","Alps"))+
  labs(title=expression("Per-gene d"["XY"]*" distributions"),x=expression("d"["XY"]),y="Density")+
  theme_classic()


#plot dxy per gene length
ggplot(data = pyr_dxy, aes(x=dxy,y=siteswithdata)) + geom_point()
ggplot(data = alp_dxy, aes(x=dxy,y=siteswithdata)) + geom_point()



#find genes that are in both pyr and alps:
only_pyr_dxy <- pyr_dxy$V1[!(pyr_dxy$V1 %in% alp_dxy$V1)]
#length(only_pyr)
#1053 genes present in pyr but not in alp
#min 1000: [1] 494
only_alp_dxy <- alp_dxy$V1[!(alp_dxy$V1 %in% pyr_dxy$V1)]
#length(only_alp)
#65 genes present in alp but not in pyr
#min 1000: [1] 230

dxy_bothhzs <- alp_dxy$V1[(alp_dxy$V1 %in% pyr_dxy$V1)]
#length(alpandpyr)
#[1] 11339
#min 1000: [1] 5583



#filter hybrid zones by genes found in both

pyr_dxy <- pyr_dxy %>%
  filter(V1 %in% dxy_bothhzs)
#length(pyr_dxy_filtered$V2)
#[1] 11339
#min 1000: [1] 5583

alp_dxy <- alp_dxy %>%
  filter(V1 %in% dxy_bothhzs)
#View(alp_dxy_filtered)
#length(alp_dxy_filtered$V2)
#[1] 11339
#min 1000: [1] 5583

#make sure the genes are in the same order
#sum(alp_dxy_filtered$V1==pyr_dxy_filtered$V1)
#[1] 11339
#min 1000: [1] 5583

#include the positions in the matrix
dxy_genes_plot <- cbind(pyr_dxy$dxy, alp_dxy$dxy)
#View(fst_genes_filteredplot)


b <- as.data.frame(dxy_genes_plot)
colnames(b)<-c("pyr","alp")
bs <- stack(b)
colnames(bs)<-c("dxy","hz")

bt<- as.data.table(bs)
gg <- bt[,list(x=density(dxy)$x, y=density(dxy)$y),by="hz"]
#  calculate quantiles
q1 <- quantile(bt[hz=="pyr",dxy],0.95)
q2 <- quantile(bt[hz=="alp",dxy],0.95)
view(q1)
view(bt)
which(is.na(q1))
#plot the distribution of genes in both hzs by fst values
#ggplot(data=bs, aes(x=dxy)) + geom_density(aes(group=hz, colour=hz))

ggplot(data=bs, aes(x=dxy, fill=hz)) + 
  geom_density(alpha=0.3) +
  scale_fill_manual(values=hzcolours, name = "Hybrid Zones", labels=c("Pyrenees","Alps"))+
  labs(title=expression("Per-gene d"["XY"]*" distributions"),x=expression("d"["XY"]),y="Density")+
  geom_ribbon(data=subset(gg,hz=="pyr" & x>q1),
              aes(x=x,ymax=y),ymin=0,fill="#D10000", alpha=0.8)+
  geom_ribbon(data=subset(gg,hz=="alp" & x>q2),
              aes(x=x,ymax=y),ymin=0,fill="#26549C", alpha=0.8)+
  #geom_vline(xintercept = 0.2349, color="#26549C")+
  #geom_vline(xintercept = 0.3570211, color="#D10000")+
  theme_classic()


dxy_genes_20 <- cbind(pyr_dxy_filtered$V1, pyr_dxy_filtered$dxy, alp_dxy_filtered$dxy)
colnames(dxy_genes_20) <- c("locus","pyr","alp")




#find highest 5% of genes
dxy_highest5_pyr <- pyr_dxy %>%
  as.data.frame(pyr_dxy) %>%
  slice_max(pyr_dxy$dxy,prop=0.05)
#view(dxy_highest5_pyr)
#length(dxy_highest5_pyr$V1)
# length: 619
#min 1000: [1] 303

dxy_highest5_alp <- alp_dxy %>%
  as.data.frame(alp_dxy) %>%
  slice_max(alp_dxy$dxy,prop=0.05)
#length(dxy_highest5_alp$V1)
# length: 570
#min 1000: [1] 290

dxy_highest5inboth_pyr <- dxy_highest5_pyr %>%
  filter(dxy_highest5_pyr$V1 %in% dxy_highest5_alp$V1)
#view(dxy_highest5inboth_pyr)
#length(dxy_highest5inboth_pyr$V2)
#[1] 313
#min 1000: [1] 176

dxy_highest5inboth_alp <- dxy_highest5_alp %>%
  filter(dxy_highest5_alp$V1 %in% dxy_highest5_pyr$V1)
#view(dxy_highest5inboth_alp)
#length(dxy_highest5inboth_alp$V2)
#[1] 313
#min 1000: [1] 176

write.csv(fst_highest5inboth_alp,"fsttop5.csv", row.names = FALSE)


#find overlap between top5 datasets:
#representation factor
r_factor=(length(dxy_highest5inboth_alp$V1)*length(alp_dxy_filtered$V1))/(length(dxy_highest5_alp$V1)*length(dxy_highest5_pyr$V1))
view(r_factor)

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


go.obj <- newGeneOverlap(dxy_highest5_alp$V1, dxy_highest5_pyr$V1, genome.size = length(alp_dxy_filtered$V1))


go.obj_test <- testGeneOverlap(go.obj)
print(go.obj_test)
# Detailed information about this GeneOverlap object:
#   listA size=290, e.g. chr1:36503411-36507885 chr1:8150754-8154186 chr1:4167778-4171684
# listB size=303, e.g. chr1:2285917-2291653 chr1:36034678-36037971 chr1:32187244-32191345
# Intersection size=176, e.g. chr1:36503411-36507885 chr1:8150754-8154186 chr1:4167778-4171684
# Union size=417, e.g. chr1:36503411-36507885 chr1:8150754-8154186 chr1:4167778-4171684
# Genome size=5583
# # Contingency Table:
# notA inA
# notB 5166 114
# inB   127 176
# Overlapping p-value=1.3e-168
# Odds ratio=62.7
# Overlap tested using Fisher's exact test (alternative=greater)
# Jaccard Index=0.4

