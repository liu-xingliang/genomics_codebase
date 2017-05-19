#!/bin/bash

# before run this scripts
# export LD_LIBRARY_PATH=/mnt/software/unstowable/root_v5.34.30/lib:/mnt/software/lib:/usr/lib/jvm/jre-1.6.0-sun/lib/amd64/server:/usr/lib/jvm/jre-1.6.0-sun/lib/amd64::/usr/lib64/openmpi/lib/:/opt/sgi/sgimc/lib:/usr/lib64/openmpi/lib/:/mnt/software/unstowable/mosek/6/tools/platform/linux64x86/bin
# use -V in qsub scripts

tbam=$1
nbam=$2
tsex=$3
nsex=$4
output_dir=$5
output_prefix=$6
amplicons_coords=$7 #/mnt/projects/liuxl/ctso4_projects/liuxl/SayLi/CTC_Proj/amplicons_withprimer_coord.bed, must including primer
refGenome=$8 #/mnt/AnalysisPool/libraries/genomes/hg19/hg19.fa, always UCSC version
refGene=$9 #/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/quandico/hg19_refGene.txt, always UCSC version
refversion=${10} # hg19 or human_g1k_v37
Xmx=${11}
primerlen=${12} # median(or mean) of our primer length
tolerance=${13} # default is 12
mingap=${14} # default is 200 
maxgap=${15} # default is 100000

qgetcounts=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/quandico/1.3/QUANDICO-v1.13/scripts/qgetcounts
qcluster=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/quandico/1.3/QUANDICO-v1.13/scripts/qcluster
quandico=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/quandico/1.3/QUANDICO-v1.13/scripts/quandico

t_XY=""
n_XY=""
if [[ $tsex == "M" ]]
then
    t_XY='-s x=1 -s y=1'
elif [[ $tsex == "F" ]]
then
    t_XY='-s x=2 -s y=0'
fi
if [[ $nsex == "M" ]]
then
    n_XY='-r x=1 -r y=1'
elif [[ $nsex == "F" ]]
then
    n_XY='-r x=2 -r y=0'
fi

# -s sample(tumour) -r reference(normal)
$qgetcounts -i $tbam -a $amplicons_coords --minmapq 30 --primerlen ${primerlen} --tolerance $tolerance --properly > $tbam.counts 
$qgetcounts -i $nbam -a $amplicons_coords --minmapq 30 --primerlen ${primerlen} --tolerance $tolerance --properly > $nbam.counts


if [[ $refversion == "human_g1k_v37" ]]; then
    /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.45.x86_64/bin/java -XX:+UseSerialGC -Xmx$Xmx -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/github convert_hg19_and_human_g1k_v37 $tbam.counts $tbam.hg19.counts 1 human_g1k_v37 hg19
    /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.45.x86_64/bin/java -XX:+UseSerialGC -Xmx$Xmx -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/github convert_hg19_and_human_g1k_v37 $nbam.counts $nbam.hg19.counts 1 human_g1k_v37 hg19
    $qcluster -i $tbam.hg19.counts --above $maxgap --below $mingap --names $refGene > $tbam.cluster
    $qcluster -i $nbam.hg19.counts --above $maxgap --below $mingap --names $refGene > $nbam.cluster
    $quandico -s data=$tbam.cluster $t_XY -r data=$nbam.cluster $n_XY -a data=$refGenome -a version=hg19 --no-cluster -d $output_dir -b $output_prefix --cp names=$refGene --rexe /mnt/software/stow/R-3.1.2/bin/R-3.1.2 # the highest R version can be used is 3.1.2
else
    $qcluster -i $tbam.counts --above $maxgap --below $mingap --names $refGene > $tbam.cluster
    $qcluster -i $nbam.counts --above $maxgap --below $mingap --names $refGene > $nbam.cluster
    $quandico -s data=$tbam.cluster $t_XY -r data=$nbam.cluster $n_XY -a data=$refGenome -a version=hg19 --no-cluster -d $output_dir -b $output_prefix --cp names=$refGene --rexe /mnt/software/stow/R-3.1.2/bin/R-3.1.2
fi
