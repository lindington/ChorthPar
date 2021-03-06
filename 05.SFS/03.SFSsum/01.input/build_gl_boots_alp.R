#This script is used to combine gene SFS into a single 'genesum' SFS that contains all the data for a species comparison. It also builds 100 bootstrapped SFS using resampling with replacement of gene SFS.

options(scipen=999)

t <- 'alp'

#Split taxa pair into taxa 1 and 2
t1 <- 'gom'
t2 <- 'tar'
  
#read in bamlists to get number of individuals
t1file <- read.csv(paste("../../01.SAF_files/01.input/bamlist_a_gom.txt",sep = ""), header = FALSE)
t2file <- read.csv(paste("../../01.SAF_files/01.input/bamlist_a_tar.txt",sep = ""), header = FALSE)
  
t1n <- length(t1file$V1)
t2n <- length(t2file$V1)
  
#read in filenames of gene SFS
filelist <- list.files(paste0('../../02.SFS_per_gene/02.output/02.big',t))
  
#Sum gene SFS into total SFS and clean up.
all_sfs <- t(sapply(filelist, function(x) scan(paste0('../../02.SFS_per_gene/02.output/02.big',t,'/',x)), simplify = TRUE))
  
all_sfs <- na.omit(all_sfs)
 
summed_sfs <- colSums(all_sfs)
  
#Write combined gene SFS to single file with appendage 'genesum'
sink(paste0('../02.output/2dsfs_',t,'_fold0_','genesumbig.sfs'), append = FALSE)
cat(paste0((2*t1n)+1,' ',(2*t2n)+1,' unfolded "',t1,'" "',t2,'"'))
cat('\n')
sink()
  
write(summed_sfs, file = paste0('../02.output/2dsfs_',t,'_fold0_','genesumbig.sfs'), ncolumns = length(summed_sfs), append = TRUE, sep = " ")
 
#Build bootstrap SFS using sampling with replacement of gene SFS.
for (b in 1:100) {
  
  sample_sfs <- all_sfs[sample(nrow(all_sfs),size=nrow(all_sfs),replace=TRUE),]
  boot_sfs <- colSums(sample_sfs)
    
  sink(paste0('../03.gl_boot_sfs/02.big',t,'/boot',b,'.sfs'), append = FALSE)
  cat(paste0((2*t1n)+1,' ',(2*t2n)+1,' unfolded "',t1,'" "',t2,'"'))
  cat('\n')
  sink()
   
  write(boot_sfs, file = paste0('../03.gl_boot_sfs/02.big',t,'/boot',b,'.sfs'), ncolumns = length(boot_sfs), append = TRUE, sep = " ")
    
}

