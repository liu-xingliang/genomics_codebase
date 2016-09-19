#!/bin/bash

fastq1=$1
lib=$2
nthreads=$3
bwa=$4
refGenome=$5
samtools=$6

$bwa mem -M -R "@RG\tID:$lib\tLB:$lib\tPL:illumina\tSM:$lib" -t $nthreads $refGenome $fastq1 | $samtools view -bS - > $lib.bam 
