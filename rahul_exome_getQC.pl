#!/usr/bin/perl -w
use strict;

my $sample_summary = $ARGV[0];
my $cum_cov_prop = $ARGV[1]; # sample_cumulative_coverage_proportions
my $flagstat_out = $ARGV[2];
my $read_length = $ARGV[3];
my $total_reads = $ARGV[4];

my $total_covbases = `awk -F"\t" 'NR==2{print \$2}' $sample_summary`;
chomp $total_covbases;
my $mean_target_cov = `awk -F"\t" 'NR==2{print \$3}' $sample_summary`;
chomp $mean_target_cov;

my $bases_gte_1X = `awk -F"\t" 'NR==2{print \$3}' $cum_cov_prop`;
my $bases_gte_20X = `awk -F"\t" 'NR==2{print \$22}' $cum_cov_prop`;
my $bases_gte_60X = `awk -F"\t" 'NR==2{print \$62}' $cum_cov_prop`;
chomp $bases_gte_1X;
chomp $bases_gte_20X;
chomp $bases_gte_60X;

my $mapped_reads = `awk -F" " '/\\+ [0-9]+ mapped/{print \$1}' $flagstat_out`;
chomp $mapped_reads;
my $no_duplicates_marked = `awk -F" " '/\\+ [0-9]+ duplicates/{print \$1}' $flagstat_out`;
chomp $no_duplicates_marked;

# print the header
#print "Sample\tLibrary ID\tMultiplex_ID\tProtocol\tSector Info\tTissue Type\tRUN_ID\tTotal Reads\t% bases >= Q30\tMean Base quality\tMapped reads\tTotal mapped bases\tUnmapped reads\t% unmapped\tNumber of duplicates marked\t% duplicates\tOn Target Bases\t% On target bases\tTotal Target Intervals\tTarget intervals covered >=1x\tMean Target Coverage\tBases >= 1x\tBases >= 20x\tBases >=60x\tMean  target coverage / million reads mapped";

my $line = "";
# the first 7 columns need to be filled ourselves
$line .= ".";
$line .= "\t." x 6;
$line .= "\t$total_reads"; # total reads
$line .= "\t."; #% bases >= Q30
$line .= "\t."; #mean base quality
$line .= "\t$mapped_reads"; # mapped reads getting from flagstat out
my $total_mapped_bases = $mapped_reads * $read_length;
$line .= "\t$total_mapped_bases";
my $unmapped_reads = $total_reads - $mapped_reads;
$line .= "\t$unmapped_reads";
my $unmapped_reads_percent = $unmapped_reads / $total_reads * 100;  
$line .= "\t$unmapped_reads_percent";
$line .= "\t$no_duplicates_marked"; # number of duplicates marked
my $perc_dup_marked = $no_duplicates_marked / $mapped_reads * 100; # % duplicates
$line .= "\t$perc_dup_marked";
$line .= "\t$total_covbases"; #On Target Bases
my $perc_ontarget_bases = $total_covbases/$total_mapped_bases * 100;#% On target bases
$line .= "\t$perc_ontarget_bases";
$line .= "\t."; #Total Target Intervals
$line .= "\t."; #Target intervals covered >=1x
$line .= "\t$mean_target_cov"; #mean target coverage (total number of on target bases / covered region length)
$line .= "\t$bases_gte_1X"; #Bases >= 1x
$line .= "\t$bases_gte_20X"; #Bases >= 20X
$line .= "\t$bases_gte_60X"; #Bases >= 60X
my $mean_targetcov_millionreads = $mean_target_cov / $mapped_reads * 1000000; 
$line .= "\t$mean_targetcov_millionreads"; #Mean  target coverage / million reads mapped

print "$line\n";
