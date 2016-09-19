#!/bin/bash

lib=$1

while read line
do
    tlib=$(echo $line | cut -d' ' -f1)
    nlib=$(echo $line | cut -d' ' -f2)
    chr=$(echo $line | cut -d' ' -f3)
    pos_start=$(echo $line | cut -d' ' -f4)
    pos_end=$(echo $line | cut -d' ' -f5)
    start=$(( $pos_start - 50 ))
    end=$(( $pos_end + 50 ))

    printf "$line\t"
    bash gcrate_data_ref_singleregion.sh ${tlib}.sorted.addreplacegroup.bam.ovlprefine.bam.rmprimer.bam.indelrealign.baserecal.bam ${chr}:${start}-${end} 1 2>/dev/null 
    printf "\t"
    bash gcrate_data_ref_singleregion.sh ${nlib}.sorted.addreplacegroup.bam.ovlprefine.bam.rmprimer.bam.indelrealign.baserecal.bam ${chr}:${start}-${end} 0 2>/dev/null 
    printf "\n"
done < $lib.coord # can change format accordingly
