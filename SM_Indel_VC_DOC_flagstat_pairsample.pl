#!usr/bin/perl

use Getopt::Long;
use warnings;
use strict;
use Parallel::ForkManager;

### Tools ###
my $picard_dir = "java -XX:ConcGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelGCThreads=8 -jar -Xmx10g /mnt/AnalysisPool/libraries/tools/picard/picard-tools-1.111";
my $gatk_dir = "java -XX:ConcGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelGCThreads=8 -jar -Xmx10g /mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/GenomeAnalysisTK.jar";
my $refGenome = "/mnt/AnalysisPool/libraries/genomes/human_g1k_v37/human_g1k_v37.fa";
my $known_indel_file1 = "/mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/resource_bundle/1000G_phase1.indels.b37.vcf";
my $known_indel_file2 = "/mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/resource_bundle/Mills_and_1000G_gold_standard.indels.b37.vcf";
my $seqCap_file = "/mnt/userArchive/liuxl/SeqCap_file/SeqCap_target_1000genome.bed"; #/mnt/AnalysisPool/libraries/SNV_pipeline/ROI/SeqCap_EZ_Exome_v3_primary_1000G.intervals
my $mutect_path = "/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/bin/java -XX:ConcGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelGCThreads=8 -Xmx10g -jar /mnt/AnalysisPool/libraries/tools/mutect/muTect-1.1.4.jar";
#my $mutect_path = "/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/bin/java -XX:ConcGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ParallelGCThreads=8 -jar /mnt/lung_cancer_patrick_cgi/TCR/krishnanvg/pipeline/mutect/muTect-1.1.4.jar";
my $annovar_dir="/mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/Tools/annovar";
#my $annovar_dir="/mnt/lung_cancer_patrick_cgi/TCR/Tools/annovar";

## make symbol link
#my $cosmic_file = "/mnt/userArchive/liuxl/cosmic/b37_cosmic_v54_120711.vcf";
#my $dbsnp_file = "/mnt/userArchive/liuxl/dbsnp/dbsnp_132_b37.leftAligned.vcf";
my $cosmic_file = "/mnt/userArchive/liuxl/cosmic/Cosmicv67_b37.vcf";
my $dbsnp_file = "/mnt/userArchive/liuxl/dbsnp/dbSNPv138_00-All.vcf";

#TODO
#my $overwrite = 1;      # Overwrite mode: 0 - do not overwrite; 1 - overwrite all existing data;

### Command Line Arguments ###
my (
    $workspace, 
    $normal_bam,
    $tumour_bam,
    $runMode,        # Run mode: 0 for debug mode (not execute actual command); 1 for executable mode.
);

GetOptions(
    "workspace=s" => \$workspace,
    "normal=s" => \$normal_bam,
    "tumour=s" => \$tumour_bam,	
    "run=i" => \$runMode,
) or die "Errors in command line arugments!";

### Paralle ###
my $MAX_PROCESSES = 40;         # Total number of processes to be allocated to this workflow
my $parallel_manager = new Parallel::ForkManager(int($MAX_PROCESSES));

### Others ###
my $recal_suffix = "_reAligned_reCal.bam";
my $mutect_out = "${workspace}/mutect";
my $DOC_out = "${workspace}/DOC"; 
my $strelka_out = "${workspace}/strelka";

