#!/bin/bash

normalbam=$1
tumourbam=$2
normallib=$3
tumourlib=$4
refGenome=$5 #"/mnt/AnalysisPool/libraries/genomes/hg19/hg19.fa"

strelka_dir=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/Strelka/strelka_workflow-1.0.14/
annovar_dir="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/annovar"

# # exome seq
# my_strelka_config_bwa=/mnt/projects/liuxl/ctso4_projects/liuxl/scripts/strelka/my_strelka_config_bwa.exon 
# perl $strelka_dir/dist/bin/configureStrelkaWorkflow.pl --normal=$normalbam --tumor=$tumourbam --ref=$refGenome --config=$my_strelka_config_bwa --output-dir=${tumourlib}_${normallib}_strelka
# cd ${tumourlib}_${normallib}_strelka
# make -j 1 
# cd -

# deep seq
my_strelka_config_bwa=/mnt/projects/liuxl/ctso4_projects/liuxl/scripts/strelka/my_strelka_config_bwa.deepseq 
perl $strelka_dir/dist/bin/configureStrelkaWorkflow.pl --normal=$normalbam --tumor=$tumourbam --ref=$refGenome --config=$my_strelka_config_bwa --output-dir=${tumourlib}_${normallib}_strelka
cd ${tumourlib}_${normallib}_strelka
make -j 1 
cd -

## INDEL

# no filter
# coordinates DP1(NORMAL) TIR1(NORMAL) TIR1(NORMAL)/DP1(NORMAL) DP1(TUMOR) TIR1(TUMOR) TIR1(TUMOR)/DP1(TUMOR)
perl ${annovar_dir}/convert2annovar.pl --format vcf4old -includeinfo -withzyg ${tumourlib}_${normallib}_strelka/results/passed.somatic.indels.vcf > ${tumourlib}_${normallib}_somaticindel_raw.avinput

# old implementation
#awk 'BEGIN{FS=",|:|\t"}{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$23"\t"$27"\t"($27/$23)"\t"$34"\t"$38"\t"($38/$34)}' ${tumourlib}_${normallib}_somaticindel_raw.avinput > ${tumourlib}_${normallib}_somaticindel.avinput

while read line
do
    dp1_normal=$(echo $line | cut -d' ' -f16 | cut -d':' -f1)
    tir1_normal=$(echo $line | cut -d' ' -f16 | cut -d':' -f4 | cut -d',' -f1)
    dp1_tumour=$(echo $line | cut -d' ' -f17 | cut -d':' -f1)
    tir1_tumour=$(echo $line | cut -d' ' -f17 | cut -d':' -f4 | cut -d',' -f1)
    echo $line | awk -v dp1_normal="$dp1_normal" -v tir1_normal="$tir1_normal" -v dp1_tumour="$dp1_tumour" -v tir1_tumour="$tir1_tumour" 'BEGIN{FS=" ";OFS="\t"}{print $1,$2,$3,$4,$5,dp1_normal,tir1_normal,tir1_normal/dp1_normal,dp1_tumour,tir1_tumour,tir1_tumour/dp1_tumour}'
done < ${tumourlib}_${normallib}_somaticindel_raw.avinput > ${tumourlib}_${normallib}_somaticindel.avinput

perl $annovar_dir/table_annovar.pl -buildver hg19 -remove -outfile ${tumourlib}_${normallib}_INDEL -protocol refGene,ensGene,cytoBand,snp138,snp138NonFlagged,cosmic70,ljb26_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog,esp6500si_all,1000g2012apr_all -operation g,g,r,f,f,f,f,r,r,r,r,f,f -otherinfo ${tumourlib}_${normallib}_somaticindel.avinput $annovar_dir/humandb/
tail -n +2 ${tumourlib}_${normallib}_INDEL.hg19_multianno.txt | cat $annovar_dir/Annovar_strelka_header.txt - > ${tumourlib}_${normallib}_INDEL_hg19_multianno.txt
perl /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/VOGELSTEIN/add_annotations_of_driver_mut.pl ${tumourlib}_${normallib}_INDEL_hg19_multianno.txt

