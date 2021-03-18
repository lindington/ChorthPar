setwd("~/Documents/master thesis project/Theta/new_per_species")
# Read the Per Gene Theta estimate tables
library(readr)

PG_Tajima_Cbig_20_1perallele <- read_delim("~/Documents/master thesis project/Theta/new_per_species/PG_Tajima_Cbig_20_1perallele", 
                                             "\t", escape_double = FALSE, col_names = FALSE, 
                                               trim_ws = TRUE)
PG_Tajima_Cmol_20_1perallele <- read_delim("~/Documents/master thesis project/Theta/new_per_species/PG_Tajima_Cmol_20_1perallele", 
                                           "\t", escape_double = FALSE, col_names = FALSE, 
                                           trim_ws = TRUE)

PG_Tajima_Cbru_20_1perallele <- read_delim("~/Documents/master thesis project/Theta/new_per_species/PG_Tajima_Cbru_20_1perallele", 
                                           "\t", escape_double = FALSE, col_names = FALSE, 
                                           trim_ws = TRUE)

PG_Tajima_Crub_16_1perallele <- read_delim("~/Documents/master thesis project/Theta/new_per_species/PG_Tajima_Crub_16_1perallele", 
                                           "\t", escape_double = FALSE, col_names = FALSE, 
                                           trim_ws = TRUE)

PG_Tajima_Cpar_10_1perallele <- read_delim("~/Documents/master thesis project/Theta/new_per_species/PG_Tajima_Cpar_10_1perallele", 
                                           "\t", escape_double = FALSE, col_names = FALSE, 
                                           trim_ws = TRUE)
#Change the column names
library(dplyr)

PG_Tajima_Cbig_20_1perallele <-PG_Tajima_Cbig_20_1perallele  %>% dplyr::rename(Start_End = X2, Length=X3, Effective_Length=X4, TajimaD=X5) 
PG_Tajima_Cmol_20_1perallele <-PG_Tajima_Cmol_20_1perallele  %>% dplyr::rename(Start_End = X2, Length=X3, Effective_Length=X4, TajimaD=X5) 
PG_Tajima_Cbru_20_1perallele <-PG_Tajima_Cbru_20_1perallele  %>% dplyr::rename(Start_End = X2, Length=X3, Effective_Length=X4, TajimaD=X5) 
PG_Tajima_Cpar_10_1perallele <-PG_Tajima_Cpar_10_1perallele  %>% dplyr::rename(Start_End = X2, Length=X3, Effective_Length=X4, TajimaD=X5) 
PG_Tajima_Crub_16_1perallele <-PG_Tajima_Crub_16_1perallele  %>% dplyr::rename(Start_End = X2, Length=X3, Effective_Length=X4, TajimaD=X5) 

# Density plots for each of them 

library(ggplot2)
p_Tajima_Cbig_20_1perallele <- ggplot(PG_Tajima_Cbig_20_1perallele, aes(x=TajimaD)) + geom_density(fill="coral2", alpha=0.5, colour="coral2") + theme(legend.position = "None")
p_Tajima_Cbig_20_1perallele
p_Tajima_Cmol_20_1perallele <- ggplot(PG_Tajima_Cmol_20_1perallele, aes(x=TajimaD)) + geom_density(fill="darkolivegreen4", alpha=0.5, colour="darkolivegreen4") + theme(legend.position = "None")
p_Tajima_Cmol_20_1perallele
p_Tajima_Cbru_20_1perallele <- ggplot(PG_Tajima_Cbru_20_1perallele, aes(x=TajimaD)) + geom_density(fill="darkgoldenrod2", alpha=0.5, colour="darkgoldenrod2") + theme(legend.position = "None")
p_Tajima_Cbru_20_1perallele
p_Tajima_Crub_16_1perallele <- ggplot(PG_Tajima_Crub_16_1perallele, aes(x=TajimaD)) + geom_density(fill="darkred", alpha=0.5, colour="darkred") + theme(legend.position = "None")
p_Tajima_Crub_16_1perallele
p_Tajima_Cpar_10_1perallele <- ggplot(PG_Tajima_Cpar_10_1perallele, aes(x=TajimaD)) + geom_density(fill="blue", alpha=0.5, colour="blue") + theme(legend.position = "None")
p_Tajima_Cpar_10_1perallele

# Make overlayed density plots
# First extract the Tajimas of each as a different data frame and add name column
onlyTajima_Cbig_1perallele <- PG_Tajima_Cbig_20_1perallele[,5, drop=FALSE]
onlyTajima_Cbig_1perallele$Name <- "Cbig"

onlyTajima_Cmol_1perallele <- PG_Tajima_Cmol_20_1perallele[,5, drop=FALSE]
onlyTajima_Cmol_1perallele$Name <- "Cmol"
onlyTajima_Cbru_1perallele <- PG_Tajima_Cbru_20_1perallele[,5, drop=FALSE]
onlyTajima_Cbru_1perallele$Name <- "Cbru"
onlyTajima_Crub_1perallele <- PG_Tajima_Crub_16_1perallele[,5, drop=FALSE]
onlyTajima_Crub_1perallele$Name <- "Crub"
onlyTajima_Cpar_1perallele <- PG_Tajima_Cpar_10_1perallele[,5, drop=FALSE]
onlyTajima_Cpar_1perallele$Name <- "Cpar"

# Connect the data frames 

PG_Tajima_all_1perallele<- rbind(onlyTajima_Cbig_1perallele, onlyTajima_Cbru_1perallele, onlyTajima_Cmol_1perallele, onlyTajima_Cpar_1perallele, onlyTajima_Crub_1perallele)

p_tajimas_all_1perallele<- ggplot(PG_Tajima_all_1perallele, aes(x=TajimaD, fill=Name, colour=Name)) + geom_density(alpha=0.5)
#p_tajimas_all_1perallele<- p_tajimas_all_1perallele +scale_colour_manual(values = c("Cbig"="coral2", "Cbru"="darkgoldenrod2", "Cmol"="darkolivegreen4", "Cpar"="blue", "Crub"="darkred"))+
 # scale_fill_manual(values = c("Cbig"="coral2", "Cbru"="darkgoldenrod2", "Cmol"="darkolivegreen4", "Cpar"="blue", "Crub"="darkred"))
p_tajimas_all_1perallele<- p_tajimas_all_1perallele +scale_colour_manual(values = c("Cbig"="#660066","Cbru"="#999900","Cmol"="#336600", "Cpar"="#3333FF", "Crub"="#FF0000"))+
  scale_fill_manual(values = c("Cbig"="#660066","Cbru"="#999900","Cmol"="#336600", "Cpar"="#3333FF", "Crub"="#FF0000"))
p_tajimas_all_1perallele
library(ggpubr)
grid.arrange(p_thetas_all_1perallele, p_tajimas_all_1perallele, ncol=2)
fir<- ggarrange(p_thetas_all_1perallele_to0075, p_tajimas_all_1perallele, ncol = 2, common.legend = TRUE,legend = "right", labels = "AUTO", font.label = list(size=18, face="plain"))
fir
