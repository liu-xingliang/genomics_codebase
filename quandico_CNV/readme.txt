# how to use
# NOTE: I did some changes to original scripts -> /mnt/projects/liuxl/ctso4_projects/liuxl/Tools/quandico/readme.txt
1. run run_quandico.sh # note the comments in the scripts 

example:

    refGenome=/mnt/AnalysisPool/libraries/genomes/human_g1k_v37/human_g1k_v37.fa
    export LD_LIBRARY_PATH=/mnt/software/unstowable/root_v5.34.30/lib:/mnt/software/lib:/usr/lib/jvm/jre-1.6.0-sun/lib/amd64/server:/usr/lib/jvm/jre-1.6.0-sun/lib/amd64::/usr/lib64/openmpi/lib/:/opt/sgi/sgimc/lib:/usr/lib64/openmpi/lib/:/mnt/software/unstowable/mosek/6/tools/platform/linux64x86/bin
    while read line
    do
        tlib=
        nlib=
        tbam= 
        nbam=
        tsex=
        nsex=

        qjob=${tlib}_${nlib}_quandico

        # run each quandico in separate folder
        mkdir ${tlib}_${nlib}_quandico
        cp run_quandico.sh ${tlib}_${nlib}_quandico
        ln -s $(readlink -f $tbam) ${tlib}_${nlib}_quandico
        ln -s $(readlink -f $nbam) ${tlib}_${nlib}_quandico
        cd ${tlib}_${nlib}_quandico

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
        echo '#$ -l h_rt=48:00:00,mem_free=8G -pe OpenMP 1' >> $uge
        echo '#$ -cwd' >> $uge
        echo '#$ -V' >> $uge
        echo 'source /mnt/software/etc/gis.bashrc' >> $uge
        echo 'source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh' >> $uge 
        echo bash run_quandico.sh $tbam $nbam $tsex $nsex ${tlib}_${nlib}_quandico_out ${tlib}_${nlib}_quandico /mnt/projects/liuxl/ctso4_projects/liuxl/SayLi/CTC_Proj/amplicons_withprimer_coord_human_g1k_v37.bed /mnt/AnalysisPool/libraries/genomes/hg19/hg19.fa /mnt/projects/liuxl/ctso4_projects/liuxl/Tools/quandico/hg19_refGene.txt  human_g1k_v37 4G 21 12 200 100000 '>>'$qjob.runlog '2>&1' >> $uge
        qsub < $uge

        cd -
    done < colon_tumour_normal_pair
    
2. then, under the same folder of running above scripts, run the following

    quandico_csv=quandico_csv
    mkdir $quandico_csv
    find -mindepth 3 -maxdepth 3 -name "*_quandico.csv" -exec ln -s $(readlink -f "{}") $quandico_csv \;
    cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/quandico_CNV/csv_pickpass_totsv.sh /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/quandico_CNV/passtsv_to_AMP_DEL.awk $quandico_csv
    cd $quandico_csv

    [[ -e <CNVs_info> ]] && rm <CNVs_info>
    while read line; do

        tlib=
        nlib=
        patient=
        tsample= 
        nsample=
        
        bash csv_pickpass_totsv.sh ${tlib}_${nlib}_quandico.csv
        cat ${tlib}_${nlib}_quandico.csv.pass.tsv | ./passtsv_to_AMP_DEL.awk > ${tlib}_${nlib}_quandico.csv.pass.tsv.AMP_DEL
        # chromosome,start,end,locus,amplicons,outliers,usable,expected,log2,copies,min,max,qp,sd,score,p.val,filter
        # patient   chromosome  start   end locus   expected    copies  p.val   filter
        
        awk -F"\t" -v info="$patient\t$tsample\t$tlib\t$nsample\t$nlib" 'BEGIN{OFS="\t"}{print info,$1,$2,$3,$4,$8,$10}' ${tlib}_${nlib}_quandico.csv.pass.tsv >> <CNVs_info>
    done < <tumour_normal_pair>
    
    cd -

3. draw heatmap
# get heatmap input, run under $quandico_csv above
[[ -e <java_in> ]] && rm <java_in>
[[ -e <nameset> ]] && rm <nameset>
while read line; do
    tlib=
    nlib=
    tsample=
    nsample=
    name= #names (libs, samples, or patients) shown on heatmap, can use ${tsample}_VS_${nsample}
    echo $name >>  <nameset>
    #chromosome,start,end,locus,amplicons,outliers,usable,expected,log2,copies,min,max,qp,sd,score,p.val,filter
    awk -F"," -v name="$name" 'NR>1 && $17=="PASS"{print name"\t"$4"\t"$10}' <each_quandico.csv> >> <java_in> # lib<TAB>gene<TAB>copies
done < <tumour_normal>
java -XX:+UseSerialGC -Xmx4G -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/quandico_CNV CNVHeatmapInNoXY <java_in> <nameset> > <heatmap_in>
