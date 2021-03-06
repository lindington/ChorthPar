#Not all combinations are valid, as for the test to be informative, the topology tested must match the known species tree
#This script takes the tables produced by angsd as an input, along with the species tree described below to remove any outputs that violate the species tree


#IMPORTANT: Be sure to change the species tree if needed before running the script. As of now, it is set to the phylogeny for Chorthippus spp. produced by Burcin
library(data.table)
library(ape)

#Put D-statistic file as argument in command line

args <- commandArgs(trailingOnly=TRUE)
message("Arguments entered:")
args
#message("The first argument should be 'all' to select how you grouped your bam files. The second argument is your untrimmed D-statistic file.")

if (args[1] == "all") {

#Species tree for enriques tree
#species_tree <- read.tree(text = "(((CHYB_PHY,((CERY_CSY,CERY_B_E),CERY_POR)),(PPAR_DOB,((PPAR_G_A,PPAR_TAR),((PPAR_PAS,PPAR_GOM),PPAR_SLO)))),CBIG_OUT);")
#species tree for treemix tree
species_tree <- read.tree(text = "(((CHYB_PHY,((CERY_CSY,CERY_B_E),CERY_POR)),(PPAR_DOB,(((PPAR_G_A,PPAR_TAR),PPAR_SLO),(PPAR_PAS,PPAR_GOM)))),CBIG_OUT);")
}

#if (args[1] == "pyrenees") {

#Species tree for species
#species_tree <- read.tree(text = "(((CeryPo,(CeryEs,CeryBi)),(CparAr,CparGa)),Cbig);")

#}

message("This is your selected species tree.")
species_tree

dataset <- fread(args[2],header = TRUE)
filename <- tools::file_path_sans_ext(args[2])

topologies <- dataset[,9:12]

checkassumption <- function(x) {                                                                     
  tips <- unlist(x)
  taxa <- species_tree$tip.label

  test.tree <- read.tree(text = paste("(((",tips[1],",",tips[2],"),",tips[3],"),",tips[4],");",sep =""))
  true.tree <- drop.tip(species_tree,taxa[!taxa %in% tips])

  all.equal.phylo(test.tree,true.tree)

}

truetopologies <- apply(topologies, 1, checkassumption)

write.table(dataset[truetopologies,], paste(filename,".trimmed.csv",sep = ""), append = FALSE, sep = ",", dec = ".", row.names = FALSE, col.names = TRUE)
