#!/bin/bash

samtools="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samtools/samtools-1.1/bin/samtools"
java6="/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/bin/java"
java8="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/java/jdk1.8.0_74/bin/java"
picard="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/picard/picard-tools-2.1.0/picard.jar"

input_bam=$1
Xmx=$2

printf "merging splitted bam\n"
$samtools merge -f -b ${input_bam}_split_bam_list -p -c $input_bam.ovlprefine.bam.rmprimer.bam
printf "resorting merged bam\n"
$java8 -Xmx$Xmx -jar $picard SortSam I=$input_bam.ovlprefine.bam.rmprimer.bam O=$input_bam.ovlprefine.bam.rmprimer.sorted.bam SO=coordinate VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true
mv $input_bam.ovlprefine.bam.rmprimer.sorted.bam $input_bam.ovlprefine.rmprimer.sorted.bam
mv $input_bam.ovlprefine.bam.rmprimer.sorted.bai $input_bam.ovlprefine.rmprimer.sorted.bam.bai 

