## had to change order of slovenian samples

Rscript -e 'write.table(cbind(seq(1,50),rep(1,50),c(rep("COR",3),rep("LAT",2),rep("CSY",5),rep("POR",5),rep("ESC",2),rep("BIE",3),rep("DOB",5),rep("ARU",3),rep("GAB",2),rep("PAS",5),rep("SVI",1),rep("VRE",3),rep("SVI",1),rep("GOM",5),rep("TAR",5))),row.names=F,col.names=c("FID","IID","CLUSTER"),sep ="\t",file="plink_all55.clst",quote=F)'
