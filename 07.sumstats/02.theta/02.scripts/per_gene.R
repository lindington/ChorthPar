pops = c("ERY" "PAR" "TAR" "GOM" "POR" "CSY" "PHZ" "AHZ" "DOB" "SLO")

for (pop in pops){

theta = read.table(paste0("logThetas_",pop,".chr1"), header=T, comment.char="")
genes = read.table("../../../inputs/grasshopperRef.positions")[,2] #use gene position
N     = 50 #number of haploid sequences

genes$start = NA
genes$end = NA
for (i in 1:nrow(genes)){
    genes$start = head(map(strsplit(genes[i,1],"[,:]+"), 2))
    genes$end = head(map(strsplit(genes[i,1],"[,:]+"), 3))
}


#coef needed for calculation of D
a1 = sum(1/1:(N-1));  a2 = sum((1/1:(N-1))^2)
b1 = (N+1)/(3*(N-1)); b2 = 2*(N^2 + N + 3)/(9*N*(N-1))
c1 = b1 - 1/a1;       c2 = b2 - (N+2)/(a1*N) + a2/a1^2
e1 = c1/a1;           e2 = c2/(a1^2+a2)

#loop over genes and calculate thetas, number variant sites, D
genes$thetaW = NA
genes$pi = NA
genes$S = NA
genes$TajimaD = NA
for (i in 1:nrow(genes)){
    sites = (theta$Pos > genes[i,2] & theta$Pos <= genes[i,3])
    genes$thetaW[i]  = sum(exp(theta$Watterson[sites]))
    genes$pi[i]      = sum(exp(theta$Pairwise[sites]))
    genes$S[i]       = a1*genes$thetaW[i]
    genes$TajimaD[i] = (genes$pi[i] - genes$thetaW[i]) / sqrt(e1*genes$S[i] + e2*genes$S[i]^2)
}
head(genes)

write.table(genes, file = paste0('../03.output/per_gene_thetas',pop),sep = "\t")

}