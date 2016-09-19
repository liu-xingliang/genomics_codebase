#!/bin/bash

lofreq="/mnt/software/stow/lofreq_star-2.1.2/bin/lofreq"
GATK=/mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar
refGenome=/mnt/AnalysisPool/libraries/genomes/hg19/hg19.fa
bam=$1
region=$2 # "chr:start-end"
istumour=$3

chr=$(echo $region | cut -d':' -f1)
start=$(echo $region | cut -d':' -f2 | cut -d'-' -f1)
end=$(echo $region | cut -d':' -f2 | cut -d'-' -f2)

if [[ ! ( -e $bam.${chr}_${start}_${end}.data.gcrate ) ]] 
then
    if [[ $istumour -eq 1 ]]
    then
        $lofreq call -f $refGenome --plp-summary-only -r $chr:${start}-${end} $bam | grep -iE "^$chr\s" >$bam.${chr}_${start}_${end}.lofreqplp
    else
        $lofreq call -f $refGenome --plp-summary-only -r $chr:${start}-${end} --use-orphan -B -N -A $bam | grep -iE "^$chr\s" >$bam.${chr}_${start}_${end}.lofreqplp
    fi

    java -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/lofreqvar_gcrate_data_ref:. GCContentLoFreqPlp $bam.${chr}_${start}_${end}.lofreqplp > $bam.${chr}_${start}_${end}.data.gcrate
fi

data_gcrate=$(cat $bam.${chr}_${start}_${end}.data.gcrate)

[[ ! ( -e ${chr}_${start}_${end}.ref.gcrate ) ]] && java -jar -Xmx4G $GATK -T GCContentByInterval -R $refGenome -L $region -o ${chr}_${start}_${end}.ref.gcrate 

ref_gcrate=$(cut -f2 ${chr}_${start}_${end}.ref.gcrate) # region\tgcrate

printf "$data_gcrate\t$ref_gcrate"
