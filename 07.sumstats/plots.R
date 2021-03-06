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
colnames(pyr_fst) <- ("V1","V2","V3","fst","siteswithdata")
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

hzs_fstdxy <- alp_dxy$V1[(alp_dxy$V1 %in% pyr_dxy$V1)]

pyr_dxy<-pyr_dxy %>%
  filter(V1 %in% pyr_fstdxy) %>%
  filter(V1 %in% hzs_fstdxy)
pyr_fst<-pyr_fst %>%
  filter(V2 %in% pyr_fstdxy) %>%
  filter(V2 %in% hzs_fstdxy)


alp_dxy<-alp_dxy %>%
  filter(V1 %in% alp_fstdxy) %>%
  filter(V1 %in% hzs_fstdxy)
alp_fst<-alp_fst %>%
  filter(V2 %in% alp_fstdxy) %>%
  filter(V2 %in% hzs_fstdxy)

# making pretty plots
pyr_genes <- cbind.data.frame(pyr_dxy$V1,pyr_dxy$dxy,pyr_fst$V5)
alp_genes <- cbind.data.frame(alp_dxy$V1,alp_dxy$dxy,alp_fst$V5)
colnames(pyr_genes) <- c("gene","dxy","fst")
colnames(alp_genes) <- c("gene","dxy","fst")

genes<-cbind.data.frame(pyr_genes$gene,pyr_genes$dxy,pyr_genes$fst,alp_genes$dxy,alp_genes$fst)
#order: genes pyr_dxy pyr_fst alp_dxy alp_fst
colnames(genes)<-c("gene","pyr","pyr_fst","alp","alp_fst")
#View(genes)


dxys<-stack(genes,select = c(pyr,alp),drop = TRUE)
colnames(dxys)<-c("dxy","hz")
#view(dxys)
fsts<-stack(genes,select = c(pyr_fst,alp_fst),drop = TRUE)
colnames(fsts)<-c("fst","hz")
#view(fsts)
loci<-rep(genes$gene,2)
#view(loci)

plotgenes<-cbind.data.frame(loci,dxys$dxy,fsts$fst,dxys$hz)
colnames(plotgenes)<-c("loci","dxy","fst","hz")

ggplot(data=plotgenes, aes(x=fst,y=dxy,color=hz))+
  geom_point(aes(x=fst,y=dxy,color=hz),size=1,shape=21)+
  geom_smooth(aes(fill=hz),method = lm,se=FALSE,size=1.2)+
  scale_color_manual(values = c("#D10000","#489CDA"),name="Hybrid Zone",label=c("Pyrenees","Alps"))+
  scale_fill_manual(values = c("#930D01","#26549C"),name="Hybrid Zone",label=c("Pyrenees","Alps"))+
  labs(title=expression("Per-gene d"["XY"]*"~F"["ST"]*" correlation"),x=expression("F"["ST"]),y=expression("d"["XY"]))+
  theme_classic()

#correlation in the hzs? linear regression dxy response, fst fixed

reg1 <- lm(pyr_genes$dxy~pyr_genes$fst,data=pyr_genes) 
summary(reg1)

  # Call:
  #   lm(formula = pyr_genes$dxy ~ pyr_genes$fst, data = pyr_genes)
  # 
  # Residuals:
  #   Min        1Q    Median        3Q       Max 
  # -0.013091 -0.003573 -0.001170  0.001922  0.032475 
  # 
  # Coefficients:
  #   Estimate Std. Error t value Pr(>|t|)    
  # (Intercept)    0.0148754  0.0001881   79.09   <2e-16 ***
  #   pyr_genes$fst -0.0150551  0.0004205  -35.80   <2e-16 ***
  #   ---
  #   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
  # 
  # Residual standard error: 0.005611 on 5581 degrees of freedom
  # Multiple R-squared:  0.1867,	Adjusted R-squared:  0.1866 
  # F-statistic:  1282 on 1 and 5581 DF,  p-value: < 2.2e-16

hist(residuals(reg1),
     col="darkgray")
plot(fitted(reg1),
     residuals(reg1))

reg2 <- lm(alp_genes$dxy~alp_genes$fst,data=alp_genes)
summary(reg2)

  # Call:
  #   lm(formula = alp_genes$dxy ~ alp_genes$fst, data = alp_genes)
  # 
  # Residuals:
  #   Min        1Q    Median        3Q       Max 
  # -0.012419 -0.004314 -0.001603  0.002197  0.040876 
  # 
  # Coefficients:
  #   Estimate Std. Error t value Pr(>|t|)    
  # (Intercept)    0.0135781  0.0001763   77.03   <2e-16 ***
  #   alp_genes$fst -0.0133129  0.0005186  -25.67   <2e-16 ***
  #   ---
  #   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
  # 
  # Residual standard error: 0.006624 on 5581 degrees of freedom
  # Multiple R-squared:  0.1056,	Adjusted R-squared:  0.1054 
  # F-statistic:   659 on 1 and 5581 DF,  p-value: < 2.2e-16

hist(residuals(reg2),
     col="darkgray")
plot(fitted(reg2),
     residuals(reg2))
