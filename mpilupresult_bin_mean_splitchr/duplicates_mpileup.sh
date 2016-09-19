#!/bin/bash

bam=$1

# first need to remove duplicate flag
java -XX:+UseSerialGC -Xmx30G -jar /mnt/projects/liuxl/ctso4_projects/liuxl/Tools/picard/picard-tools-1.111/RevertSam.jar INPUT=$bam OUTPUT=$bam.reverted.bam SO=coordinate RESTORE_ORIGINAL_QUALITIES=false REMOVE_DUPLICATE_INFORMATION=true REMOVE_ALIGNMENT_INFORMATION=false SANITIZE=false
/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samtools/samtools-1.1/bin/samtools index $bam.reverted.bam
/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samtools/samtools-1.1/bin/samtools mpileup -A -d 1000000 -q 0 -Q 13 --output $bam.reverted.bam.mpileup $bam.reverted.bam
