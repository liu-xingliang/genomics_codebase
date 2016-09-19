######################################
# N50 definition:
# Given a set of sequences of varying lengths, the N50 length is defined as the length N for which 50% of all bases in the sequences are in a sequence of length L < N (https://www.broad.harvard.edu/crd/wiki/index.php/N50, but the calculation is slightly different, we use the length of real read as N50, instead of median)
#
# L50 definition:
# L50 count is defined as the smallest number of contigs whose length sum produces N50 (https://en.wikipedia.org/wiki/N50,_L50,_and_related_statistics)
#
# Original codes are got from https://gist.githubusercontent.com/shujishigenobu/1858458/raw/e809bfc1988ca4a8b600ca90ea58af7ba71d06a1/calc_N50.R and changed
#
# Similar implementation is found:
# http://genomics-array.blogspot.sg/2011/02/calculating-n50-of-contig-assembly-file.html
######################################

# arguments:
# input -> length list of contigs or scaffolds, no header
args <- commandArgs(trailingOnly = TRUE)
for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
}

len <- read.table(input, header=FALSE)$V1

len.sorted <- as.numeric(rev(sort(len)))
N50 <- len.sorted[cumsum(len.sorted) >= sum(len.sorted)*0.5][1]
L50 <- length(len.sorted[cumsum(len.sorted) <= sum(len.sorted)*0.5])

N90 <- len.sorted[cumsum(len.sorted) >= sum(len.sorted)*0.9][1]
L90 <- length(len.sorted[cumsum(len.sorted) <= sum(len.sorted)*0.9])

cat(paste0("N50:", N50, "\n"))
cat(paste0("L50:", L50, "\n"))
cat(paste0("N90:", N90, "\n"))
cat(paste0("L90:", L90, "\n"))
