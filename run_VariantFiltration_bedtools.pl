#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use Parallel::ForkManager;

### Common Settings ###
my $refGenome = "/mnt/AnalysisPool/libraries/genomes/human_g1k_v37/human_g1k_v37.fa";
my $GATK = "java -XX:ConcGCThreads=4 -XX:+UseConcMarkSweepGC -XX:ParallelGCThreads=4 -jar /mnt/AnalysisPool/libraries/tools/GATK/GenomeAnalysisTK-2.7-2-g6bda569/GenomeAnalysisTK.jar";
my $FFPE_folder = "FFPE_samples"; #TODO: assume folder of FFPE samples vcfs is under directory of other fresh tumour samples vcfs
my $FFPE_var_filtered_folder = "FFPE_samples";
my $abs_raw_vcf_dir = "/mnt/lung_cancer_patrick_cgi/TCR/Final_Data/Exome-seq";
my $var_filtered_folder = "variant_filtration";
my $filtered_var_cmp_folder = "filtered_var_cmp";
### Command Line Arguments ###
my ($workspace, @patientIds, @FFPE_tumour_libs, @tumour_libs, $runMode);
GetOptions (
	"workspace=s" => \$workspace,
	"patient=s" => \@patientIds,
	"tumour=s" => \@tumour_libs,
	"ffpe=s" => \@FFPE_tumour_libs,
	"run=i" => \$runMode,	
) or die "Errors in command line arguments!";
### Parallel ###
my $MAX_PROC=40;
my $parallel_manager = new Parallel::ForkManager(int($MAX_PROC));

&begin_("VariantFiltration");
foreach my $patientId (@patientIds) {
	my $raw_vcf_dir_patientId = "${abs_raw_vcf_dir}/${patientId}";
	opendir(my $dh, $raw_vcf_dir_patientId) or die "Cannot open directory ${raw_vcf_dir_patientId}\n";
	my @raw_vcfs_patientId = grep {/\.vcf$/} readdir($dh);
	# read vcfs for FFPE tumour samples
	my $FFPE_dir = "${raw_vcf_dir_patientId}/${FFPE_folder}";
	opendir(my $dh_FFPE, $FFPE_dir) or die "Cannot open directory ${FFPE_dir}\n";
	my @FFPE_raw_vcfs = grep {/\.vcf$/} readdir($dh_FFPE);
	
	foreach my $raw_vcf_patientId (@raw_vcfs_patientId) {
		foreach my $tumour_lib (@tumour_libs) {
			if($raw_vcf_patientId =~ m/$tumour_lib/) {
				$parallel_manager->start and next;
				my $vcf_snps = "${raw_vcf_patientId}_snps.vcf";
				my $variant_filtration_out_dir = "${workspace}/${patientId}/${var_filtered_folder}";
				my $variant_filtration_out_file = "${raw_vcf_patientId}_filtered.vcf";  
				&run_cmd("mkdir -p ${variant_filtration_out_dir}");
				&run_cmd("${GATK} -T SelectVariants -R ${refGenome} --variant ${raw_vcf_dir_patientId}/${raw_vcf_patientId} -o ${variant_filtration_out_dir}/${vcf_snps} -selectType SNP");
				&run_cmd("${GATK} -T VariantFiltration -R ${refGenome} --variant ${variant_filtration_out_dir}/${vcf_snps} -o ${variant_filtration_out_dir}/${variant_filtration_out_file} --filterExpression \"QD < 2.0 || MQ < 40.0 || FS > 60.0 || HaplotypeScore > 13.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0\" --filterName \"verysmall_dataset_SNPs_defaultfilter\"");	
				$parallel_manager->finish;
				last;
			}
		}
	}
	
	foreach my $FFPE_raw_vcf (@FFPE_raw_vcfs) {
		foreach my $FFPE_tumour (@FFPE_tumour_libs) {
			if($FFPE_raw_vcf =~ m/$FFPE_tumour/) {
				$parallel_manager->start and next;
				my $vcf_snps = "${FFPE_raw_vcf}_snps.vcf";
				my $variant_filtration_out_dir = "${workspace}/${patientId}/${var_filtered_folder}/${FFPE_var_filtered_folder}";
				my $variant_filtration_out_file = "${FFPE_raw_vcf}_filtered.vcf";  
				&run_cmd("mkdir -p ${variant_filtration_out_dir}");
				&run_cmd("${GATK} -T SelectVariants -R ${refGenome} --variant ${raw_vcf_dir_patientId}/${FFPE_folder}/${FFPE_raw_vcf} -o ${variant_filtration_out_dir}/${vcf_snps} -selectType SNP");
				&run_cmd("${GATK} -T VariantFiltration -R ${refGenome} --variant ${variant_filtration_out_dir}/${vcf_snps} -o ${variant_filtration_out_dir}/${variant_filtration_out_file} --filterExpression \"QD < 2.0 || MQ < 40.0 || FS > 60.0 || HaplotypeScore > 13.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0\" --filterName \"verysmall_dataset_SNPs_defaultfilter\"");	
				$parallel_manager->finish;
				last;
			}	
		}	
	}	
}
$parallel_manager->wait_all_children;
&complete_("VariantFiltration");

