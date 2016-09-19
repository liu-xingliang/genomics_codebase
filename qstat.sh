#!/bin/bash

tmp_output=/tmp/liuxl.qstat
qstat -xml > $tmp_output 

stats=($(grep -iE "<state>" $tmp_output | sed -r 's/(<state>|<\/state>)//g'))
JBnumbers=($(grep -iE "<JB_job_number>" $tmp_output | sed -r 's/(<JB_job_number>|<\/JB_job_number>)//g'))
JBnames=($(grep -iE "<JB_name>" $tmp_output | sed -r 's/(<JB_name>|<\/JB_name>)//g'))
slots=($(grep -iE "<slots>" $tmp_output | sed -r 's/(<slots>|<\/slots>)//g'))
queues=($(grep -iE "<queue_name>" $tmp_output | sed -r 's/(<queue_name>|<\/queue_name>)//g'))

output="job-ID\tname\tstate\tslots\tqueue"
for i in $(seq 1 ${#JBnumbers[@]})
do
    i=$(( i - 1 ))
    output="$output\n${JBnumbers[i]}\t${JBnames[i]}\t${stats[i]}\t${slots[i]}\t${queues[i]}"
done

echo -e $output | column -t 
