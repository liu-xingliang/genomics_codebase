#!/bin/bash

vcf=$1
lofreq filter --no-defaults --af-min 0.005 -i $vcf -o $vcf.filtered.vcf
