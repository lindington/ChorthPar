hzs = c("alp")
getwd()
setwd("C:/Users/Jag/Documents/GitHub/ChorthPar/07.sumstats/03.dxy/02.scripts")

for (hz in hzs){
    print(hz)
    #N     = 10 #number of haploid sequences (had 50, may have to change for thetas)
    dxys  = read.table(paste0("../03.output/site_dxy_",hz,".chr1"), header=T, comment.char="")
    genes = read.table("../../../inputs/grasshopperRef.positions") #use gene position
    genes <- genes[0:16969,] #only chr. 1
    genes$V1 <- genes$V2
    genes$V2 = NA
    genes$V3 = NA
  #  View(genes)
    
    startpos = as.numeric(sapply(strsplit(as.character(genes$V1),"[:-]"), '[',2))
    endpos = as.numeric(sapply(strsplit(as.character(genes$V1),"[:-]"), '[',3))
    genes$V2 <- as.vector(startpos)
    genes$V3 <- as.vector(endpos)

    
#make cols for dxy calcs
    genes$dxy           = NA
    genes$siteswithdata = NA
     
#loop over genes and calculate dxy
    if(is.unsorted(genes$V2)|is.unsorted(dxys$position)){
        stop(paste0("One of the two tables for hz ",hz," seems not sorted by genomic position!"))
    }
    curr_t<-1
    n_t<-nrow(dxys)
    start_pos<-c()
    end_pos<-c()
    for(i in 1:nrow(genes)){
        not_discovered<-T
        for(cp in curr_t:n_t){
            if(not_discovered){
                if(dxys$position[cp]>=genes$V2[i]){
                    start_pos<-c(start_pos,cp)
                    curr_t<-cp
                    not_discovered<-F
                }
            }
            if(dxys$position[cp]>genes$V3[i]){
                end_pos<-c(end_pos,cp-1)
                break
            }
        }
        print(i)
    }
    
    if(length(start_pos)!=length(end_pos)){
        end_pos<-c(end_pos,nrow(dxys))
    }
    
    sites = sapply(1:length(start_pos),function(i) start_pos[i]:end_pos[i])
    #sum dxy per site for sites within gene and divide by sites (mean)
    genes$dxy = sapply(1:nrow(genes),function(i) sum(dxys$dxy[sites[[i]]])/length(sites[[i]]))
    genes$siteswithdata = sapply(1:nrow(genes), function(i) sum(length(sites[[i]])))
        
#    View(genes)
#    View(data.frame(start_pos,end_pos))
   
    write.table(genes, file = paste0('../03.output/per_gene_dxys_',hz,'.csv'),row.names=FALSE, quote = FALSE, sep = "\t")
    
}
