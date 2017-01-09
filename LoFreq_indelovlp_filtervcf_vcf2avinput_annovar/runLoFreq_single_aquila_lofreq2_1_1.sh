#!/bin/bash

lofreq=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/LoFreq/lofreq_star-2.1.1/bin/lofreq

bam_suffix=$2
refGenome=$3
ROI=$4 # if no, use "NA"
dbSNP=$5
mem_free=$6
Xmx=$7
suffix="${8}lofreq2_1_1" # suffix of -o of lofreq
vcf2avinput_annovar=/mnt/projects/liuxl/ctso4_projects/liuxl/scripts/github/LoFreq_indelovlp_filtervcf_vcf2avinput_annovar/vcf2avinput_annovar_lofreq2_1_1.sh

while read lib
do
    bam=${lib}${bam_suffix}
    qjob=${lib}${suffix}
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
    
    command="$lofreq call --call-indels -s -f $refGenome -o $lib${suffix}.vcf --verbose"

    if [[ $ROI != "NA" ]]; then
        command="$command -l $ROI"
    fi

    if [[ $dbSNP != "NA" ]]; then
        command="$command -S $dbSNP"
    fi

    command="$command $bam"

    echo "awk '/^#/ || /INDEL/'" $lib${suffix}.vcf '>' $lib${suffix}.indel.vcf '2>>'$qjob.runlog >>$uge  
    echo "awk '/^#/ || !/INDEL/'" $lib${suffix}.vcf '>' $lib${suffix}.snv.vcf '2>>'$qjob.runlog >>$uge 
    echo bash vcf2avinput_annovar.sh $lib${suffix}.indel.vcf indels 1 $Xmx '>>'$qjob.runlog '2>&1' >> $uge
    echo bash vcf2avinput_annovar.sh $lib${suffix}.snv.vcf snvs 0 $Xmx '>>'$qjob.runlog '2>&1' >> $uge

    qsub < $uge 
done < $1 #single_libs 
