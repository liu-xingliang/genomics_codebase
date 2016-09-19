#!/bin/bash

RNASeQC=/mnt/AnalysisPool/libraries/tools/RNA-SeQC/RNA-SeQC_v1.1.7.jar
lib=$1
bam=$2
Xmx=$3
java -Xmx$Xmx -XX:+UseSerialGC -jar $RNASeQC -n 1000 -s "$lib|$bam|RNASeQC" -t /mnt/AnalysisPool/libraries/genomes/hg19/gtf/hg19_RNASeqQCannotation.gtf -r /mnt/AnalysisPool/libraries/genomes/hg19/bowtie2_path/base/hg19.fa -noDoC -o RNASeqC_output/
