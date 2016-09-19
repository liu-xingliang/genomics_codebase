#!/bin/bash

while read f
do
    awk '/^#/ || /INDEL/' $f > $f.indel.vcf
    awk '/^#/ || !/INDEL/' $f > $f.snv.vcf
done < vcflist
