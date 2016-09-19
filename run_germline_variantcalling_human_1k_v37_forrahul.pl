#!/usr/bin/perl -w
use strict;
use Getopt::Long;

# reference files
#my $cosmic ="/mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/cosmic/Cosmic70_hg19_noRandom.vcf";
#my $dbsnp ="/mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/dbsnp/dbSNPv138_00-All_hg19_noRandom.vcf";
#my $seqCap = "targetseq_038039049283_hg19.bed";
my $refGenome = "/mnt/AnalysisPool/libraries/genomes/human_g1k_v37/human_g1k_v37.fa";
my $known_indel_file1 = "/mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/resource_bundle/1000G_phase1.indels.b37.vcf";
my $known_indel_file2 = "/mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/resource_bundle/Mills_and_1000G_gold_standard.indels.b37.vcf";

# program
my $picard_dir = "java -XX:+UseSerialGC -jar -Xmx4g /mnt/AnalysisPool/libraries/tools/picard/picard-tools-1.111";
my $gatk_dir = "java -XX:+UseSerialGC -jar -Xmx4g /mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/GenomeAnalysisTK.jar";
my $java = "java -XX:+UseSerialGC -jar -Xmx4g";
my $gatk = "/mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/GenomeAnalysisTK.jar";
my $annovar_dir="/mnt/lung_cancer_patrick_cgi/TCR/Tools/annovar";

### Command Line Arguments ###
my (
    $workspace, 
    $tumour_bam,
    $runMode,        # Run mode: 0 for debug mode (not execute actual command); 1 for executable mode.
);

GetOptions(
    "workspace=s" => \$workspace,
    "tumour=s" => \$tumour_bam,	
    "run=i" => \$runMode,
) or die "Errors in command line arguments!";

#### Mark Duplicates, Add Read Group and Build Index of result bam file###
#&begin_("SortBam, MarkDuplicates, AddOrReplaceReadGroups, BuildBamIndex");
###tumour
#{
#    my $bam = $tumour_bam;
#    ## just because the original so-called "sorted" bam is unsorted!
#    run_cmd("$picard_dir/SortSam.jar I=$bam O=${bam}.sorted.bam SO=coordinate VALIDATION_STRINGENCY=SILENT");
#    run_cmd("$picard_dir/BuildBamIndex.jar I=${bam}.sorted.bam O=${bam}.sorted.bam.bai VALIDATION_STRINGENCY=SILENT");
#    $bam = "${bam}.sorted.bam";
#    (my $lib = $bam) =~ s/\.bam$//; # read group info
#    run_cmd("$picard_dir/AddOrReplaceReadGroups.jar I=$bam O=${bam}.addreplacegroup.bam SO=coordinate RGID=${lib}.bam RGLB=LB_${lib}.bam RGPU=PU_${lib} RGSM=SM_${lib} RGCN=CN_${lib} RGDS=DS_${lib} RGPL=illumina VALIDATION_STRINGENCY=SILENT");
#    run_cmd("$picard_dir/BuildBamIndex.jar I=${bam}.addreplacegroup.bam O=${bam}.addreplacegroup.bam.bai VALIDATION_STRINGENCY=SILENT");
#}
#&complete_("SortBam, MarkDuplicates, AddOrReplaceReadGroups, BuildBamIndex");

## new input
$tumour_bam = "$tumour_bam.sorted.bam.addreplacegroup.bam";

#### GATK RECALIBRATION ###
###paired sample realignment
#run_cmd("$gatk_dir -T RealignerTargetCreator -R $refGenome -I $tumour_bam -o $workspace/forIndelRealigner.intervals --known $known_indel_file1 --known $known_indel_file2 -L $seqCap");
###tumour
#{
#    my $bam = $tumour_bam;
#    run_cmd("$gatk_dir -T IndelRealigner -R $refGenome -I $bam -targetIntervals $workspace/forIndelRealigner.intervals -o ${bam}.IndelrealignedBam.bam -known $known_indel_file1 -known $known_indel_file2 -dt BY_SAMPLE -dcov 20000");
#}

# user input
my $input = "$tumour_bam.IndelrealignedBam.bam";

