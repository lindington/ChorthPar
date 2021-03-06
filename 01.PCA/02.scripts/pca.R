#Usage : Rscript -i infile . covar -c component1 - component2 -a annotation . file -o outfile . eps
library(RColorBrewer)
library(optparse)
library(ggplot2)

option_list <- list(make_option(c('-i','--in_ file'),action='store',type='character',default=NULL,help='Input file (output from ngsCovar)'),
		    make_option(c('-c','--comp'),action='store',type='character',default=1-2,help='Components to plot'),
		    make_option(c('-a','--annot_file'),action='store',type='character',default=NULL,help='Annotation file with individual classification (2 column TSV with ID and ANNOTATION)'),
		    make_option(c('-o','--out_file'),action='store',type='character',default=NULL,help='Output file')

opt <- parse_args(OptionParser(option_list=option_list))

# Annotation file is in plink cluster format
# Read input file

covar <- read.table(opt$in_file,stringsAsFact=FALSE);
# Read annot file
annot <- read.table(opt$annot_file,sep="\t",header=TRUE);
#note that plink cluster files are usually tab - separated instead

# Parse components to analyze
comp <- as.numeric(strsplit(opt$comp,"-",fixed=TRUE)[[1]])

# Eigenvalues
eig <- eigen(covar,symm=TRUE);
eig$val <- eig$val/sum(eig$val);
cat(signif(eig$val,digits=3)*100,"\n");

# Plot
PC <- as.data.frame(eig$vectors)
colnames(PC) <- gsub("V","PC",colnames(PC))
PC$Pop <- factor(annot$CLUSTER)

title <- paste("PC",comp[1],"(",signif(eig$val[comp[1]],digits=3)*100,"%)","/PC",comp[2],"(",signif(eig$val[comp[2]],digits=3)*100,"%)",sep="",collapse="")

x_axis = paste("PC",comp[1],sep ="")
y_axis = paste("PC",comp[2],sep ="")

colperpop <- c("BIG"="#191919""POR"="#9E0142","CSY"="#C82F4C","BIE"="#E55748","ESC"="#F6814C","LAT"="#FDB164","COR"="#FDD884","GAB"="#FEF3AB","ARU"="#F5FBAF","TAR"="#DCF199","PAS"="#AFDEA3","GOM"="#7BCAA4","DOB"="#4DA7B0","VRE"="#3C7AB6","SVI"="#5E4FA2")

ggplot() + 
	geom_point(data=PC,aes_string(x=x_axis,y=y_axis,color="Pop")) +
	ggtitle(title) +
	scale_color_manual(values=colperpop,name="Populations",breaks=c("BIG","POR","CSY","BIE","ESC","LAT","COR","GAB","ARU","TAR","PAS","GOM","DOB","VRE","SVI"),labels=c("Biggutulus","Portugal","Central System","Biescas","Escarrilla","La Troya","Corral de Mulas","Gabas","Arudy","Tarrenz","Passage","Gomagoi","Dobratsch","Vremscica","Sviscaki")) +
	ggsave(opt$out_file)

unlink("Rplots.pdf",force=TRUE)
