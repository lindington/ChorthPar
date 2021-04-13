#########################################
#                                       #
#   Calculates Dxy from mafs files      #
#                                       #
#   Author: Joshua Penalba              #
#   Date: 22 Oct 2016                   #
#                                       #
#########################################


# NOTES
# * Prior to calculating Dxy the following steps are recommended:
#   1. Run ANGSD with all populations with a -SNP_pval and -skipTriallelic flags.
#   2. Rerun ANGSD per population 
#       Use the -sites flag with a file corresponding to the recovered SNPs.
#       This will guarantee that sites with an allele fixed in one population is still included.
#       Remove the -SNP_pval flag.
#       IMPORTANT: Include an outgroup reference to polarize alleles.
#   3. Gunzip the resulting mafs files.
# 
# * Make sure the totLen only includes the chromosomes being analyzed.
# * minInd flag not added, assuming already considered in the ANGSD run.
# * Test for matching major and minor alleles not included as it would filter out sequencing errors. 
#   This has been accounted for in the allele frequency calculations.
#   This filter may give an underestimate of dxy.
# * Per site Dxy of ~0 could be common if the alternate alleles are present in a population other than the two being included in the calculation.


### Creating an argument parser
# install.packages("optparse")
# library("optparse")

# option_list = list(
#   make_option(c("-p","--popA"), type="character",default=NULL,help="path to unzipped mafs file for pop 1",metavar="character"),
#   make_option(c("-q","--popB"), type="character",default=NULL,help="path to unzipped mafs file for pop 2",metavar="character"),
#   make_option(c("-t","--totLen"), type="numeric",default=NULL,help="total sequence length for global per site Dxy estimate [optional]",metavar="numeric")
# )
# opt_parser = OptionParser(option_list=option_list)
# opt = parse_args(opt_parser)

### Troubleshooting input
# if(is.null(opt$popA) | is.null(opt$popB)){
#   print_help(opt_parser)
#   stop("One or more of the mafs paths are missing", call.=FALSE)
# }

# if(grepl('.gz$',opt$popA) | grepl('.gz$',opt$popB)){
#   print_help(opt_parser)
#   stop("One or more of the mafs is gzipped.", call.=FALSE)
# }

# if(is.null(opt$totLen)){
#   print("Total length not supplied. The output will not be a per site estimate.")
# }
pops1 <- c("ERY","TAR")


# guessing i should use shortest length, but why?
#177622 saf_ERY.mafs.gz
#182455 saf_PAR.mafs.gz
#163091 saf_GOM.mafs.gz
#166805 saf_TAR.mafs.gz

for (pop1 in pops1){
  if (pop1 == "ERY") {
    pop2 <- "PAR"
   # totLen <- 16693821 (from how many sites get a dxy calculation when totLen is 0)
    hz <- "pyr"
  } else {
    pop2 <- "GOM"
   # totLen <- 15429162 (from how many sites get a dxy calculation when totLen is 0)
    hz <- "alp"
    }
  print(hz)
  popA <- as.character(paste0("../../../05.SFS/01.SAF/03.output/saf_",pop1,".mafs.gz"))
  popB <- as.character(paste0("../../../05.SFS/01.SAF/03.output/saf_",pop2,".mafs.gz"))
 # totLen <- as.numeric(totLen)


  ### Reading data in
  allfreqA <- read.table(popA,sep='\t',row.names=NULL, header=T)
  allfreqB <- read.table(popB,sep='\t',row.names=NULL, header=T)

  ### Manipulating the table and print dxy table
  allfreq <- merge(allfreqA, allfreqB, by=c("chromo","position"))
  allfreq <- allfreq[order(allfreq$chromo, allfreq$position),]
  # -> Actual dxy calculation
  allfreq <- transform(allfreq, dxy=(knownEM.x*(1-knownEM.y))+(knownEM.y*(1-knownEM.x)))
  write.table(allfreq[,c("chromo","position","dxy")], file=paste0("site_dxy_",hz,".txt"),quote=FALSE, row.names=FALSE, sep='\t')
  print(paste0('Created site_dxy',hz,'.txt'))

  ### Print global dxy
  print(paste0('Global dxy in ',hz,' is: ',sum(allfreq$dxy)))
  #if(!is.null(totLen)){
  #  print(paste0('Global per site Dxy in ',hz,' is: ',sum(allfreq$dxy)/totLen))
  #}
}


