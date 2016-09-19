#!/bin/bash

fastq1=$1
fastq2=$2

indexprimer=GATCGGAAGAGCACACGTCTGAACTCCAGTCAC
reversecomplement_read1seqprimer=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
reversecomplement_read2seqprimer=AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC

/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/cutadapt/cutadapt-1.8/bin/cutadapt -a $indexprimer -a $reversecomplement_read2seqprimer -A $reversecomplement_read1seqprimer -o $fastq1.trimseqprimer.fastq.gz -p $fastq2.trimseqprimer.fastq.gz $fastq1 $fastq2 --overlap 30 --mask-adapter
