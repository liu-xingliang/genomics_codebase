## GATK HG

lib=$1
refGenome="/mnt/AnalysisPool/libraries/genomes/human_g1k_v37/human_g1k_v37.fa"
dbsnp="/mnt/projects/liuxl/ctso4_projects/liuxl/dbsnp/dbSNP144/GRCh37p13/00-All.vcf.gz"
gatk=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/GATK/GenomeAnalysisTK-3.5/GenomeAnalysisTK.jar
bcftools=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samtools/bcftools-1.3/dist/bin/bcftools

# runlog check, pass
while read lib; do
    qjob=$lib.HC_hardfilter
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
    echo '#$ -l h_rt=48:00:00,mem_free=30G -pe OpenMP 1' >> $uge
    echo '#$ -cwd' >> $uge
    echo 'source /mnt/software/etc/gis.bashrc' >> $uge
    echo 'source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh' >> $uge

    echo java -XX:+UseSerialGC -Xmx20G -jar $gatk -T HaplotypeCaller -R $refGenome -I $lib.sorted.nosecond.RG.IR.BQSR.BAQ.bam -o $lib.raw_variants.vcf --genotyping_mode DISCOVERY --output_mode EMIT_VARIANTS_ONLY --dbsnp $dbsnp -stand_call_conf 30 -stand_emit_conf 10 -dt NONE '>>'$qjob.runlog '2>&1' >> $uge    

    echo java -Xmx10G -XX:+UseSerialGC -jar $gatk -T SelectVariants -R $refGenome -V $lib.raw_variants.vcf -selectType SNP -o $lib.raw_variants.snp.vcf '>>'$qjob.runlog '2>&1' >> $uge
    echo java -Xmx10G -XX:+UseSerialGC -jar $gatk -T VariantFiltration -R $refGenome -V $lib.raw_variants.snp.vcf \
    '-filterName QD -filter "QD < 2.0"' \
    '-filterName MQ -filter "MQ < 40.0"' \
    '-filterName FS -filter "FS > 60.0"' \
    '-filterName MQRankSum -filter "MQRankSum < -12.5"' \
    '-filterName ReadPosRankSum -filter "ReadPosRankSum < -8.0"' \
    -o $lib.snp.filtered.vcf '>>'$qjob.runlog '2>&1' >> $uge
    echo java -Xmx10G -XX:+UseSerialGC -jar $gatk -T SelectVariants -R $refGenome -V $lib.snp.filtered.vcf --excludeFiltered -o $lib.snp.PASS.vcf '>>'$qjob.runlog '2>&1' >> $uge

    echo java -Xmx10G -XX:+UseSerialGC -jar $gatk -T SelectVariants -R $refGenome -V $lib.raw_variants.vcf -selectType INDEL -o $lib.raw_variants.indel.vcf '>>'$qjob.runlog '2>&1' >> $uge
    echo java -Xmx10G -XX:+UseSerialGC -jar $gatk -T VariantFiltration -R $refGenome -V $lib.raw_variants.indel.vcf \
    '-filterName QD -filter "QD < 2.0"' \
    '-filterName FS -filter "FS > 200.0"' \
    '-filterName ReadPosRankSum -filter "ReadPosRankSum < -20.0"' \
    -o $lib.indel.filtered.vcf '>>'$qjob.runlog '2>&1' >> $uge
    echo java -Xmx10G -XX:+UseSerialGC -jar $gatk -T SelectVariants -R $refGenome -V $lib.indel.filtered.vcf --excludeFiltered -o $lib.indel.PASS.vcf '>>'$qjob.runlog '2>&1' >> $uge
    qsub < $uge
done < $libs

while read lib; do

    qjob=$lib.HG.annovar
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
    echo 'source /mnt/software/etc/gis.bashrc' >> $uge
    echo 'source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh' >> $uge

    # avinput
    # uge script generation checked
    echo java -XX:+UseSerialGC -Xmx4G -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/GATK_HG/ GATK_HG_VCF2Avinput $lib.snv.PASS.vcf SNV ' "10:2" "NA" "\t" ":" "," "NA" ' '1>' $lib.HG.snv.avinput '2>>'$qjob.runlog >> $uge # GATK_HG_VCF2Avinput.java is modified from /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/LoFreq_indelovlp_filtervcf_vcf2avinput_annovar/LoFreqVCF2Avinput_lofreq2_1_2.java, checked
    echo java -XX:+UseSerialGC -Xmx4G -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/GATK_HG/ GATK_HG_VCF2Avinput $lib.indel.PASS.vcf INDEL ' "10:2" "NA" "\t" ":" "," "NA" ' '1>' $lib.HG.indel.avinput '2>>'$qjob.runlog >> $uge

    echo perl $annovar_dir/table_annovar.pl -buildver hg19 -remove -outfile ${lib}_HG_SNV -protocol refGene,cytoBand,snp138,snp138NonFlagged,cosmic70,esp6500siv2_all,1000g2015aug_all -operation g,r,f,f,f,f,f -otherinfo $lib.HG.snv.avinput $annovar_dir/humandb/ '>>'$qjob.runlog '2>&1' >> $uge
    echo '{' head -n 1 ${lib}_HG_SNV.hg19_multianno.txt '|' sed -r "'"'s/Otherinfo$/Depth_tumor\tReads_nonref_tumor\tFreq_nonref_tumor\tVar_type/'"'"';' tail -n +2 ${lib}_HG_SNV.hg19_multianno.txt';' '}' '1>' ${lib}_HG_SNV_hg19_multianno.txt '2>>'$qjob.runlog >> $uge

    echo perl $annovar_dir/table_annovar.pl -buildver hg19 -remove -outfile ${lib}_HG_INDEL -protocol refGene,cytoBand,snp138,snp138NonFlagged,cosmic70,esp6500siv2_all,1000g2015aug_all -operation g,r,f,f,f,f,f -otherinfo $lib.HG.indel.avinput $annovar_dir/humandb/ '>>'$qjob.runlog '2>&1' >> $uge
    echo '{' head -n 1 ${lib}_HG_INDEL.hg19_multianno.txt '|' sed -r "'"'s/Otherinfo$/Depth_tumor\tReads_nonref_tumor\tFreq_nonref_tumor\tVar_type/'"'"';' tail -n +2 ${lib}_HG_INDEL.hg19_multianno.txt';' '}' '1>' ${lib}_HG_INDEL_hg19_multianno.txt '2>>'$qjob.runlog >> $uge
    
    qsub < $uge
done < $libs
