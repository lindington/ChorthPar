#Usage : Rscript -i infile.covar -c component1 - component2 -a annotation.file -o outfile.eps
install.packages("optparse")
library(RColorBrewer)
library(optparse)
library(ggplot2)

option_list <- list(make_option(c('-i','--in_ file'),action='store',type='character',default=NULL,help='Input file (output from ngsCovar)'),
		    make_option(c('-c','--comp'),action='store',type='character',default=1-2,help='Components to plot'),
		    make_option(c('-a','--annot_file'),action='store',type='character',default=NULL,help='Annotation file with individual classification (2 column TSV with ID and ANNOTATION)'),
		    make_option(c('-o','--out_file'),action='store',type='character',default=NULL,help='Output file'))
		    
opt <- parse_args(OptionParser(option_list=option_list))


# Annotation file is in plink cluster format
# Read input file
getwd()
covar <- read.table('50beagle.covar', stringsAsFactors = FALSE);
# Read annot file
annot <- read.table('50plinkcolour.clst',sep="\t",header=TRUE);
#note that plink cluster files are usually tab - separated instead

# Parse components to analyze
comp <- as.numeric(strsplit('1-2',"-",fixed=TRUE)[[1]])
View(comp[1])
# Eigenvalues
eig <- eigen(covar,symm=TRUE);
eig$val <- eig$val/sum(eig$val);
cat(signif(eig$val,digits=3)*100,"\n");

# Plot
PC <- as.data.frame(eig$vectors)
colnames(PC) <- gsub("V","PC",colnames(PC))
PC$Pop <- factor(annot$CLUSTER)

title <- paste("PC",comp[1],"(",signif(eig$val[comp[1]],digits=3)*100,"%)","/PC",comp[2],"(",signif(eig$val[comp[2]],digits=3)*100,"%)",sep="",collapse="")
View(title)
x_axis = paste("PC",comp[1],sep ="")
y_axis = paste("PC",comp[2],sep ="")

#colours set to match throughout the figures of the paper
colperpop <- c("POR"="#D10000","CSY"="#D10000","ERY"="#D10000","PHZ"="#000000","PAR"="#489CDA","TAR"="#489CDA","AHZ"="#000000","GOM"="#26549C","DOB"="#A4A4A4","SLO"="#A4A4A4")

ggplot() + 
  geom_point(aes_string(x=x_axis,y=y_axis,fill=factor(annot$COLOUR)), 
             fill=factor(annot$COLOUR), 
             colour="white",
             data=PC,
             pch = 21,  
             size = 3, 
             stroke = 0.4) +
  scale_y_continuous(minor_breaks = NULL, limits=c(-0.4,0.4)) +
  scale_x_continuous(minor_breaks = NULL, limits=c(-0.4,0.4)) +
  coord_fixed() +
  ggtitle(title) +
	scale_color_manual(values=colperpop,name="Populations",breaks=c("BIG","POR","CSY","ERY","PHZ","PAR","TAR","AHZ","GOM","DOB","SLO"),labels=c("Biguttulus","Portugal","Central System","Erythropus","Pyrenees HZ","Parallelus","Tarrenz","Alps HZ","Gomagoi","Dobratsch","Slovenia")) +
	ggsave('50PCA12new.pdf')

unlink("Rplots.pdf",force=TRUE)