### Mark Duplicates, Add Read Group and Build Index of result bam file###
&begin_("SortBam, MarkDuplicates, AddOrReplaceReadGroups, BuildBamIndex");
##normal
{
    my $pid = $parallel_manager->start and next;
    my $bam = $normal_bam;
    ## just because the original so-called "sorted" bam is unsorted!
    run_cmd("$picard_dir/SortSam.jar I=$bam O=${bam}.sorted.bam SO=coordinate VALIDATION_STRINGENCY=SILENT");
    run_cmd("$picard_dir/BuildBamIndex.jar I=${bam}.sorted.bam O=${bam}.sorted.bam.bai VALIDATION_STRINGENCY=SILENT");
    $bam = "${bam}.sorted.bam"; 
    run_cmd("$picard_dir/MarkDuplicates.jar I=$bam O=${bam}.mark_duplicates.bam M=${bam}.metric REMOVE_DUPLICATES=FALSE VALIDATION_STRINGENCY=SILENT");
    (my $lib = $bam) =~ s/\.bam$//; # read group info
    run_cmd("$picard_dir/AddOrReplaceReadGroups.jar I=${bam}.mark_duplicates.bam O=${bam}.addreplacegroup.bam SO=coordinate RGID=${lib}.bam RGLB=LB_${lib}.bam RGPU=PU_${lib} RGSM=SM_${lib} RGCN=CN_${lib} RGDS=DS_${lib} RGPL=illumina VALIDATION_STRINGENCY=SILENT");
    run_cmd("$picard_dir/BuildBamIndex.jar I=${bam}.addreplacegroup.bam O=${bam}.addreplacegroup.bam.bai VALIDATION_STRINGENCY=SILENT");
    $parallel_manager->finish; # Terminates the child process
}
##tumour
{
    my $pid = $parallel_manager->start and next;
    my $bam = $tumour_bam;
    ## just because the original so-called "sorted" bam is unsorted!
    run_cmd("$picard_dir/SortSam.jar I=$bam O=${bam}.sorted.bam SO=coordinate VALIDATION_STRINGENCY=SILENT");
    run_cmd("$picard_dir/BuildBamIndex.jar I=${bam}.sorted.bam O=${bam}.sorted.bam.bai VALIDATION_STRINGENCY=SILENT");
    $bam = "${bam}.sorted.bam";
    run_cmd("$picard_dir/MarkDuplicates.jar I=$bam O=${bam}.mark_duplicates.bam M=${bam}.metric REMOVE_DUPLICATES=FALSE VALIDATION_STRINGENCY=SILENT");
    (my $lib = $bam) =~ s/\.bam$//; # read group info
    run_cmd("$picard_dir/AddOrReplaceReadGroups.jar I=${bam}.mark_duplicates.bam O=${bam}.addreplacegroup.bam SO=coordinate RGID=${lib}.bam RGLB=LB_${lib}.bam RGPU=PU_${lib} RGSM=SM_${lib} RGCN=CN_${lib} RGDS=DS_${lib} RGPL=illumina VALIDATION_STRINGENCY=SILENT");
    run_cmd("$picard_dir/BuildBamIndex.jar I=${bam}.addreplacegroup.bam O=${bam}.addreplacegroup.bam.bai VALIDATION_STRINGENCY=SILENT");
    $parallel_manager->finish; # Terminates the child process
}
$parallel_manager->wait_all_children;
#run_cmd("touch $workspace/RG.complete");
&complete_("SortBam, MarkDuplicates, AddOrReplaceReadGroups, BuildBamIndex");

## new input
$tumour_bam = "$tumour_bam.sorted.bam.addreplacegroup.bam";
$normal_bam = "$normal_bam.sorted.bam.addreplacegroup.bam";

