#!/bin/bash

while read link
do
    filename=$(echo $link | awk -F"/" '{print $NF}')
    qjob=$filename.wget
    uge=$qjob.uge
    [[ -e $uge ]] && rm $uge
    [[ -e $qjob.log ]] && rm $qjob.log
    [[ -e $qjob.err ]] && rm $qjob.err
    [[ -e $qjob.runlog ]] && rm $qjob.runlog
    echo '#!/bin/bash' >> $uge
    echo '#$ -N' $qjob >> $uge
    echo '#$ -o' $qjob.log >> $uge
    echo '#$ -e' $qjob.err >> $uge
    echo '#$ -q ionode.q' >> $uge
    echo '#$ -l h_rt=48:00:00,mem_free=4G -pe OpenMP 1' >> $uge
    echo '#$ -cwd' >> $uge
    echo 'source /mnt/software/etc/gis.bashrc' >> $uge
    echo 'source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh' >> $uge
    echo wget $link --no-check-certificate >> $uge
    qsub < $uge
done < download_list
