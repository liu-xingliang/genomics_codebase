#!/bin/bash

annovar_dir="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/annovar"
annovar_header=/mnt/projects/liuxl/ctso4_projects/liuxl/scripts/LoFreq_indelovlp_filtervcf_vcf2avinput_annovar/Annovar_header_lofreq2_1_2.txt

vcf=$1
vartype=$2
isindel=$3
Xmx=$4

if [[ $isindel -eq 1 ]] 
then
    /mnt/software/stow/lofreq_star-2.1.2/bin/lofreq2_indel_ovlp.py $vcf > $vcf.indelovlp.vcf
    vcf=$vcf.indelovlp.vcf
fi

if [[ $vartype != "" ]] 
then
    java -Xmx$Xmx -XX:+UseSerialGC -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/LoFreq_indelovlp_filtervcf_vcf2avinput_annovar:. LoFreqVCF2Avinput_lofreq2_1_2 $vcf > $vcf.avinput
    perl $annovar_dir/table_annovar.pl -buildver hg19 -remove -outfile ${vcf}_${vartype} -protocol refGene,ensGene,cytoBand,snp138,snp138NonFlagged,cosmic70,ljb26_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog,esp6500si_all,1000g2012apr_all -operation g,g,r,f,f,f,f,f,r,r,r,r,f,f -otherinfo $vcf.avinput $annovar_dir/humandb/
        
    tail -n +2 ${vcf}_${vartype}.hg19_multianno.txt | cat $annovar_header - > ${vcf}_${vartype}_hg19_multianno.txt
    perl /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/VOGELSTEIN/add_annotations_of_driver_mut.pl ${vcf}_${vartype}_hg19_multianno.txt
else
    printf "please specify which types of variants: snv, indel, allvar\n"
fi
