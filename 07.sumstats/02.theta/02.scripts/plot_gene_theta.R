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

#This script is used to produce theta distributions for population comparisons of Chorthippus species.
setwd("C:/Users/Jag/Documents/GitHub/ChorthPar/07.sumstats/02.theta/03.output/")


#set colour according to rest of analyses
colperpop <- c("POR"="#D10000","CSY"="#D10000","ERY"="#D10000","PHZ"="#000000",
               "PAR"="#489CDA","TAR"="#489CDA","AHZ"="#000000","GOM"="#26549C",
               "SLO"="#A4A4A4","DOB"="#A4A4A4")

#Read in per gene thetas estimates for all populations
getwd()
pops <- c("POR","CSY","ERY","PHZ","PAR","TAR","AHZ","GOM","SLO","DOB")

for (pop in pops){
  sumstats<-fread(paste0("per_gene_thetas_",pop),header = TRUE)
  assign(paste0("sumstats_",pop),sumstats)
}

thetas <- cbind.data.frame(sumstats_POR$thetaW,sumstats_CSY$thetaW,
                           sumstats_ERY$thetaW,sumstats_PHZ$thetaW,
                           sumstats_PAR$thetaW,sumstats_TAR$thetaW,
                           sumstats_AHZ$thetaW,sumstats_GOM$thetaW,
                           sumstats_SLO$thetaW,sumstats_DOB$thetaW)


pis <- cbind.data.frame(sumstats_POR$pi,sumstats_CSY$pi,
                        sumstats_ERY$pi,sumstats_PHZ$pi,
                        sumstats_PAR$pi,sumstats_TAR$pi,
                        sumstats_AHZ$pi,sumstats_GOM$pi,
                        sumstats_SLO$pi,sumstats_DOB$pi)

tajDs <- cbind.data.frame(sumstats_POR$TajimaD,sumstats_CSY$TajimaD,
                          sumstats_ERY$TajimaD,sumstats_PHZ$TajimaD,
                          sumstats_PAR$TajimaD,sumstats_TAR$TajimaD,
                          sumstats_AHZ$TajimaD,sumstats_GOM$TajimaD,
                          sumstats_SLO$TajimaD,sumstats_DOB$TajimaD)
mean(tajDs$POR)
view(tajDs)
averagepi<- mean(c(mean(pis$POR),mean(pis$CSY),mean(pis$ERY),mean(pis$PHZ),mean(pis$PAR),
                   mean(pis$TAR),mean(pis$AHZ),mean(pis$GOM),mean(pis$SLO),mean(pis$GOM)))
averagepi
colnames(thetas) <- pops 
colnames(pis) <- pops 
colnames(tajDs) <- pops

#stack populations in same column
thetas <- stack(thetas)
colnames(thetas)<-c("theta","pop")
pis <- stack(pis)
colnames(pis) <- c("pi","pop")
tajDs <- stack(tajDs)
colnames(tajDs) <- c("tajD","pop")

#plot violin plots
pthetas <- ggplot(thetas, aes(x=theta, y=pop, fill=pop)) + 
  geom_violin(trim = TRUE, color="white" ) +
  scale_fill_manual(values=colperpop,name="Populations",
                    breaks=c("POR","CSY","ERY","PHZ","PAR","TAR","AHZ","GOM","SLO","DOB"),
                    labels=c("Portugal","Central System","Erythropus","Pyrenees HZ","Parallelus",
                             "Tarrenz","Alps HZ","Gomagoi","Slovenia","Dobratsch")) +
  stat_summary(fun=mean, geom="point", size=2, color = "white") +
  #stat_summary(fun=median, geom="point", shape=21, size=2, color="white")+
  scale_y_discrete(limits=rev) +
  xlim(0,30)
pthetas

ppis <- ggplot(pis, aes(x=pi, y=pop, fill=pop)) + 
  geom_violin(trim = TRUE, color="white" ) +
  scale_fill_manual(values=colperpop,name="Populations",
                    breaks=c("POR","CSY","ERY","PHZ","PAR","TAR","AHZ","GOM","SLO","DOB"),
                    labels=c("Portugal","Central System","Erythropus","Pyrenees HZ","Parallelus",
                             "Tarrenz","Alps HZ","Gomagoi","Slovenia","Dobratsch")) +
  stat_summary(fun=mean, geom="point", size=2, color = "white") +
  #stat_summary(fun=median, geom="point", shape=21, size=2, color="white")+
  scale_y_discrete(limits=rev) +
  xlim(0,26)

ppis


ptajDs <- ggplot(tajDs, aes(x=tajD, y=pop, fill=pop)) + 
  geom_violin(trim = TRUE, color="white" ) +
  scale_fill_manual(values=colperpop,name="Populations",
                    breaks=c("POR","CSY","ERY","PHZ","PAR","TAR","AHZ","GOM","SLO","DOB"),
                    labels=c("Portugal","Central System","Erythropus","Pyrenees HZ","Parallelus",
                             "Tarrenz","Alps HZ","Gomagoi","Slovenia","Dobratsch")) +
  stat_summary(fun=mean, geom="point", size=2, color = "white") +
  #stat_summary(fun=median, geom="point", shape=21, size=2, color="white")+
  scale_y_discrete(limits=rev) + 
  xlim(-1,1)
  #coord_fixed(ratio = 0.5, xlim = NULL, ylim = NULL, expand = TRUE, clip = "on")

ptajDs

ggsave("sizedtajD",ptajDs)

