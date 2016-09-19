#!/bin/bash

wd=/mnt/projects/liuxl/ctso4_projects/liuxl/SayLi/CTC_Proj/Final_DataSet_2015Apr/LoFreq_error0.2_changemate_bugfix_2015Apr21/2014Apr22_indelrealign_baserecal_finished/somatic
while read runlog
do
    cd $wd

    # delete job if it is still running
    qjob=$(echo $runlog | sed -r 's/\.runlog$//')
    qdel $qjob
    sleep 5

    # remove log
    rm $(echo $runlog | sed 's/runlog$/log/')
    rm $(echo $runlog | sed 's/runlog$/err/')
    rm $runlog

    # remove result
    pair=$(echo $runlog | cut -d'_' -f1)
    uge=$(echo $runlog | sed 's/runlog$/uge/')
    mv $uge rerun_$uge
    rm $pair*

    # resubmit
    qsub < rerun_$uge
done < error_runlog