### GATK RECALIBRATION ###
begin_("GATK RECALIBRATION");
##paired sample realignment
run_cmd("$gatk_dir -T RealignerTargetCreator -R $refGenome -I $normal_bam -I $tumour_bam -o $workspace/forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2 -L $seqCap_file");
##normal
{
    $parallel_manager->start and next;
    my $bam = $normal_bam;
    run_cmd("$gatk_dir -T IndelRealigner -R $refGenome -I $bam -targetIntervals $workspace/forIndelRealigner.intervals -o ${bam}.IndelrealignedBam.bam -known $known_indel_file1 -known $known_indel_file2");
    run_cmd("$gatk_dir -T BaseRecalibrator -I ${bam}.IndelrealignedBam.bam -R $refGenome -knownSites $known_indel_file1 -knownSites $known_indel_file2 -knownSites $dbsnp_file -o ${bam}.recal_data.table -L $seqCap_file");
    run_cmd("$gatk_dir -T PrintReads -R $refGenome -o ${bam}${recal_suffix} -I ${bam}.IndelrealignedBam.bam \-BQSR ${bam}.recal_data.table");   
    $parallel_manager->finish;
}
##tumour
{
    $parallel_manager->start and next;
    my $bam = $tumour_bam;
    run_cmd("$gatk_dir -T IndelRealigner -R $refGenome -I $bam -targetIntervals $workspace/forIndelRealigner.intervals -o ${bam}.IndelrealignedBam.bam -known $known_indel_file1 -known $known_indel_file2");
    run_cmd("$gatk_dir -T BaseRecalibrator -I ${bam}.IndelrealignedBam.bam -R $refGenome -knownSites $known_indel_file1 -knownSites $known_indel_file2 -knownSites $dbsnp_file -o ${bam}.recal_data.table -L $seqCap_file");
    run_cmd("$gatk_dir -T PrintReads -R $refGenome -o ${bam}${recal_suffix} -I ${bam}.IndelrealignedBam.bam \-BQSR ${bam}.recal_data.table");   
    $parallel_manager->finish;
}
$parallel_manager->wait_all_children;
#run_cmd("touch $workspace/recalibration.complete");
complete_("GATK RECALIBRATION");

## new input
$tumour_bam = "$tumour_bam$recal_suffix";
$normal_bam = "$normal_bam$recal_suffix";

### COVERAGE DEPTH and samtools flagstat ###
{
    $parallel_manager->start and next;
    
    begin_("COVERAGE DEPTH and samtools flagstat");
    run_cmd("mkdir -p $DOC_out");
    my $sub_pm = new Parallel::ForkManager(4);
    ##normal
    {
	$sub_pm->start and next;
        my $bam = $normal_bam;
	(my $bam_name = $bam) =~ s/.*\///;
        run_cmd("$gatk_dir -T DepthOfCoverage -R $refGenome -L $seqCap_file -o $DOC_out/$bam_name -I $bam");
        $sub_pm->finish;
    }
    {
	$sub_pm->start and next;
        my $bam = $normal_bam;
        (my $bam_name = $bam) =~ s/.*\///;
	run_cmd("samtools flagstat $bam > $DOC_out/${bam_name}_flagstat.out"); 
        $sub_pm->finish;
    }
    #tumour
    {
	$sub_pm->start and next;
        my $bam = $tumour_bam;
	(my $bam_name = $bam) =~ s/.*\///;
        run_cmd("$gatk_dir -T DepthOfCoverage -R $refGenome -L $seqCap_file -o $DOC_out/$bam_name -I $bam");
        $sub_pm->finish;
    }
    {
	$sub_pm->start and next;
        my $bam = $tumour_bam;
        (my $bam_name = $bam) =~ s/.*\///;
	run_cmd("samtools flagstat $bam > $DOC_out/${bam_name}_flagstat.out"); 
        $sub_pm->finish;
    }
    $sub_pm->wait_all_children;
    complete_("COVERAGE DEPTH and samtools flagstat");
    #run_cmd("touch $workspace/DOC_flagstat.complete");
    
    $parallel_manager->finish;
}

