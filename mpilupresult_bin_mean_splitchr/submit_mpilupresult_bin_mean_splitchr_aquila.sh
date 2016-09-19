#!/bin/bash

while read mpileup
do
    [[ ! ( -e ${mpileup}_d ) ]] && mkdir ${mpileup}_d
    ln -s $(readlink -f $mpileup) ${mpileup}_d 
    cp mpilupresult_bin_mean_splitchr.pl ${mpileup}_d
    cd ${mpileup}_d
    perl mpilupresult_bin_mean_splitchr.pl $mpileup 100
    cd -
done < $1
