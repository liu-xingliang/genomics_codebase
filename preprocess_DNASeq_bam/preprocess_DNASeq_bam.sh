
## preprocess
bam=$1
lib=$2
sample=$3
Xmx=$4
sorted=$5 # 1 means sorted
ROI=$6 # if NA, use null
deep=$7 # if 1, deep sequencing, remove downsampling in RTC, IR, DOC 
MD=$8 # if 1, mark duplicates
BAQ=$9 # if 1, do BAQ
DOC=$10 # if 1, do DOC

gatk=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/GATK/GenomeAnalysisTK-3.5/GenomeAnalysisTK.jar
java="java -XX:+UseSerialGC -Xmx$Xmx"
java6="/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/bin/java -XX:+UseSerialGC -Xmx$Xmx"
java8="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/java/jdk1.8.0_74/bin/java -XX:+UseSerialGC -Xmx$Xmx"
picard="/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/picard/picard-tools-2.1.0/picard.jar"

# ## human_g1k_v37 version
# refGenome="/mnt/AnalysisPool/libraries/genomes/human_g1k_v37/human_g1k_v37.fa"
# known_indel_file1="/mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/resource_bundle/1000G_phase1.indels.b37.vcf"
# known_indel_file2="/mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/resource_bundle/Mills_and_1000G_gold_standard.indels.b37.vcf"
# dbsnp_file="/mnt/projects/liuxl/ctso4_projects/liuxl/dbsnp/dbSNP144/GRCh37p13/00-All.vcf"

## hg19noUn version
refGenome="/mnt/AnalysisPool/libraries/genomes/hg19/hg19.fa"
known_indel_file1="/mnt/projects/liuxl/ctso4_projects/liuxl/GATK_resource_bundle/hg19_noUn/1000G_phase1.indels.hg19.vcf"
known_indel_file2="/mnt/projects/liuxl/ctso4_projects/liuxl/GATK_resource_bundle/hg19_noUn/Mills_and_1000G_gold_standard.indels.hg19.vcf"
dbsnp_file="/mnt/projects/liuxl/ctso4_projects/liuxl/dbsnp/dbSNP144/hg19_noUn/00-All.hg19noUn.vcf"

# ## hg19 version
# refGenome="/mnt/genomeDB/genomeIndices/hg19/picard_index/hg19.fa"
# known_indel_file1="/mnt/projects/liuxl/ctso4_projects/liuxl/GATK_resource_bundle/hg19/1000G_phase1.indels.hg19.vcf"
# known_indel_file2="/mnt/projects/liuxl/ctso4_projects/liuxl/GATK_resource_bundle/hg19/Mills_and_1000G_gold_standard.indels.hg19.vcf"
# dbsnp_file="/mnt/projects/liuxl/ctso4_projects/liuxl/dbsnp/dbSNP144/hg19/All.hg19.vcf"

samtools=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samtools/samtools-1.3/dist/bin/samtools
samstat=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samstat/samstat-1.5.1/bin/samstat

if [[ $sorted -ne 1 ]]; then
    #$java6 -jar $picard SortSam I=$bam O=$(echo $bam | sed -r 's/bam$/sorted.bam/') VALIDATION_STRINGENCY=SILENT SO=coordinate CREATE_INDEX=true
    echo $java8 -jar $picard SortSam I=$bam O=$(echo $bam | sed -r 's/bam$/sorted.bam/') VALIDATION_STRINGENCY=SILENT SO=coordinate CREATE_INDEX=true
    $java8 -jar $picard SortSam I=$bam O=$(echo $bam | sed -r 's/bam$/sorted.bam/') VALIDATION_STRINGENCY=SILENT SO=coordinate CREATE_INDEX=true

    bam=$(echo $bam | sed -r 's/bam$/sorted.bam/')

    echo mv $(echo $bam | sed -r 's/bam$/bai/') $bam.bai
    mv $(echo $bam | sed -r 's/bam$/bai/') $bam.bai
fi

echo $samtools flagstat $bam '>' $bam.flagstat # to check the secondary alignment proportion
$samtools flagstat $bam > $bam.flagstat # to check the secondary alignment proportion

echo $samtools view -h -F 0x100 $bam '|' samtools view -bS - '>' $(echo $bam | sed -r 's/bam$/nosecond.bam/')
$samtools view -h -F 0x100 $bam | samtools view -bS - > $(echo $bam | sed -r 's/bam$/nosecond.bam/')

