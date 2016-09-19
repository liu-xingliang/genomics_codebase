#!/usr/bin/perl -w
use strict;
use Parallel::ForkManager;

my $input_bam = $ARGV[0]; 
my $mem_free = $ARGV[1];
my $Xmx = $ARGV[2];

my $chr_list_file = $ARGV[3]; #"/mnt/projects/liuxl/ctso4_projects/liuxl/SayLi/CTC_Proj/SayLiCTC_primers/not_empty/hg19_noUn_chrlist_not_empty";
my $ovlp = $ARGV[4]; #"/mnt/projects/liuxl/ctso4_projects/liuxl/myTools/OverlapBaseRefine.jar";
my $rmprimer = $ARGV[5]; #"/mnt/projects/liuxl/ctso4_projects/liuxl/myTools/TrimBAMPCRPrimer_locusbased.jar";
my $primer_dir= $ARGV[6]; #"/mnt/projects/liuxl/ctso4_projects/liuxl/SayLi/CTC_Proj/SayLiCTC_primers/locusbased/not_empty";
my $hold_jids= $ARGV[7]; # NA is "NA"
my $jids=$ARGV[8];

my $samtools = "/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/samtools/samtools-1.2/dist/bin/samtools";
my $java6 = "/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/bin/java";
my $java8 = "/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/java/jdk1.8.0_74/bin/java";
my $picard = "/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/picard/picard-tools-2.1.0/picard.jar";

open CHRS, '<', $chr_list_file or die "Cannot open the chromsome list file";
print "removing split_bam_list\n";
`rm ${input_bam}_split_bam_list` if -e "${input_bam}_split_bam_list";
open split_bam_list, '>>', "${input_bam}_split_bam_list";

print "Begin split $input_bam and refine the overlapped bases\n";
my $fm = new Parallel::ForkManager(8);
while(<CHRS>) {
    chomp;
    my $chr = $_;
    my $child = $fm ->start and next;
    print "$chr send to cluster\n";
    my $qjob = "$input_bam.$chr.ovlprefine_trimprimer";
    my $uge = "$qjob.uge";
    `rm $uge` if -e $uge;
    `rm $qjob.log` if -e "$qjob.log";
    `rm $qjob.err` if -e "$qjob.err";
    `rm $qjob.runlog` if -e "$qjob.runlog";
    open H_uge, '>>', $uge;
    print H_uge "#!/bin/bash\n";
    print H_uge "#\$ -N $qjob\n";
    print H_uge "#\$ -o $qjob.log\n";
    print H_uge "#\$ -e $qjob.err\n";
    print H_uge "#\$ -q medium.q\n";
    print H_uge "#\$ -l h_rt=48:00:00,mem_free=$mem_free -pe OpenMP 1\n";
    print H_uge "#\$ -cwd\n";
    print H_uge "source /mnt/software/etc/gis.bashrc\n";
    print H_uge "source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh\n";
    print H_uge "$samtools view -h $input_bam $chr | $samtools view -Sb - > part_${input_bam}_$chr.bam 2>$qjob.runlog\n";
    print H_uge "$java6 -Xmx$Xmx -XX:+UseSerialGC -jar $ovlp part_${input_bam}_$chr.bam part_${input_bam}_$chr.bam.ovlprefine.bam >>$qjob.runlog 2>&1\n";
    print H_uge "$java6 -Xmx$Xmx -XX:+UseSerialGC -jar $rmprimer part_${input_bam}_$chr.bam.ovlprefine.bam part_${input_bam}_$chr.bam.ovlprefine.bam.rmprimer.bam $primer_dir/primerpair_$chr.txt 0.2 >>$qjob.runlog 2>&1\n";
    print H_uge "$java8 -Xmx$Xmx -XX:+UseSerialGC -jar $picard SortSam I=part_${input_bam}_$chr.bam.ovlprefine.bam.rmprimer.bam O=part_${input_bam}_$chr.bam.ovlprefine.bam.rmprimer.bam.sorted.bam SO=coordinate VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true >>$qjob.runlog 2>&1\n"; 
    print split_bam_list "part_${input_bam}_$chr.bam.ovlprefine.bam.rmprimer.bam.sorted.bam\n";
    close H_uge;
    `qsub < $uge`;
    $fm->finish;
}
$fm->wait_all_children;

close CHRS;
close split_bam_list;
