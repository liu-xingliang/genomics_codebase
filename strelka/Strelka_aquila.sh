#!/bin/bash

refGenome=/mnt/AnalysisPool/libraries/genomes/hg19/hg19.fa

while read line
do
    tumourlib=$(echo $line | cut -d' ' -f1)
    normallib=$(echo $line | cut -d' ' -f2)
    tumourbam=$tumourlib.sorted.addreplacegroup.bam.indelrealign.baserecal.bam.ovlprefine.bam.rmprimer.bam
    normalbam=$normallib.sorted.addreplacegroup.bam.indelrealign.baserecal.bam.ovlprefine.bam.rmprimer.bam
    qjob=${tumourlib}_${normallib}_strelka_annovar

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
    echo '#$ -l h_rt=48:00:00,mem_free=4G -pe OpenMP 1' >> $uge
    echo '#$ -cwd' >> $uge
    echo 'source /mnt/software/etc/gis.bashrc' >> $uge
    echo 'source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh' >> $uge 
    echo 'bash Strelka.sh' $normalbam $tumourbam $normallib $tumourlib $refGenome '>' $qjob.runlog '2>&1' >> $uge
    qsub < $uge
done < $1
