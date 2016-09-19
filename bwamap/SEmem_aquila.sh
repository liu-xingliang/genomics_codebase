#!/bin/bash

bwa="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/bwa/bwa-0.7.12/bwa"
refGenome="/mnt/AnalysisPool/libraries/genomes/human_g1k_v37/bwa_path/nucleotide/human_g1k_v37.fa"
samtools="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samtools/samtools-1.3/dist/bin/samtools"

while read lib
do
    qjob=$lib.SEmem
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
    echo '#$ -l h_rt=48:00:00,mem_free=10G -pe OpenMP 10' >> $uge
    echo '#$ -cwd' >> $uge
    echo 'source /mnt/software/etc/gis.bashrc' >> $uge
    echo 'source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh' >> $uge
    echo bash SEmem.sh $lib.fastq.gz $lib 10 $bwa $refGenome $samtools '>'$qjob.runlog '2>&1' >> $uge
    qsub < $uge
done < liblist
