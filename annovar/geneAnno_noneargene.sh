#!/bin/bash

avinput=$1
annovar_dir=/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/annovar

# checked, when upstream;downstream, after change --neargene 0, result is correct; when there is only upstream or downstream (the other gene with distance > 1000 is ignored due to annotation precedence), result is correct
perl $annovar_dir/table_annovar_noneargene.pl -buildver hg19 -remove -outfile $avinput.geneAnno.noneargene -protocol refGene,ensGene -operation g,g -otherinfo $avinput $annovar_dir/humandb/