## SNV
perl ${annovar_dir}/convert2annovar.pl --format vcf4old -includeinfo -withzyg ${tumourlib}_${normallib}_strelka/results/passed.somatic.snvs.vcf > ${tumourlib}_${normallib}_somaticsnv_raw.avinput

while read line
do
    alt=$(echo $line | cut -d' ' -f5)

    normal_DP=$(echo $line | cut -d' ' -f16 | cut -d':' -f1)
    normal_FDP=$(echo $line | cut -d' ' -f16 | cut -d':' -f2)
    dp1_normal=$(( $normal_DP - $normal_FDP ))
    normal_AU=$(echo $line | cut -d' ' -f16 | cut -d':' -f5 | cut -d',' -f1)
    normal_CU=$(echo $line | cut -d' ' -f16 | cut -d':' -f6 | cut -d',' -f1)
    normal_GU=$(echo $line | cut -d' ' -f16 | cut -d':' -f7 | cut -d',' -f1)
    normal_TU=$(echo $line | cut -d' ' -f16 | cut -d':' -f8 | cut -d',' -f1)
    
    tumour_DP=$(echo $line | cut -d' ' -f17 | cut -d':' -f1)
    tumour_FDP=$(echo $line | cut -d' ' -f17 | cut -d':' -f2)
    dp1_tumour=$(( $tumour_DP - $tumour_FDP ))
    tumour_AU=$(echo $line | cut -d' ' -f17 | cut -d':' -f5 | cut -d',' -f1)
    tumour_CU=$(echo $line | cut -d' ' -f17 | cut -d':' -f6 | cut -d',' -f1)
    tumour_GU=$(echo $line | cut -d' ' -f17 | cut -d':' -f7 | cut -d',' -f1)
    tumour_TU=$(echo $line | cut -d' ' -f17 | cut -d':' -f8 | cut -d',' -f1)   
    
    if [[ $alt == "a" || $alt == "A" ]]
    then
        tir1_normal=$normal_AU;
        tir1_tumour=$tumour_AU;
    elif [[ $alt == "c" || $alt == "C" ]]
    then
        tir1_normal=$normal_CU;
        tir1_tumour=$tumour_CU;
    elif [[ $alt == "g" || $alt == "G" ]]
    then
        tir1_normal=$normal_GU;
        tir1_tumour=$tumour_GU;
    elif [[ $alt == "t" || $alt == "T" ]]
    then
        tir1_normal=$normal_TU;
        tir1_tumour=$tumour_TU;
    fi
    
    echo $line | awk -v dp1_normal="$dp1_normal" -v tir1_normal="$tir1_normal" -v dp1_tumour="$dp1_tumour" -v tir1_tumour="$tir1_tumour" 'BEGIN{FS=" ";OFS="\t"}{print $1,$2,$3,$4,$5,dp1_normal,tir1_normal,tir1_normal/dp1_normal,dp1_tumour,tir1_tumour,tir1_tumour/dp1_tumour}'
done < ${tumourlib}_${normallib}_somaticsnv_raw.avinput > ${tumourlib}_${normallib}_somaticsnv.avinput

perl $annovar_dir/table_annovar.pl -buildver hg19 -remove -outfile ${tumourlib}_${normallib}_SNV -protocol refGene,ensGene,cytoBand,snp138,snp138NonFlagged,osmic70,ljb26_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog,esp6500si_all,1000g2012apr_all -operation g,g,r,f,f,f,f,r,r,r,r,f,f -otherinfo ${tumourlib}_${normallib}_somaticsnv.avinput $annovar_dir/humandb/
tail -n +2 ${tumourlib}_${normallib}_SNV.hg19_multianno.txt | cat $annovar_dir/Annovar_strelka_header.txt - > ${tumourlib}_${normallib}_SNV_hg19_multianno.txt
perl /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/VOGELSTEIN/add_annotations_of_driver_mut.pl ${tumourlib}_${normallib}_SNV_hg19_multianno.txt
