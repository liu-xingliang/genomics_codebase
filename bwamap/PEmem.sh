#!/bin/bash

fastq1=$1
fastq2=$2
lib=$3
nthreads=$4
bwa=$5
refGenome=$6
samtools=$7

$bwa mem -M -R "@RG\tID:$lib\tLB:$lib\tPL:illumina\tSM:$lib" -t $nthreads $refGenome $fastq1 $fastq2 | $samtools view -bS - > $lib.bam 
