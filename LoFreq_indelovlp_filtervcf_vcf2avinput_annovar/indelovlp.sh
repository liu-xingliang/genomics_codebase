#!/bin/bash

vcf=$1
lofreq2_indel_ovlp.py $vcf > $vcf.indelovlp.vcf 