### MUTECT ###
{
    $parallel_manager->start and next;
    
    begin_("MUTECT");
    run_cmd("mkdir -p ${mutect_out}");
    my $normal_recal = $normal_bam;
    my $tumour_recal = $tumour_bam;
    (my $tumour_recal_name = $tumour_recal) =~ s/.*\///;
    my $out_file = "${mutect_out}/${tumour_recal_name}.stat.txt";
    #my $coverage_file = "${mutect_sample_out_dir}/${tumour}.wig.txt";
    my $vcf_file = "${mutect_out}/${tumour_recal_name}.vcf"; 	
    run_cmd("$mutect_path --analysis_type MuTect --reference_sequence $refGenome --cosmic $cosmic_file --dbsnp $dbsnp_file --intervals $seqCap_file --input_file:normal $normal_recal --input_file:tumor $tumour_recal --enable_extended_output --out $out_file --vcf $vcf_file");
    complete_("MUTECT");
    #run_cmd("touch $workspace/MuTect.complete");

    ### annotation ###
    begin_("MuTect Annotation");
    &run_cmd('tail -n +3 '.$out_file.' | awk \'/KEEP/\' > '.$out_file.'.keep');
    
    #&run_cmd('awk -F "\t" \'/KEEP/{print $1"\t",$2"\t",$2"\t",$4"\t",$5"\t",$3"\t",$24"\t",$29"\t",$30"\t",$40"\t",$47"\t",$48"\t","?\t"}\' '.$out_file.'.keep | sed \'s/ //g\' > '.$out_file.'.avinput');
    &run_cmd('awk -F "\t" \'{print $1"\t"$2"\t"$2"\t"$4"\t"$5"\t"$3"\t"$24"\t"$29"\t"$30"\t"$40"\t"$47"\t"$48"\t?"}\' '.$out_file.'.keep > '.$out_file.'.avinput');
    
    #&run_cmd('perl '.$annovar_dir.'/table_annovar.pl -buildver hg19 -remove -outfile '.$out_file.'_SNV -protocol refGene,ensGene,cytoBand,snp137,cosmic67,ljb2_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog -operation g,g,r,f,f,f,f,r,r,r,r -otherinfo '.$out_file.'.avinput '.$annovar_dir.'/humandb/');
    &run_cmd('perl '.$annovar_dir.'/table_annovar.pl -buildver hg19 -remove -outfile '.$out_file.'_SNV -protocol refGene,ensGene,cytoBand,snp138,cosmic70,ljb26_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog,esp6500si_all,1000g2012apr_all -operation g,g,r,f,f,f,f,r,r,r,r,f,f -otherinfo '.$out_file.'.avinput '.$annovar_dir.'/humandb/');
    #&run_cmd('tail -n +2 '.$out_file.'_SNV.hg19_multianno.txt | cat '.$annovar_dir.'/Annovar_mutect_header.txt - > '.$out_file.'_SNV_hg19_multianno.txt');
    &run_cmd('tail -n +2 '.$out_file.'_SNV.hg19_multianno.txt > '.$out_file.'_SNV_hg19_multianno.txt');

    #&run_cmd('sed -i \'s/\t$//g\' '.$out_file.'_SNV_hg19_multianno.txt');
    
    &run_cmd('perl /mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/scripts/add_annotations_of_driver_mut.pl '.$out_file.'_SNV_hg19_multianno.txt');
    #&run_cmd('rm '.$out_file.'_SNV_hg19_multianno.txt');
    complete_("MuTect Annotation");
    #run_cmd("touch $workspace/MuTect_Annotation.complete");
    
    $parallel_manager->finish;
    
}

