#!/usr/bin/perl -w
use strict;
use Parallel::ForkManager;

my $input_mpileup = $ARGV[0]; 
my $binsize = $ARGV[1]; 

my $chr_list_file = "/mnt/projects/liuxl/ctso4_projects/liuxl/scripts/mpilupresult_bin_mean_splitchr/human_g1k_v37_chrlist";

open CHRS, '<', $chr_list_file or die "Cannot open the chromsome list file";
print "removing split_bam_list\n";
`rm ${input_mpileup}_split_bam_list` if -e "${input_mpileup}_split_bam_list";

open split_list, '>>', "${input_mpileup}_split_list";

print "Split samtools mpileup result based on chr ...\n";
my $fm = new Parallel::ForkManager(8);
while(<CHRS>) {
    chomp;
    my $chr = $_;
    my $child = $fm ->start and next;
    print "$chr send to cluster\n";
    my $qjob = "$input_mpileup.$chr.mpileup.binmean";
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
    print H_uge "#\$ -l h_rt=48:00:00,mem_free=10G -pe OpenMP 1\n";
    print H_uge "#\$ -cwd\n";
    print H_uge "source /mnt/software/etc/gis.bashrc\n";
    print H_uge "source /opt/uge-8.1.7p3/aquila_cell/common/settings.sh\n";
    print H_uge "grep -iE \"^$chr\\s\" $input_mpileup > part_${input_mpileup}_$chr.mpileup 2>$qjob.runlog\n";
    print H_uge "java -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/mpilupresult_bin_mean_splitchr:. -Xmx10G -XX:+UseSerialGC mpilupresult_bin_mean part_${input_mpileup}_$chr.mpileup $binsize >>$qjob.runlog 2>&1\n";
    print split_list "part_${input_mpileup}_$chr.mpileup.bin$binsize.mpileup\n";
    close H_uge;
    `qsub < $uge`;
    $fm->finish;
}
$fm->wait_all_children;

close CHRS;
