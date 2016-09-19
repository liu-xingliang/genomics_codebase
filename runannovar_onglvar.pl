#!/usr/bin/perl -w
use strict;

my $annovar_dir = "/mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/Tools/annovar";
my $input_vcf = $ARGV[0];

#system("perl $annovar_dir/convert2annovar.pl --format vcf4 -includeinfo -withzyg $input_vcf > $input_vcf.avinput");
#system("perl $annovar_dir/table_annovar.pl -buildver hg19 -outfile ${input_vcf}_SNV -remove -protocol refGene,ensGene,cytoBand,snp137,cosmic67,ljb2_all,avsift,tfbsConsSites,wgRna,targetScanS,gwasCatalog,esp6500si_all,1000g2012apr_all -operation g,g,r,f,f,f,f,r,r,r,r,f,f -otherinfo $input_vcf.avinput $annovar_dir/humandb");

open(FH, "${input_vcf}_SNV.hg19_multianno.txt");
my @file = <FH>;
close(FH);
open FH_out, ">", "${input_vcf}_SNV.hg19_multianno.altrefcountfreq.txt";
my $header = shift @file;
my @headerarray = split "\t", $header;
my $header_id_and_annotation = join "\t", @headerarray[0..39];
print FH_out "$header_id_and_annotation\talt_allele_freq\tref_depth\talt_depth\n";
foreach (@file) {
    chomp;
    my @array = split "\t", $_;
    my $value = pop @array;
    my @v_array = split ',|:', $value;
    my $freq = $v_array[2] / ($v_array[1] + $v_array[2]);
    my $id_and_annotation= join "\t", @array[0..39];
    print FH_out "$id_and_annotation\t$freq\t$v_array[1]\t$v_array[2]\n";
}
close(FH_out);

#no need to do change header, it's already correct
#system("tail -n +2 ${input_vcf}_SNV.hg19_multianno.combinefreq.txt | cat Annovar_mutect_header.txt - > ${input_vcf}_SNV_hg19_multianno.combinefreq.txt");
system("perl /mnt/lung_cancer_patrick_cgi/TCR/Tools/VOGELSTEIN/add_annotations_of_driver_mut.pl ${input_vcf}_SNV.hg19_multianno.altrefcountfreq.txt");
