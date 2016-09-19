#!/bin/bash

csv=$1

awk -F"," '$NF=="PASS"' $csv | sed -r 's/,/\t/g' > $csv.pass.tsv
