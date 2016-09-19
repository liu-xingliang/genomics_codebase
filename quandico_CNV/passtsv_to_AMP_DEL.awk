#!/bin/gawk -f

BEGIN {
    # self var
    AMP_DEL="";

    # build in var
    FS="\t"
    OFS="\t";
    IGNORECASE=1;# gawk only
}

{
    if($1~/^chrx$/ || $1~/^x$/) # chrX
    {
        if($8 == 2) { #expected is 2
            if($10 >= 2.3) {
                AMP_DEL="AMP"; 
                print $1,$2,$3,$4,AMP_DEL; 
            } else if ($10 <= 1.7) {
                AMP_DEL="DEL";
                print $1,$2,$3,$4,AMP_DEL; 
            }
        } else if ($8 == 1) { # expected is 1
            if($10 >= 1.3) {
                AMP_DEL="AMP"; 
                print $1,$2,$3,$4,AMP_DEL; 
            } else if ($10 <= 0.7) {
                AMP_DEL="DEL";
                print $1,$2,$3,$4,AMP_DEL;
            }
        } 
    } else if($1~/^chry$/ || $1~/^y$/) { # chrY
        if($10 >= 1.3) {
            AMP_DEL="AMP"; 
            print $1,$2,$3,$4,AMP_DEL; 
        } else if ($10 <= 0.7) {
            AMP_DEL="DEL";
            print $1,$2,$3,$4,AMP_DEL; 
        }
    } else if ($1~/^chr[0-9]+$/ || $1~/^[0-9]+$/){ # chr1-22
        if($10 >= 2.3) {
            AMP_DEL="AMP"; 
            print $1,$2,$3,$4,AMP_DEL; 
        } else if ($10 <= 1.7) {
            AMP_DEL="DEL";
            print $1,$2,$3,$4,AMP_DEL; 
        }  
    }
}

END {
}
