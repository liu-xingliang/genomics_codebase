#!/bin/bash

# this scripts can be used for all versions of perl_scripts (locusebased and matchprimer)

not_empty_chrlist=$2 #/mnt/projects/liuxl/ctso4_projects/liuxl/SayLi/JCO/lungprimer/not_empty/locusbased_rmprimer/human_g1k_v37_chrlist_not_empty
primer_dir=$3 # /mnt/projects/liuxl/ctso4_projects/liuxl/SayLi/dataquality_2016Apr/BC50_primers/not_empty/locusbased_rmprimer/human_g1k_v37/ 
mem_free=$4
Xmx=$5

perl_scripts=/mnt/projects/liuxl/ctso4_projects/liuxl/scripts/github/ovlp_and_rmprimer_splitchr/ovlp_and_rmprimer_splitchr_locusebased_aquila.pl # need to be changed for different version of perl_scripts 
cp  $perl_scripts .
perl_scripts=$(basename $perl_scripts)

while read bam
do
    [[ ! ( -e ${bam}_d ) ]] && mkdir ${bam}_d
    ln -s $(readlink -f $bam) ${bam}_d 
    ln -s $(readlink -f $bam.bai) ${bam}_d
    cp $perl_scripts ${bam}_d

    cd ${bam}_d

    perl $perl_scripts $bam $mem_free $Xmx \
    $not_empty_chrlist \
    "/mnt/projects/liuxl/ctso4_projects/liuxl/myTools/OverlapBaseRefine.jar" \
    /mnt/projects/liuxl/ctso4_projects/liuxl/myTools/PrimerTrimmer_LocusBased_IndelQual_BAQ.jar \
    $primer_dir \
    "NA" \
    $bam.ovlprefine_rmprimer.jids

    cd -
done < $1 # bamlist