### Bedtools Intersect ###
&begin_("intersectBed");
foreach my $patientId (@patientIds) {
	#find target filtered vcf files in fresh tumour directory
	my $var_filtered_dir = "${workspace}/${patientId}/${var_filtered_folder}";
	opendir(my $dh_var_filtered_dir, $var_filtered_dir) or die "Cannot open ${var_filtered_dir}";
	my @filtered_vcf_fnames = grep {/.*_filtered\.vcf$/} readdir($dh_var_filtered_dir);
	# find all filtered vcf files in FFPE tumour directory
	my $FFPE_var_filtered_dir = "${workspace}/${patientId}/${var_filtered_folder}/${FFPE_var_filtered_folder}";
	opendir(my $dh_FFPE_var_filtered_dir, $FFPE_var_filtered_dir) or die "Cannot open ${FFPE_var_filtered_dir}";
	my @FFPE_filtered_vcf_fnames = grep {/.*_filtered\.vcf$/} readdir($dh_FFPE_var_filtered_dir);
	# compare filtered vcf files of fresh tumour and FFPE tumour
	foreach my $filtered_vcf_fname (@filtered_vcf_fnames) {
		foreach my $FFPE_filtered_vcf_fname (@FFPE_filtered_vcf_fnames) {
			my $filtered_vcf = "${var_filtered_dir}/${filtered_vcf_fname}";
			my $FFPE_filtered_vcf = "${FFPE_var_filtered_dir}/${FFPE_filtered_vcf_fname}";
			my $filtered_vcf_cmp_dir = "${workspace}/${patientId}/${filtered_var_cmp_folder}";
			&run_cmd("mkdir -p ${filtered_vcf_cmp_dir}");
			my $filtered_vcf_cmp_file = "${filtered_vcf_cmp_dir}/${FFPE_filtered_vcf_fname}_${filtered_vcf_fname}_cmp.txt";
			&run_cmd("bedtools intersect -wo -a ${FFPE_filtered_vcf} -b ${filtered_vcf} | wc -l | awk '{print \"BOTH: \", \$0}' >${filtered_vcf_cmp_file}");
			&run_cmd("bedtools intersect -v -a ${FFPE_filtered_vcf} -b ${filtered_vcf} | wc -l | awk '{print \"${FFPE_filtered_vcf_fname}: \", \$0}' >>${filtered_vcf_cmp_file}");
			&run_cmd("bedtools intersect -v -b ${FFPE_filtered_vcf} -a ${filtered_vcf} | wc -l | awk '{print \"${filtered_vcf_fname}: \", \$0}' >>${filtered_vcf_cmp_file}");
		}
	}
}
&complete_("intersectBed");

### Functions ###
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

