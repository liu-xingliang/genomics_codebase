#!/bin/bash

mem_free=$2
Xmx=$3

merge_scripts=/mnt/projects/liuxl/ctso4_projects/liuxl/scripts/ovlp_and_rmprimer_splitchr/merge.sh
cp $merge_scripts .
merge_scripts=$(basename $merge_scripts)

while read bam
do
    cp $merge_scripts ${bam}_d

    cd ${bam}_d

    hold_jids=$(echo $(cat $bam.ovlprefine_rmprimer.jids) | sed -r 's/  */,/g')
    jids=$bam.merge.jids
    [[ -e $jids ]] && rm $jids

    qjob=${bam}.merge
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
    echo '#$ -hold_jid' $hold_jids >> $uge
    echo 'source /mnt/software/etc/gis.bashrc' >> $uge
    echo 'source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh' >> $uge
    echo bash $merge_scripts $bam $Xmx '>>'$qjob.runlog '2>&1' >> $uge 
    qsub -terse < $uge >> $jids

    cd -
done< $1 # bamlist
