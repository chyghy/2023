###vs2###
source activate vs2
virsorter config --set HMMSEARCH_THREADS=$Threads
ls batch/SRR|while read id;do
if [ -f batch/SRR/$id ];then
ID=` echo $id|awk -F '.' '{print $1}' `
mkdir -p batch/SRR/$ID/vsout; mv batch/SRR/$id batch/SRR/$ID;
virsorter run -w batch/SRR/$ID/vsout -i batch/SRR/$ID/$id --min-length 10000 -j $Threads all --keep-original-seq
fi
done
source deactivate
###checkV###
export CHECKVDB=/public1/home/scg2154/ghy/database/checkV
ls batch/SRR|while read id;do
ID=` echo $id|awk -F '.' '{print $1}' `
mkdir batch/SRR/$ID/checkV
checkv end_to_end batch/SRR/$ID/vsout/final-viral-combined.fa batch/SRR/$ID/checkV -t $Threads
done
###merge prophage###
ls batch/SRR|while read id;do
awk '{if( $10>10 && $3 == "Yes" && $1 ~ /full/) print $0}' batch/SRR/$ID/checkV/quality_summary.tsv > batch/SRR/$ID/prophage.txt
grep "partial" batch/SRR/$ID/vsout/final-viral-score.tsv >> batch/SRR/$ID/prophage.txt
echo -n -e $ID"\t" >> plot_tmp/SRR_prophage_Number.txt 
cat batch/SRR/$ID/prophage.txt|wc -l >> plot_tmp/SRR_prophage_Number.txt
echo -n -e $id"\t" >> plot_tmp/SRR_bin_size.txt
cat batch/SRR/$id/bin/${id}.gff.fasta |wc -m >> plot_tmp/SRR_bin_size.txt ###calculate the character number roughly
done