### strelka ###
{
    $parallel_manager->start and next;
    
    begin_("strelka");
    my $normal_recal = $normal_bam;
    my $tumour_recal = $tumour_bam;
    
    #create config file
    my $my_config = "$workspace/my_strelka_bwa_config";
    system("cp /projects/javeda/phase_software/strelka/etc/strelka_config_bwa_default.ini $my_config");
    system("sed -i -r 's/isSkipDepthFilters = 0/isSkipDepthFilters = 1/' $my_config");
    system("sed -i -r 's/^extraStrelkaArguments =\$/extraStrelkaArguments = --ignore-conflicting-read-names/' $my_config");
    #my $my_config = "$workspace/strelka_config_bwa";
    #run_cmd("cp /projects/javeda/phase_software/strelka/etc/strelka_config_bwa_default.ini $my_config");
    #run_cmd("sed -i -r 's/isSkipDepthFilters = 0/isSkipDepthFilters = 1/' $my_config");
    
    run_cmd("/projects/javeda/phase_software/strelka/bin/configureStrelkaWorkflow.pl --normal=$normal_recal --tumor=$tumour_recal --ref=$refGenome --config=$my_config --output-dir=$strelka_out");
    chdir("$strelka_out");
    run_cmd("make -j 16");
    complete_("strelka");
    #run_cmd("touch $workspace/strelka.complete");
    
    ### annotation ###
    begin_("strelka annotation");
    my $file= "$strelka_out/results/passed.somatic.indels.vcf";
    &run_cmd("cat $file | awk -F \" |\t|:|,\" '\$0!~/^#/ && (\$32+0)>=4 && (\$32+0)/(\$28+0)>=0.1{print \$0} \$0~/^#/{print \$0}' > ${file}_filtered.vcf"); 
    &run_cmd("/mnt/lung_cancer_patrick_cgi/TCR/Tools/annovar/convert2annovar.pl --format vcf4old -includeinfo -withzyg ${file}_filtered.vcf > ${file}_filtered_raw.avinput");
    run_cmd("awk 'BEGIN {FS = \"[ \t:,]+\"} {print \$1\"\t\"\$2\"\t\"\$3\"\t\"\$4\"\t\"\$5\"\t\"\$23\"\t\"\$27\"\t\"(\$27+0)/(\$23+0)\"\t\"\$34\"\t\"\$38\"\t\"(\$38+0)/(\$34+0)}' ${file}_filtered_raw.avinput > ${file}_filtered.avinput"); 
    #&run_cmd('perl '.$annovar_dir.'/table_annovar.pl -buildver hg19 -remove -outfile '.$file.'_InDel -protocol refGene,ensGene,cytoBand,snp137,cosmic67,ljb2_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog -operation g,g,r,f,f,f,f,r,r,r,r -otherinfo '."${file}_filtered.avinput ".$annovar_dir.'/humandb/');
    &run_cmd('perl '.$annovar_dir.'/table_annovar.pl -buildver hg19 -remove -outfile '.$file.'_InDel -protocol refGene,ensGene,cytoBand,snp138,cosmic70,ljb26_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog,esp6500si_all,1000g2012apr_all -operation g,g,r,f,f,f,f,r,r,r,r,f,f -otherinfo '."${file}_filtered.avinput ".$annovar_dir.'/humandb/');
    #&run_cmd('tail -n +2 '.$file.'_InDel.hg19_multianno.txt | cat '.$annovar_dir.'/Annovar_strelka_header.txt - > '.$file.'_InDel_hg19_multianno.txt');
    &run_cmd('tail -n +2 '.$file.'_InDel.hg19_multianno.txt > '.$file.'_InDel_hg19_multianno.txt');

    #&run_cmd('sed -i \'s/\t$//g\' '.$file.'_InDel_hg19_multianno.txt');
    
    &run_cmd('perl /mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/scripts/add_annotations_of_driver_mut.pl '.$file.'_InDel_hg19_multianno.txt');
    complete_("strelka annotation"); 
    #run_cmd("touch $workspace/strelka_annotation.complete");
    
    $parallel_manager->finish;
}

$parallel_manager->wait_all_children;

####functions####
sub run_cmd
{
        my ($commands) = @_;
        chomp(my $date = `date`);
        print "$date: $commands\n";
        print STDERR `$commands` if($runMode);
}

sub begin_
{
	(my $sub_procedure) = @_;
	print "=====================\n";
	print &date_format . "${sub_procedure}: starts!\n";
	print "=====================\n";
}

sub complete_
{
	(my $sub_procedure) = @_;
	print "=====================\n";
	print &date_format . "${sub_procedure}: completes!\n";
	print "=====================\n";
}

sub date_format {
	chomp(my $date = `date`);
	return "<" . $date . ">";
}
