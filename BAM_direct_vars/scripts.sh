#!/bin/bash

# input
bam=XXX.bam # this is the only input required

# mpileup variants calling

samtools=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samtools/samtools-1.3/dist/bin/samtools
refGenome=/mnt/AnalysisPool/libraries/genomes/human_g1k_v37/human_g1k_v37.fa

# remove all filter, direct counting indels and snvs from bam
#-A # Do not skip anomalous read pairs in variant calling. 
#-B # Disable probabilistic realignment for the computation of base alignment quality (BAQ)
#-d 1000000 -f $refGenome -l ROI.bed 
#-q 0 -Q 0 
#-x # Disable read-pair overlap detection
#-v -L 1000000 -t DP,AD -u
$samtools mpileup -A -B -d 1000000 -f $refGenome -l ROI.bed -q 0 -Q 0 -x -v -L 1000000 -t DP,AD -u $bam > $bam.samtools.vcf

# annovar
annovar_dir=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/annovar

awk -F"\t" '/^#/ || $8!~/INDEL/' $bam.samtools.vcf > $bam.samtools.SNV.vcf # checked
awk -F"\t" '/^#/ || $8~/INDEL/' $bam.samtools.vcf > $bam.samtools.INDEL.vcf

java -XX:+UseSerialGC -Xmx4G -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/BAM_direct_vars VCF2Avinput $bam.samtools.SNV.vcf SNV "10:3" "NA" "\t" ":" "," "NA" > $bam.samtools.SNV.avinput
java -XX:+UseSerialGC -Xmx4G -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/BAM_direct_vars VCF2Avinput $bam.samtools.INDEL.vcf INDEL "10:3" "NA" "\t" ":" "," "NA" > $bam.samtools.INDEL.avinput

qjob=$bam.annovar
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

# uge script generation checked
echo perl $annovar_dir/table_annovar.pl -buildver hg19 -remove -outfile ${lib}_samtools_SNV -protocol refGene,cytoBand,snp138,snp138NonFlagged,cosmic70,esp6500siv2_all,1000g2015aug_all -operation g,r,f,f,f,f,f -otherinfo $bam.samtools.SNV.avinput $annovar_dir/humandb/ '>>'$qjob.runlog '2>&1' >> $uge
echo '{' head -n 1 ${lib}_samtools_SNV.hg19_multianno.txt '|' sed -r "'"'s/Otherinfo$/Depth_tumor\tReads_nonref_tumor\tFreq_nonref_tumor\tVar_type/'"'"';' tail -n +2 ${lib}_samtools_SNV.hg19_multianno.txt';' '}' '1>' ${lib}_samtools_SNV_hg19_multianno.txt '2>>'$qjob.runlog >> $uge

echo perl $annovar_dir/table_annovar.pl -buildver hg19 -remove -outfile ${lib}_samtools_INDEL -protocol refGene,cytoBand,snp138,snp138NonFlagged,cosmic70,esp6500siv2_all,1000g2015aug_all -operation g,r,f,f,f,f,f -otherinfo $bam.samtools.INDEL.avinput $annovar_dir/humandb/ '>>'$qjob.runlog '2>&1' >> $uge
echo '{' head -n 1 ${lib}_samtools_INDEL.hg19_multianno.txt '|' sed -r "'"'s/Otherinfo$/Depth_tumor\tReads_nonref_tumor\tFreq_nonref_tumor\tVar_type/'"'"';' tail -n +2 ${lib}_samtools_INDEL.hg19_multianno.txt';' '}' '1>' ${lib}_samtools_INDEL_hg19_multianno.txt '2>>'$qjob.runlog >> $uge

qsub < $uge