# run
# indel, small set
{
    system("$java $gatk -T UnifiedGenotyper -R $refGenome -I $input --dbsnp $dbsnp -o $input.indel.raw.vcf -L $seqCap");
    system("$java $gatk -T SelectVariants -R $refGenome --variant $input.indel.raw.vcf -o $input.indel.vcf -selectType INDEL");
    system("$java $gatk -T VariantFiltration -R $refGenome --variant $input.indel.vcf -o $input.indel.vcf_filtered.vcf --filterExpression \"QD < 2.0\" --filterName \"QD\" --filterExpression \"ReadPosRankSum < -20.0\" --filterName \"ReadPosRankSum\" --filterExpression \"InbreedingCoeff < -0.8\" --filterName \"InbreedingCoeff\" --filterExpression \"FS > 200.0\" --filterName \"FS\"");
#    # create .avinput input file for annovar
#    my $vcf_version = `head -n 1 $input.indel.vcf_filtered.vcf`;
#    chomp $vcf_version;
#    if($vcf_version !~ m/VCFv4.1/ && $vcf_version !~ m/VCFv4.2/) {
#        print STDERR "Current support versions are only VCFv4.1 and VCFv4.2\n";
#        exit 1;
#    }
#    #my @a = `awk -F"\t" '!/^#/ && \$7=="PASS"{split(\$10,a,":|,");print \$1"\t"\$2"\t"\$4"\t"\$5"\t"a[3]/(a[2]+a[3])"\t"a[2]"\t"a[3]}' $input.indel.vcf_filtered.vcf`;
#    my @a = `awk -F"\t" '!/^#/ && \$7=="PASS"{print \$1"\t"\$2"\t"\$4"\t"\$5"\t"\$10}' $input.indel.vcf_filtered.vcf`;
#    open FH, '>', $input.'.indel.vcf_filtered.vcf.avinput';
#    foreach my $s (@a) {
#        chomp $s;
#        
#        my @indel_array = split "\t", $s;
#        my $ref = $indel_array[2];
#        my $alt_raw = $indel_array[3];
#        my @alt_array = split ",", $alt_raw; # there might be several possible variants 
#        my $otherinfo = $indel_array[4];
#        my @otherinfo_array = split /:|,/, $otherinfo;
#        my $ref_dep = $otherinfo_array[0];
#        for(my $idx_altarr=0; $idx_altarr<=$#alt_array; $idx_altarr++) {
#            my $alt = $alt_array[$idx_altarr];
#            my $ref_len = length $ref;
#            my $alt_len = length $alt;
#            my $alt_dep = $otherinfo_array[$idx_altarr + 1];
#            my $alt_allele_freq = $alt_dep/($ref_dep + $alt_dep);
#            if($ref_len > $alt_len) # DEL
#            {
#                my $newRef = substr $ref, $alt_len;
#                my $new_start = $indel_array[1] + $alt_len;
#                my $end = $new_start + $ref_len - 1;
#                print FH "$indel_array[0]\t$new_start\t$end\t$newRef\t-\t$alt_allele_freq\t$ref_dep\t$alt_dep\n";
#            } else { # INS
#                my $newAlt = substr $alt, $ref_len;
#                print FH "$indel_array[0]\t$indel_array[1]\t$indel_array[1]\t-\t$newAlt\t$alt_allele_freq\t$ref_dep\t$alt_dep\n"
#            } 
#        }
#    }
#    close(FH);
#    
#    # annovar 
#    &run_cmd('perl '.$annovar_dir.'/table_annovar.pl -buildver hg19 -remove -outfile '.$input.'_InDel -protocol refGene,ensGene,cytoBand,snp138,cosmic70,ljb26_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog,esp6500si_all,1000g2012apr_all -operation g,g,r,f,f,f,f,r,r,r,r,f,f -otherinfo '."$input.indel.vcf_filtered.vcf.avinput ".$annovar_dir.'/humandb/');
#    
#    # post-annovar
#    &run_cmd('tail -n +2 '.$input.'_InDel.hg19_multianno.txt | cat '.$annovar_dir.'/Annovar_glvar_header.txt - > '.$input.'_InDel_hg19_multianno.txt');
#    &run_cmd('perl /mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/scripts/VOGELSTEIN/add_annotations_of_driver_mut.pl '.$input.'_InDel_hg19_multianno.txt');
}