bam=$(echo $bam | sed -r 's/bam$/nosecond.bam/')

echo $java8 -jar $picard BuildBamIndex I=$bam O=$bam.bai VALIDATION_STRINGENCY=SILENT
$java8 -jar $picard BuildBamIndex I=$bam O=$bam.bai VALIDATION_STRINGENCY=SILENT

if [[ $MD -eq 1 ]]; then
    #$java6 -jar $picard MarkDuplicates I=$bam O=$(echo $bam | sed -r 's/bam$/MD.bam/') M=${bam}.metric REMOVE_DUPLICATES=FALSE VALIDATION_STRINGENCY=SILENT
    echo $java8 -jar $picard MarkDuplicates I=$bam O=$(echo $bam | sed -r 's/bam$/MD.bam/') M=${bam}.metric REMOVE_DUPLICATES=FALSE VALIDATION_STRINGENCY=SILENT
    $java8 -jar $picard MarkDuplicates I=$bam O=$(echo $bam | sed -r 's/bam$/MD.bam/') M=${bam}.metric REMOVE_DUPLICATES=FALSE VALIDATION_STRINGENCY=SILENT
    
    bam=$(echo $bam | sed -r 's/bam$/MD.bam/')
fi

#$java6 -jar $picard AddOrReplaceReadGroups I=$bam O=$(echo $bam | sed -r 's/bam$/RG.bam/') RGID=${lib} RGLB=${lib} RGPU=PU_${lib} RGSM=$sample RGPL=illumina VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true
echo $java8 -jar $picard AddOrReplaceReadGroups I=$bam O=$(echo $bam | sed -r 's/bam$/RG.bam/') RGID=${lib} RGLB=${lib} RGPU=PU_${lib} RGSM=$sample RGPL=illumina VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true
$java8 -jar $picard AddOrReplaceReadGroups I=$bam O=$(echo $bam | sed -r 's/bam$/RG.bam/') RGID=${lib} RGLB=${lib} RGPU=PU_${lib} RGSM=$sample RGPL=illumina VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true

bam=$(echo $bam | sed -r 's/bam$/RG.bam/')

echo mv $(echo $bam | sed -r 's/bam$/bai/') $bam.bai
mv $(echo $bam | sed -r 's/bam$/bai/') $bam.bai

if [[ $ROI == "null" ]]; then
    if [[ $deep -eq 1 ]]; then
        echo $java -jar $gatk -T RealignerTargetCreator -R $refGenome -I $bam -o $lib.forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2 -dt NONE
        $java -jar $gatk -T RealignerTargetCreator -R $refGenome -I $bam -o $lib.forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2 -dt NONE
    else
        echo $java -jar $gatk -T RealignerTargetCreator -R $refGenome -I $bam -o $lib.forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2
        $java -jar $gatk -T RealignerTargetCreator -R $refGenome -I $bam -o $lib.forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2
    fi
else
    if [[ $deep -eq 1 ]]; then
        echo $java -jar $gatk -T RealignerTargetCreator -R $refGenome -I $bam -o $lib.forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2 -L $ROI -dt NONE
        $java -jar $gatk -T RealignerTargetCreator -R $refGenome -I $bam -o $lib.forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2 -L $ROI -dt NONE
    else
        echo $java -jar $gatk -T RealignerTargetCreator -R $refGenome -I $bam -o $lib.forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2 -L $ROI
        $java -jar $gatk -T RealignerTargetCreator -R $refGenome -I $bam -o $lib.forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2 -L $ROI
    fi
    
fi

if [[ $deep -eq 1 ]]; then
    echo $java -jar $gatk -T IndelRealigner -R $refGenome -I $bam -targetIntervals $lib.forIndelRealigner.intervals -o $(echo $bam | sed -r 's/bam$/IR.bam/') -known $known_indel_file1 -known $known_indel_file2 -maxReads 1000000
    $java -jar $gatk -T IndelRealigner -R $refGenome -I $bam -targetIntervals $lib.forIndelRealigner.intervals -o $(echo $bam | sed -r 's/bam$/IR.bam/') -known $known_indel_file1 -known $known_indel_file2 -maxReads 1000000
