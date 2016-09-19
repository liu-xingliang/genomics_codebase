#!/bin/bash

fastq=$1
lib=$2
nthreads=$3
bwa=$4
refGenome=$5
samtools=$6

$bwa aln $refGenome $fastq -t $nthreads > $fastq.aln.sai
$bwa samse -r "@RG\tID:$lib\tLB:$lib\tPL:illumina\tSM:$lib" $refGenome $fastq.aln.sai $fastq | $samtools view -bS - > $lib.bam 
