setwd("C:/Users/Jag/Documents/LMU/EES/sem5/paper/02bestk/newdata")
colors = c("#242424","#ED797C", #black biggutulus, #lightred erythropus
           "#A6CEED","#26549C", #lightblue parallelus europe, #darkblue parallelus italy
           "#A4A4A4","#930D01", #light gray slovenia, #darkred portugal
           "#489CDA","#D10000", #blue tarrenz, #red central system   
           "#7F7F7F","#FAD9BF", #dark gray dobratsch,
           "#1976D2","#FDD884", ##
           "#FDFADD","#E55748", ##
           "#DCF199","#4DA7B0", ##
           "#7BCAA4","#9E0142", ##
           "#3C7AB6") ##


mainlines = c(5,10,15,20,25,30,35,40,45,50)
dotlines = c(1:54)
# Colors you need to change manually,PITA
colorscrambles = list()
colorscrambles[[2]] = c(1,3)
colorscrambles[[3]] = c(2,1,3)
colorscrambles[[4]] = c(2,3,1,4)
colorscrambles[[5]] = c(4,3,1,2,5)
colorscrambles[[6]] = c(6,3,4,1,2,5)
colorscrambles[[7]] = c(6,4,7,1,2,3,5)
colorscrambles[[8]] = c(5,4,1,8,2,3,7,6)
colorscrambles[[9]] = c(3,5,8,7,9,6,2,1,4)
colorscrambles[[10]] = c(10,5,9,2,3,1,6,7,4,8)
colorscrambles[[11]] = c(10,11,3,1,9,5,2,4,8,7,6)
colorscrambles[[12]] = c(3,8,2,6,11,10,5,4,12,9,1,7)
colorscrambles[[13]] = c(5,4,10,11,7,8,13,12,6,9,3,1,2)
colorscrambles[[14]] = c(8,6,7,13,3,9,11,12,2,1,5,10,14,4)
colorscrambles[[15]] = c(8,6,7,13,3,9,11,14,2,1,5,10,15,4,12)

par(mar=c(0.75,0,0,0),oma=c(0,0,1,0))
layout(c(1:11)) #11 is max clusters
for (i in 2:11) { #11 is max clusters
  # new_K11_50reps.qopt
  Q = t(as.matrix(read.table(paste0("new_K",i,
                                    "_50reps.qopt"))))
  # The order of populations you want to show on the plot
  col.order <- c(1:5,16:20,11:15,21:25,9:10,6:8,34:35,31:33,51:55,
                 36:40,46:50,26:30,41:45) 
  #BIG; POR; CSY; ERY; PAR; TAR; ALP; GOM; DOB; SLO 
  Q <- Q[,col.order]
  barplot(Q,col=colors[colorscrambles[[i]]],border=colors[
    colorscrambles[[i]]],axes=F,space=c(rep(0,55)))
  sapply(mainlines,function(x){lines(c(x,x),c(0,1),lty=1,lwd=1.5)})
  sapply(dotlines,function(x){lines(c(x,x),c(0,1),lty=3,col="black")})
  mtext(paste0("K=",i),side=2,line=-2,font =2)
}

