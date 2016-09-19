#!/usr/bin/perl -w
use strict;
use Getopt::Long;

# run mode
my $runMode = 0;

#program
my $annovar_dir="/mnt/lung_cancer_patrick_cgi/TCR/Tools/annovar";

# configure
my $workspace = "";

# reference
my $refGenome = "/mnt/AnalysisPool/libraries/genomes/human_g1k_v37/human_g1k_v37.fa";

## input realigned recalibrated bam file
my $tumour_bam = "";
my $normal_bam = "";

GetOptions(
    "workspace=s" => \$workspace,
    "normal=s" => \$normal_bam,
    "tumour=s" => \$tumour_bam,	
    "run=i" => \$runMode,
) or die "Errors in command line arugments!";

my $strelka_out = "${workspace}/strelka";

### run ###
{
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
    run_cmd("make -j 20");
    complete_("strelka");
    #run_cmd("touch $workspace/strelka.complete");
    
    ### annotation ###
    begin_("strelka annotation");
    my $file= "$strelka_out/results/passed.somatic.indels.vcf";
    &run_cmd("cat $file | awk -F \" |\t|:|,\" '\$0!~/^#/ && (\$32+0)>=4 && (\$32+0)/(\$28+0)>=0.1{print \$0} \$0~/^#/{print \$0}' > ${file}_filtered.vcf"); 
    &run_cmd("/mnt/lung_cancer_patrick_cgi/TCR/Tools/annovar/convert2annovar.pl --format vcf4old -includeinfo -withzyg ${file}_filtered.vcf > ${file}_filtered_raw.avinput");
    run_cmd("awk 'BEGIN {FS = \"[ \t:,]+\"} {print \$1\"\t\"\$2\"\t\"\$3\"\t\"\$4\"\t\"\$5\"\t\"\$23\"\t\"\$27\"\t\"(\$27+0)/(\$23+0)\"\t\"\$34\"\t\"\$38\"\t\"(\$38+0)/(\$34+0)}' ${file}_filtered_raw.avinput > ${file}_filtered.avinput"); 
    &run_cmd('perl '.$annovar_dir.'/table_annovar.pl -buildver hg19 -remove -outfile '.$file.'_InDel -protocol refGene,ensGene,cytoBand,snp137,cosmic67,ljb2_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog -operation g,g,r,f,f,f,f,r,r,r,r -otherinfo '."${file}_filtered.avinput ".$annovar_dir.'/humandb/');
    &run_cmd('tail -n +2 '.$file.'_InDel.hg19_multianno.txt | cat '.$annovar_dir.'/Annovar_strelka_header.txt - > '.$file.'_InDel_hg19_multianno.txt');
    
    &run_cmd('sed -i \'s/\t$//g\' '.$file.'_InDel_hg19_multianno.txt');
    
    &run_cmd('perl /mnt/lung_cancer_patrick_cgi/TCR/Tools/VOGELSTEIN/add_annotations_of_driver_mut.pl '.$file.'_InDel_hg19_multianno.txt');
    complete_("strelka annotation"); 
    #run_cmd("touch $workspace/strelka_annotation.complete");
}

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
