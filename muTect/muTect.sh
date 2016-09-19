tbam=$1
nbam=$2
tlib=$3
nlib=$4
Xmx=$5

refGenome="/mnt/AnalysisPool/libraries/genomes/hg19/hg19.fa"
ROI="/mnt/projects/liuxl/ctso4_projects/liuxl/rnaseq_SNV/SeqCap_target_hg19.bed"
mutect="/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/bin/java -XX:+UseSerialGC -Xmx$Xmx -jar /mnt/projects/liuxl/ctso4_projects/liuxl/Tools/muTect/muTect-1.1.4/muTect-1.1.4.jar"
annovar_dir="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/annovar"
cosmic="/mnt/projects/liuxl/ctso4_projects/liuxl/cosmic/Cosmic70_hg19_noUn.vcf"
dbsnp="/mnt/projects/liuxl/ctso4_projects/liuxl/dbsnp/dbSNPv138_00-All_hg19_noUn.vcf"

$mutect --analysis_type MuTect --cosmic $cosmic --dbsnp $dbsnp --intervals $ROI --enable_extended_output --reference_sequence $refGenome --input_file:normal $nbam --input_file:tumor $tbam --out ${tlib}_${nlib}.mutect.out --vcf ${tlib}_${nlib}.mutect.vcf

tail -n +3 ${tlib}_${nlib}.mutect.out | awk '/KEEP/' > ${tlib}_${nlib}.mutect.keep
awk -F "\t" '{print $1"\t"$2"\t"$2"\t"$4"\t"$5"\t"$3"\t"$24"\t"$29"\t"$30"\t"$40"\t"$47"\t"$48"\t?"}' ${tlib}_${nlib}.mutect.keep > ${tlib}_${nlib}.mutect.avinput

perl $annovar_dir/table_annovar.pl -buildver hg19 -remove -outfile ${tlib}_${nlib}.mutect.SNV -protocol refGene,ensGene,snp138,snp138NonFlagged,cosmic70,esp6500siv2_all,1000g2015aug -operation g,g,f,f,f,f,f -otherinfo ${tlib}_${nlib}.mutect.avinput $annovar_dir/humandb/

#perl /mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/scripts/add_annotations_of_driver_mut.pl ${tlib}_${nlib}.mutect.SNV.hg19_multianno.txt

