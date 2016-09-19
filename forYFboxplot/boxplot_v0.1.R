#!/mnt/software/stow/R-3.1.0/bin/Rscript-3.1.0
library(ggplot2)

# version:
# 0.1: 
#   number of parameters can be various
args <- commandArgs(trailingOnly = TRUE)
lib <- args[1]
result <-paste(lib, "_boxplot.png", sep="") 
png(result)
input <- paste(lib, ".in", sep="")
mydata<-read.table(header=TRUE, input)
argslength <- length(args)
mydata$Normal_Cancer <- factor(mydata$Normal_Cancer, levels = c("NormalSV", "CancerSV", tail(args, argslength - 1)))
p <- qplot(Normal_Cancer,goodbadtag_ratio,data=mydata,geom="boxplot")
ylimitation = boxplot.stats(mydata$goodbadtag_ratio)$stats[c(1, 5)] # extreme lower whisker, extreme higher whisker
p + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + coord_cartesian(ylim = ylimitation * 2)
dev.off()

