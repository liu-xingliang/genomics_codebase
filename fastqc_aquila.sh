#!/bin/bash

fastqc=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/FastQC/FastQC_v0.11.4/fastqc
while read fastq
do
    qjob=$fastq.fastqc
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
    echo $fastqc -f fastq --extract -t 1 $fastq '>>'$qjob.runlog '2>&1' >> $uge # no need to extract gz file in advance
    qsub < $uge
done < fastq_list
