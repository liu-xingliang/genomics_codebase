#!/bin/bash

bam=$1
primers_intervals_dir=$2
for f in $primers_intervals_dir/*.intervals
do
    intervals=$(basename $f)
    qjob=$bam.$intervals.DOC
    uge=$qjob.uge
    [[ -e $uge ]] && rm $uge
    echo '#!/bin/bash' >> $uge
    echo '#$ -N' $qjob >> $uge
    echo '#$ -o' $qjob.log >> $uge
    echo '#$ -e' $qjob.err >> $uge
    echo '#$ -q medium.q' >> $uge
    echo '#$ -l h_rt=48:00:00,mem_free=4G -pe OpenMP 1' >> $uge
    echo '#$ -cwd' >> $uge
    echo 'source /mnt/software/etc/gis.bashrc' >> $uge
    echo 'source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh' >> $uge
    echo bash samtools_mpileup_coverage.sh $bam $primers_intervals_dir/$intervals '>' $bam.$intervals.DOC '2>'$qjob.runlog >>$uge
    qsub < $uge 
done