# snp, small set
{
    system("$java $gatk -T UnifiedGenotyper -R $refGenome -I $input --dbsnp $dbsnp -o $input.snps.raw.vcf -L $seqCap");
    system("$java $gatk -T SelectVariants -R $refGenome --variant $input.snps.raw.vcf -o $input.snps.vcf -selectType SNP");
    system("$java $gatk -T VariantFiltration -R $refGenome --variant $input.snps.vcf -o $input.snps.vcf_filtered.vcf --filterExpression \"QD < 2.0\" --filterName \"QD\" --filterExpression \"MQ < 40.0\" --filterName \"MQ\" --filterExpression \"FS > 60.0\" --filterName \"FS\" --filterExpression \"HaplotypeScore > 13.0\" --filterName \"HaplotypeScore\" --filterExpression \"MQRankSum < -12.5\" --filterName \"MQRankSum\" --filterExpression \"ReadPosRankSum < -8.0\" --filterName \"ReadPosRankSum\"");

#    # create .avinput input file for annovar
#    my $vcf_version = `head -n 1 $input.snps.vcf_filtered.vcf`;
#    chomp $vcf_version;
#    if($vcf_version !~ m/VCFv4.1/ && $vcf_version !~ m/VCFv4.2/) {
#        print STDERR "Current support versions are only VCFv4.1 and VCFv4.2\n";
#        exit 1;
#    }
#    #my @a = `awk -F"\t" '!/^#/ && \$7=="PASS"{split(\$10,a,":|,");print \$1"\t"\$2"\t"\$2"\t"\$4"\t"\$5"\t"a[3]/(a[2]+a[3])"\t"a[2]"\t"a[3]}' $input.snps.vcf_filtered.vcf`;
#    my @a = `awk -F"\t" '!/^#/ && \$7=="PASS"{print \$1"\t"\$2"\t"\$4"\t"\$5"\t"\$10}' $input.indel.vcf_filtered.vcf`;
#    open FH, '>', $input.'.snps.vcf_filtered.vcf.avinput';
#    foreach my $s (@a) {
#        my @snp_array = split "\t", $s;
#        my $ref = $snp_array[2];
#        my $alt_raw = $snp_array[3];
#        my @alt_array = split ",", $alt_raw; # there might be several possible variants 
#        my $otherinfo = $snp_array[4];
#        my @otherinfo_array = split /:|,/, $otherinfo;
#        my $ref_dep = $otherinfo_array[0];
#        for(my $idx_altarr=0; $idx_altarr<=$#alt_array; $idx_altarr++) {
#            my $alt = $alt_array[$idx_altarr];
#            my $alt_dep = $otherinfo_array[$idx_altarr + 1];
#            my $alt_allele_freq = $alt_dep/($ref_dep + $alt_dep);
#            print FH "$snp_array[0]\t$snp_array[1]\t$snp_array[1]\t$snp_array[2]\t$snp_array[3]\t$alt_allele_freq\t$ref_dep\t$alt_dep\n";
#        } 
#    }
#    close(FH);
#    
#    # annovar 
#    &run_cmd('perl '.$annovar_dir.'/table_annovar.pl -buildver hg19 -remove -outfile '.$input.'_SNV -protocol refGene,ensGene,cytoBand,snp138,cosmic70,ljb26_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog,esp6500si_all,1000g2012apr_all -operation g,g,r,f,f,f,f,r,r,r,r,f,f -otherinfo '."$input.snps.vcf_filtered.vcf.avinput ".$annovar_dir.'/humandb/');
#    
#    # post-annovar
#    &run_cmd('tail -n +2 '.$input.'_SNV.hg19_multianno.txt | cat '.$annovar_dir.'/Annovar_glvar_header.txt - > '.$input.'_SNV_hg19_multianno.txt');
#    &run_cmd('perl /mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/scripts/VOGELSTEIN/add_annotations_of_driver_mut.pl '.$input.'_SNV_hg19_multianno.txt');
}

## merge indels and snps
#`tail -n +2 ${input}_InDel_hg19_multianno.txt.mutdriver | cat ${input}_SNV_hg19_multianno.txt.mutdriver - > ${input}_SNV_InDel_hg19_multianno.txt.mutdriver`;

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