else
    echo $java -jar $gatk -T IndelRealigner -R $refGenome -I $bam -targetIntervals $lib.forIndelRealigner.intervals -o $(echo $bam | sed -r 's/bam$/IR.bam/') -known $known_indel_file1 -known $known_indel_file2
    $java -jar $gatk -T IndelRealigner -R $refGenome -I $bam -targetIntervals $lib.forIndelRealigner.intervals -o $(echo $bam | sed -r 's/bam$/IR.bam/') -known $known_indel_file1 -known $known_indel_file2
fi


bam=$(echo $bam | sed -r 's/bam$/IR.bam/')

if [[ $ROI == "null" ]]; then
    echo $java -jar $gatk -T BaseRecalibrator -I ${bam} -R $refGenome -knownSites $known_indel_file1 -knownSites $known_indel_file2 -knownSites $dbsnp_file -o ${lib}.recal_data.table
    $java -jar $gatk -T BaseRecalibrator -I ${bam} -R $refGenome -knownSites $known_indel_file1 -knownSites $known_indel_file2 -knownSites $dbsnp_file -o ${lib}.recal_data.table
else
    echo $java -jar $gatk -T BaseRecalibrator -I ${bam} -R $refGenome -knownSites $known_indel_file1 -knownSites $known_indel_file2 -knownSites $dbsnp_file -o ${lib}.recal_data.table -L $ROI
    $java -jar $gatk -T BaseRecalibrator -I ${bam} -R $refGenome -knownSites $known_indel_file1 -knownSites $known_indel_file2 -knownSites $dbsnp_file -o ${lib}.recal_data.table -L $ROI
fi

echo $java -jar $gatk -T PrintReads -R $refGenome -o $(echo $bam | sed -r 's/bam$/BQSR.bam/') -I ${bam} -BQSR ${lib}.recal_data.table -baq RECALCULATE

if [[ $BAQ -eq 1 ]]; then
    $java -jar $gatk -T PrintReads -R $refGenome -o $(echo $bam | sed -r 's/bam$/BQSR.bam/') -I ${bam} -BQSR ${lib}.recal_data.table -baq RECALCULATE
    bam=$(echo $bam | sed -r 's/bam$/BQSR.bam/')

    echo $samtools calmd -Abr $bam $refGenome '>' $(echo $bam | sed -r 's/bam$/BAQ.bam/')
    $samtools calmd -Abr $bam $refGenome > $(echo $bam | sed -r 's/bam$/BAQ.bam/')
    
    bam=$(echo $bam | sed -r 's/bam$/BAQ.bam/')
else
    $java -jar $gatk -T PrintReads -R $refGenome -o $(echo $bam | sed -r 's/bam$/BQSR.bam/') -I ${bam} -BQSR ${lib}.recal_data.table
    bam=$(echo $bam | sed -r 's/bam$/BQSR.bam/')
fi

#$samtools index $bam
#$java6 -jar $picard BuildBamIndex I=$bam O=$bam.bai VALIDATION_STRINGENCY=SILENT
echo $java8 -jar $picard BuildBamIndex I=$bam O=$bam.bai VALIDATION_STRINGENCY=SILENT
$java8 -jar $picard BuildBamIndex I=$bam O=$bam.bai VALIDATION_STRINGENCY=SILENT

echo $samstat $bam # to check MAPQ proportion
$samstat $bam # to check MAPQ proportion

if [[ $DOC -eq 1 ]]; then
    if [[ $ROI == "null" ]]; then
        if [[ $deep -eq 1 ]]; then
            echo $java -jar $gatk -T DepthOfCoverage -I $bam -o $bam.DOC -R $refGenome -dt NONE
            $java -jar $gatk -T DepthOfCoverage -I $bam -o $bam.DOC -R $refGenome -dt NONE
        else
            echo $java -jar $gatk -T DepthOfCoverage -I $bam -o $bam.DOC -R $refGenome 
            $java -jar $gatk -T DepthOfCoverage -I $bam -o $bam.DOC -R $refGenome 
        fi
    else
        if [[ $deep -eq 1 ]]; then
            echo $java -jar $gatk -T DepthOfCoverage -I $bam -o $bam.DOC -R $refGenome -L $ROI -dt NONE
            $java -jar $gatk -T DepthOfCoverage -I $bam -o $bam.DOC -R $refGenome -L $ROI -dt NONE
        else
            echo $java -jar $gatk -T DepthOfCoverage -I $bam -o $bam.DOC -R $refGenome -L $ROI
            $java -jar $gatk -T DepthOfCoverage -I $bam -o $bam.DOC -R $refGenome -L $ROI
        fi
    fi
fi
