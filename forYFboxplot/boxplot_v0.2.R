#!/mnt/software/stow/R-3.1.0/bin/Rscript-3.1.0
library(ggplot2)

# version:
# 0.1: 
#   number of parameters can be various
# 0.2:
#   change the color of axis labels
#   change the color of axis name
args <- commandArgs(trailingOnly = TRUE)
lib <- args[1]
result <-paste(lib, "_boxplot.png", sep="") 
png(result)
input <- paste(lib, ".in", sep="")
mydata<-read.table(header=TRUE, input)
argslength <- length(args)
mydata$Normal_Cancer <- factor(mydata$Normal_Cancer, levels = c("NormalSV", "CancerSV", tail(args, argslength - 1)))
#p <- qplot(Normal_Cancer,goodbadtag_ratio,data=mydata,geom="boxplot")
#p <- ggplot(mydata, aes(Normal_Cancer,goodbadtag_ratio, color = factor(Normal_Cancer))) + geom_boxplot();
p <- ggplot(mydata, aes(Normal_Cancer,goodbadtag_ratio)) + geom_boxplot();
ylimitation = boxplot.stats(mydata$goodbadtag_ratio)$stats[c(1, 5)] # extreme lower whisker, extreme higher whisker
p <- p + theme(axis.text.x = element_text(colour = 'black', angle = 45, hjust = 1), axis.text.y = element_text(colour = 'black')) + coord_cartesian(ylim = ylimitation * 1.05)
#p <- p + theme(legend.position = "none")
p <- p + theme(axis.title.x = element_text(colour = 'blue'), axis.title.y = element_text(colour = 'blue'))
#p <- p + theme(axis.line = element_line(colour = 'red'))
p
dev.off()

