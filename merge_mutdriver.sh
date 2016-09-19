#!/bin/bash

while read mutdriver
do
    tlib=$(echo $mutdriver | awk -F"somatic_" '{print $1}' | awk -F"AND" '{print $1}')
    nlib=$(echo $mutdriver | awk -F"somatic_" '{print $1}' | awk -F"AND" '{print $2}')
    tinfo=$(awk -F"\t" -v lib="$tlib" '$3==lib' libinfo)
    ninfo=$(awk -F"\t" -v lib="$nlib" '$3==lib' libinfo)
    awk -v tinfo="$tinfo" -v ninfo="$ninfo" -F"\t" '{print tinfo"\t"ninfo"\t"$0}' $mutdriver >> All_mutdriver
done < mutdriver_list
