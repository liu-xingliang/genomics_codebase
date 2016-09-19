#!/bin/bash

samtools=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samtools/samtools-1.1/bin/samtools
bam=$1
intervals=$2

while read region
do
    chr=$(echo $region | cut -d' ' -f1)
    start=$(echo $region | cut -d' ' -f2)
    end=$(echo $region | cut -d' ' -f3)
    
    arr=($($samtools mpileup -f /mnt/AnalysisPool/libraries/genomes/hg19/hg19.fa -r $chr:${start}-${end} -d 100000 -A -x -Q 0 $bam 2>/dev/null | cut -f4))
    sum=0
    for n in ${arr[@]}
    do
        sum=$(( $sum + $n ))
    done

    if [[ ${#arr[@]} -eq 0 ]]
    then
        avg_cov=0
    else
        avg_cov=$(bc -l <<< $sum/${#arr[@]})
    fi
    echo -e "$chr:${start}-${end}\t$avg_cov"
done < $intervals
  

