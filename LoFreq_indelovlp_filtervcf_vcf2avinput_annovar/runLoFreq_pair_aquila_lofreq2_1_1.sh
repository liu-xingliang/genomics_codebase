#!/bin/bash

lofreq=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/LoFreq/lofreq_star-2.1.1/bin/lofreq
bam_suffix=$2
refGenome=$3
ROI=$4 # if no, use "NA"
dbSNP=$5
mem_free=$6
Xmx=$7
suffix="${8}lofreq2_1_1" # suffix of -o of lofreq
extra_args=$9 # extra arguments for lofreq somatic ("" or something)
vcf2avinput_annovar=/mnt/projects/liuxl/ctso4_projects/liuxl/scripts/github/LoFreq_indelovlp_filtervcf_vcf2avinput_annovar/vcf2avinput_annovar_lofreq2_1_1.sh

while read line
do
    normallib=$(echo $line | cut -d' ' -f2)
    tumourlib=$(echo $line | cut -d' ' -f1)
    normalbam=$normallib.${bam_suffix}
    tumourbam=$tumourlib.${bam_suffix}

    # qjob=${tumourlib}AND${normallib}_lofreq
    qjob=${tumourlib}AND${normallib}${suffix}
    
    uge=$qjob.uge
    [[ -e $uge ]] && rm $uge
    [[ -e $qjob.log ]] && rm $qjob.log
    [[ -e $qjob.err ]] && rm $qjob.err
    [[ -e $qjob.runlog ]] && rm $qjob.runlog
    echo '#!/bin/bash' >> $uge
    echo '#$ -N' $qjob >> $uge
    echo '#$ -o' $qjob.log >> $uge
    echo '#$ -e' $qjob.err >> $uge
    echo '#$ -q medium.q' >> $uge
    echo '#$ -l h_rt=48:00:00,mem_free='$mem_free' -pe OpenMP 1' >> $uge
    echo '#$ -cwd' >> $uge
    echo 'source /mnt/software/etc/gis.bashrc' >> $uge
    echo 'source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh' >> $uge

    command="$lofreq somatic --call-indels -n $normalbam -t $tumourbam -f $refGenome -o ${tumourlib}AND${normallib}${suffix} $extra_args"

    if [[ $ROI != "NA" ]]; then
        command="$command -l $ROI"
    fi

    if [[ $dbSNP != "NA" ]]; then
        command="$command -d $dbSNP"
    fi

    echo $command '>>'$qjob.runlog '2>&1' >> $uge
    
    if [[ $dbSNP != "NA" ]]; then
        echo zcat ${tumourlib}AND${normallib}${suffix}somatic_final_minus-dbsnp.indels.vcf.gz '>' ${tumourlib}AND${normallib}${suffix}somatic_final_minus-dbsnp.indels.vcf '2>>'$qjob.runlog >> $uge
        echo bash $vcf2avinput_annovar ${tumourlib}AND${normallib}${suffix}somatic_final_minus-dbsnp.indels.vcf indels 1 $Xmx '>>'$qjob.runlog '2>&1' >> $uge 
        echo zcat ${tumourlib}AND${normallib}${suffix}somatic_final_minus-dbsnp.snvs.vcf.gz '>' ${tumourlib}AND${normallib}${suffix}somatic_final_minus-dbsnp.snvs.vcf '2>>'$qjob.runlog >> $uge
        echo bash $vcf2avinput_annovar ${tumourlib}AND${normallib}${suffix}somatic_final_minus-dbsnp.snvs.vcf svns 0 $Xmx '>>'$qjob.runlog '2>&1' >> $uge 
    else
        echo zcat ${tumourlib}AND${normallib}${suffix}somatic_final.indels.vcf.gz '>' ${tumourlib}AND${normallib}${suffix}somatic_final.indels.vcf '2>>'$qjob.runlog >> $uge
        echo bash $vcf2avinput_annovar ${tumourlib}AND${normallib}${suffix}somatic_final.indels.vcf indels 1 $Xmx '>>'$qjob.runlog '2>&1' >> $uge 
        echo zcat ${tumourlib}AND${normallib}${suffix}somatic_final.snvs.vcf.gz '>' ${tumourlib}AND${normallib}${suffix}somatic_final.snvs.vcf '2>>'$qjob.runlog >> $uge
        echo bash $vcf2avinput_annovar ${tumourlib}AND${normallib}${suffix}somatic_final.snvs.vcf svns 0 $Xmx '>>'$qjob.runlog '2>&1' >> $uge 
    fi
    
    qsub < $uge 
done < $1 
