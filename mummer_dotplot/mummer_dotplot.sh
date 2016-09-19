nucmer_delta=$1
assembly_report=$2
refGenome=$3
Xmx=$4
Qfasta=$5

echo "delta-filter..."
delta1to1=$(echo $nucmer_delta | sed -r 's/delta$/1to1.delta/')
/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/MUMmer/MUMmer3.23_64bit/delta-filter -1 $nucmer_delta > $delta1to1 # 1-to-1 (best in ref and best in query) alignment allowing for rearrangements
echo "delta-filter finished"

echo "get main reference fasta id..."
grep -E "^1\s|^2\s|^3\s|^4\s|^5\s|^6\s|^7\s|^8\s|^9\s|^10\s|^11\s|^12\s|^13\s|^14\s|^15\s|^16\s|^17\s|^18\s|^19\s|^20\s|^21\s|^22\s|^X\s|^Y\s|^MT\s" $assembly_report | cut -f5 | sort | uniq > main.rids
grep -E "^1\s|^2\s|^3\s|^4\s|^5\s|^6\s|^7\s|^8\s|^9\s|^10\s|^11\s|^12\s|^13\s|^14\s|^15\s|^16\s|^17\s|^18\s|^19\s|^20\s|^21\s|^22\s|^X\s|^Y\s|^MT\s" $assembly_report | cut -f1,5 | sort | uniq > main.rids2chr
echo "get main reference fasta id finished!"

echo "show-coords..."
/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/MUMmer/MUMmer3.23_64bit/show-coords -q -T -d $delta1to1 > $delta1to1.coords
/mnt/projects/liuxl/ctso4_projects/liuxl/Tools/MUMmer/MUMmer3.23_64bit/show-coords -q -T -d -H $delta1to1 > $delta1to1.noheader.coords
echo "show-coords finished!"

echo "mummerplot..."
while read rid; do
    chr=$(awk -F"\t" -v rid="$rid" '$2==rid{print $1}' main.rids2chr) 
    awk -F"\t" -v rid="$rid" '$10==rid{print $11}' $delta1to1.noheader.coords | sort | uniq > nucmer.1to1.$chr.qids
    Qfile=$Qfasta.$chr.fasta
    [[ -e $Qfile ]] && rm $Qfile
    while read qid; do
        echo "Extracting query $qid fasta..."
        java -XX:+UseSerialGC -Xmx$Xmx -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/mummer_dotplot ExtractFasta $Qfasta $qid
        cat $qid.fasta >> $Qfile
        rm $qid.fasta
    done < nucmer.1to1.$chr.qids
    echo "Extracting reference $chr fasta..."
    java -XX:+UseSerialGC -Xmx$Xmx -cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/mummer_dotplot ExtractFasta $refGenome $rid
    mv $rid.fasta $chr.fasta
    Rfile=$chr.fasta
    echo "mummerplot drawing..."
    /mnt/projects/liuxl/ctso4_projects/liuxl/Tools/MUMmer/MUMmer3.23_64bit/mummerplot --png --title "$chr" --Rfile $Rfile --Qfile $Qfile --layout -p mummerplot.${chr} $delta1to1 
done < main.rids # only map to main chrs
echo "mummerplot finished!"
