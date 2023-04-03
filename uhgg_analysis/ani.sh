ls batch/SRR|while read id;do
mkdir batch/SRR/$id/vsout/seqs
grep "partial" batch/SRR/$id/vsout/final-viral-combined.fa|while read line;do
ID=` echo $line|sed 's/.//' `
echo $ID > batch/SRR/$id/vsout/tmp_ID.txt
File=` echo $ID|awk -F '|' '{print $1}' `
seqtk subseq batch/SRR/$id/vsout/final-viral-combined.fa batch/SRR/$id/vsout/tmp_ID.txt > batch/SRR/$id/vsout/seqs/${File}.fna
ln -s batch/SRR/$id/vsout/seqs/${File}.fna ln/${File}.fna
done
done