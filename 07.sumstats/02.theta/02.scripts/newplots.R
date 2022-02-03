pops <- c("POR","CSY","ERY","PHZ","PAR","TAR","AHZ","GOM","SLO","DOB")
getwd()
setwd("C:/Users/Jag/Documents/GitHub/ChorthPar/07.sumstats/02.theta/02.scripts")


for (pop in pops){
  print(pop)
  theta <- read.table(paste0("../03.output/per_gene_thetas_",pop), header=T)
  theta$nsites <- theta$V3 - theta$V2
  theta$pigene <- theta$pi/theta$nsites
  theta$thetagene <- theta$thetaW/theta$nsites
  write.table(theta, file = paste0('../03.output/better_per_gene_thetas_',pop),row.names=FALSE, quote = FALSE, sep = "\t")
}


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


for (pop in pops){
  sumstats<-fread(paste0("trying_per_gene_thetas_",pop),header = TRUE)
  assign(paste0("sumstats_",pop),sumstats)
}


pis <- cbind.data.frame(sumstats_POR$pigene,sumstats_CSY$pigene,
                        sumstats_ERY$pigene,sumstats_PHZ$pigene,
                        sumstats_PAR$pigene,sumstats_TAR$pigene,
                        sumstats_AHZ$pigene,sumstats_GOM$pigene,
                        sumstats_SLO$pigene,sumstats_DOB$pigene)



thetas <- cbind.data.frame(sumstats_POR$thetaW,sumstats_CSY$thetaW,
                           sumstats_ERY$thetaW,sumstats_PHZ$thetaW,
                           sumstats_PAR$thetaW,sumstats_TAR$thetaW,
                           sumstats_AHZ$thetaW,sumstats_GOM$thetaW,
                           sumstats_SLO$thetaW,sumstats_DOB$thetaW)


colnames(pis)<-pops
colnames(thetas)<-pops

averagetheta<-mean(c(mean(thetas$POR),mean(thetas$CSY),mean(thetas$ERY),mean(thetas$PHZ),mean(thetas$PAR),
                     mean(thetas$TAR),mean(thetas$AHZ),mean(thetas$GOM),mean(thetas$SLO),mean(thetas$DOB)))
averagetheta

averagepi<- mean(c(mean(pis$POR),mean(pis$CSY),mean(pis$ERY),mean(pis$PHZ),mean(pis$PAR),
                   mean(pis$TAR),mean(pis$AHZ),mean(pis$GOM),mean(pis$SLO),mean(pis$DOB)))
averagepi

#stack populations in same column

pis <- stack(pis)
colnames(pis) <- c("pi","pop")

ppis <- ggplot(pis, aes(x=pi, y=pop, fill=pop)) + 
  geom_violin(trim = TRUE, color="white" ) +
  scale_fill_manual(values=colperpop,name="Populations",
                    breaks=c("POR","CSY","ERY","PHZ","PAR","TAR","AHZ","GOM","SLO","DOB"),
                    labels=c("Portugal","Central System","Erythropus","Pyrenees HZ","Parallelus",
                             "Tarrenz","Alps HZ","Gomagoi","Slovenia","Dobratsch")) +
  stat_summary(fun=mean, geom="point", size=2, color = "white") +
  #stat_summary(fun=median, geom="point", shape=21, size=2, color="white")+
  scale_y_discrete(limits=rev) +
  xlim(0,0.013)

ppis

thetas <- stack(thetas)
colnames(thetas)<-c("theta","pop")

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

