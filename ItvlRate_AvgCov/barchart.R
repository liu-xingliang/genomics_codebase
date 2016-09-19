require("ggplot2")
args <- commandArgs(trailingOnly = TRUE)
t <- read.table(paste(args[1],".itvlrate", sep=""))
t$V1 <- factor(t$V1, levels=c("0", "(0-50]", "(50-100]", "(100-500]", "(500-1000]", "(1000-2000]", ">2000"))
pdf(paste(args[1], ".itvlrate.pdf", sep=""))
ggplot(t, aes(x=V1, y=V2)) + labs(title=args[1]) +ylab("percentage_of_reads") + theme(axis.title.x = element_blank()) + geom_bar(stat="identity")
dev.off()

