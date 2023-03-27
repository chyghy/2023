# Detect prophages from rawdata
### Install dependencies
sunbeam  
virsorter  
seqtk  
checkv  
bowtie2  
metabat2  
checkm  

### Parameter setting
```bash
python_dir='python/' 
W_DIR="results"  
Threads=4
```
### Take SRR5273878 as an example
This script takes the sample "SRR527387" as an example.

### Run sunbeam for quality control and assembly 
#### Data preparation
Here we get started from sra format data downloaded from NCBI
```bash
mkdir -p $W_DIR/SRR5273878/sunbeam_output/download
fastq-dump --split-3 --gzip /public1/home/scg2154/jxy/rawdata/SRR5273878.sra -O ${W_DIR}/SRR5273878/sunbeam_output/download
rm ${W_DIR}/SRR5273878/sunbeam_output/download/SRR5273878.fastq.gz /public1/home/scg2154/jxy/rawdata/SRR5273878.sra
```
#### Quality control and assembly
```bash
source activate sunbeam
sunbeam init --data_fp $W_DIR/SRR5273878/sunbeam_output/download $W_DIR/SRR5273878;
sed -i "s/host_fp.*$/host_fp: '\/public1\/home\/scg2154\/ghy\/ref'/g" $W_DIR/SRR5273878/sunbeam_config.yml;
sed -i "s/threads: 4/threads: $Threads/g" $W_DIR/SRR5273878/sunbeam_config.yml;
sunbeam run --configfile $W_DIR/SRR5273878/sunbeam_config.yml all_decontam --cores $Threads;
sunbeam run --configfile $W_DIR/SRR5273878/sunbeam_config.yml all_assembly --cores $Threads;
conda deactivate
rm -r $W_DIR/SRR5273878/sunbeam_output/download $W_DIR/SRR5273878/sunbeam_output/qc/0* $W_DIR/SRR5273878/sunbeam_output/qc/cleaned $W_DIR/SRR5273878/sunbeam_output/qc/log ${W_DIR}/SRR5273878/sunbeam_output/download
mv $W_DIR/SRR5273878/sunbeam_config.yml $W_DIR/SRR5273878/samples.csv -t $W_DIR/SRR5273878/sunbeam_output
```
### Filter for contigs
#### Get the id of contigs (>1.5kb or circular)
```bash
mkdir $W_DIR/SRR5273878/filter_contig
python ${python_dir}circular.py $W_DIR/SRR5273878/sunbeam_output/assembly/contigs/SRR5273878-contigs.fa $W_DIR/SRR5273878/ 
awk '{print $1}' $W_DIR/SRR5273878/filter_contig/circular_long.txt > $W_DIR/SRR5273878/filter_contig/id.txt
```
#### Get the sequences of there contigs
```bash
seqtk subseq $W_DIR/SRR5273878/sunbeam_output/assembly/contigs/SRR5273878-contigs.fa $W_DIR/SRR5273878/filter_contig/id.txt > $W_DIR/SRR5273878/filter_contig/for_virsoter.fa 
```
### Virsorter2 for detecting prophages
```bash
source activate vs2
virsorter config --set HMMSEARCH_THREADS=$Threads
virsorter run -w $W_DIR/SRR5273878/vsout -i $W_DIR/SRR5273878/filter_contig/for_virsoter.fa --min-length 10000 -j $Threads all --keep-original-seq
source deactivate
```
### CheckV for detecting prophages and assessing the phage completeness
```bash
export CHECKVDB=/public1/home/scg2154/ghy/database/checkV
mkdir $W_DIR/SRR5273878/checkV
checkv end_to_end $W_DIR/SRR5273878/vsout/final-viral-combined.fa $W_DIR/SRR5273878/checkV -t $Threads
cd $W_DIR/SRR5273878/checkV
grep "host" $W_DIR/SRR5273878/checkV/contamination.tsv|awk '{print $1"\t"$9"\t"$11}'> $W_DIR/SRR5273878/checkV/checkV_prophage.txt
```
### Bowtie2 mapping for calcualting the coverage of these contigs
```bash
mkdir $W_DIR/SRR5273878/filter_contig/bowtie2
bowtie2-build $W_DIR/SRR5273878/filter_contig/for_virsoter.fa $W_DIR/SRR5273878/filter_contig/bowtie2/index
bowtie2 -p $Threads -x $W_DIR/SRR5273878/filter_contig/bowtie2/index -1 $W_DIR/SRR5273878/sunbeam_output/qc/decontam/SRR5273878_1.fastq.gz -2 $W_DIR/SRR5273878/sunbeam_output/qc/decontam/SRR5273878_2.fastq.gz -S $W_DIR/SRR5273878/filter_contig/bowtie2/out.sam
samtools view -bS $W_DIR/SRR5273878/filter_contig/bowtie2/out.sam |samtools view -b -F 4|samtools sort -@ $Threads > $W_DIR/SRR5273878/filter_contig/bowtie2/mapped.sorted.bam
samtools index $W_DIR/SRR5273878/filter_contig/bowtie2/mapped.sorted.bam
rm $W_DIR/SRR5273878/filter_contig/bowtie2/out.sam
```
### Detect active prophages
#### Binning and calculate coverage
```bash
bedtools bamtobed -i $W_DIR/SRR5273878/filter_contig/bowtie2/mapped.sorted.bam > $W_DIR/SRR5273878/filter_contig/bowtie2/mapped.sorted.bed
python ${python_dir}seq.py $W_DIR/SRR5273878/vsout/final-viral-combined.fa $W_DIR/SRR5273878/filter_contig/for_virsoter.fa ###extract the virus_contig which is partial or complete
samtools faidx $W_DIR/SRR5273878/SRR5273878_seq.fa
awk '{n=int($2/1000);for(i=0;i<=n+1;i++){print $1"\t"i*1000+1"\t"(1+i)*1000}}' $W_DIR/SRR5273878/SRR5273878_seq.fa.fai > $W_DIR/SRR5273878/contig.1k.bedgraph
bedtools coverage -a $W_DIR/SRR5273878/contig.1k.bedgraph -b $W_DIR/SRR5273878/filter_contig/bowtie2/mapped.sorted.bam |cut -f 1-4 >  $W_DIR/SRR5273878/1k_cov.txt
mkdir $W_DIR/SRR5273878/coverage
mv $W_DIR/SRR5273878/SRR5273878_seq.fa $W_DIR/SRR5273878/contig.1k.bedgraph $W_DIR/SRR5273878/1k_cov.txt $W_DIR/SRR5273878/SRR5273878_seq.fa.fai $W_DIR/SRR5273878/SRR5273878.txt -t $W_DIR/SRR5273878/coverage
```
#### Define the bins to be prophage or bacteria
```bash
awk '{print $1"\t0\t"$2}' $W_DIR/SRR5273878/coverage/SRR5273878_seq.fa.fai > $W_DIR/SRR5273878/coverage/contig_length.txt
grep "partial" $W_DIR/SRR5273878/vsout/final-viral-score.tsv |awk -F '|' '{print $1}' |while read id;do grep $id $W_DIR/SRR5273878/vsout/final-viral-boundary.tsv >> $W_DIR/SRR5273878/vsout/partial.tsv;done;
awk '{print $1"\t"$4"\t"$5}' $W_DIR/SRR5273878/vsout/partial.tsv > $W_DIR/SRR5273878/vsout/trim_vsout.txt
if [ ` cat $W_DIR/SRR5273878/checkV/checkV_prophage.txt |wc -l `!=1 ];then
Rscript ${python_dir}trim_checkV.r $W_DIR/SRR5273878/;fi
python ${python_dir}site.py $W_DIR/SRR5273878/
python ${python_dir}interaction.py $W_DIR/SRR5273878/
mkdir $W_DIR/SRR5273878/R_plot
Rscript ${python_dir}plot.r $W_DIR/SRR5273878/
```
#### Calculate the fold change of active propahge compared with its surrounding genome
```bash
mkdir $W_DIR/SRR5273878/ratio
Rscript ${python_dir}partial_bed.r $W_DIR/SRR5273878/ SRR5273878 ##Select the upstream 10k and downstream 10k of the prophage
sed -i 's/\"//g' $W_DIR/SRR5273878/ratio/partial.bed
sed -i 's/ /\t/g' $W_DIR/SRR5273878/ratio/partial.bed
samtools bedcov $W_DIR/SRR5273878/ratio/partial.bed $W_DIR/SRR5273878/filter_contig/bowtie2/mapped.sorted.bam > $W_DIR/SRR5273878/ratio/partial_counts.txt
sed -i 's/ /\t/g' $W_DIR/SRR5273878/ratio/partial_counts.txt
Rscript ${python_dir}ratio.r $W_DIR/SRR5273878/
```
### Run metabat2 for metagenome binning 
```bash
mkdir $W_DIR/SRR5273878/bin
jgi_summarize_bam_contig_depths --outputDepth $W_DIR/SRR5273878/bin/depth.txt $W_DIR/SRR5273878/filter_contig/bowtie2/mapped.sorted.bam
metabat2 -m 1500 -t $Threads -i $W_DIR/SRR5273878/filter_contig/for_virsoter.fa -a $W_DIR/SRR5273878/bin/depth.txt -o $W_DIR/SRR5273878/bin/Bin -v
rm $W_DIR/SRR5273878/bin/depth.txt
```
### CheckM for assigning taxonamy to bins and assessing the quality of bins
```bash
mkdir $W_DIR/SRR5273878/checkM
checkm tree_qa $W_DIR/SRR5273878/checkM/ -o 1 > $W_DIR/SRR5273878/checkM/checkM.txt
checkm lineage_set $W_DIR/SRR5273878/checkM $W_DIR/SRR5273878/checkM/bin_marker.txt
checkm analyze $W_DIR/SRR5273878/checkM/bin_marker.txt $W_DIR/SRR5273878/bin $W_DIR/SRR5273878/checkM/analyze -x fa
checkm qa $W_DIR/SRR5273878/checkM/bin_marker.txt $W_DIR/SRR5273878/checkM/analyze > $W_DIR/SRR5273878/checkM/bin_quality.txt
source deactivate
grep "Bin" $W_DIR/SRR5273878/checkM/bin_quality.txt | sed '1d'|awk '{if($13 > 50 && $14 < 10) print $1}' > $W_DIR/SRR5273878/checkM/afterQC_bin.txt
grep "Bin" $W_DIR/SRR5273878/checkM/checkM.txt | sed '1d'|awk '/p_/||/g_/{print $1"\t"$4}' > $W_DIR/SRR5273878/checkM/tmp.txt
```
### Merge prophages predicted by checkV and virsorter2
```bash
cat $W_DIR/SRR5273878/ratio/ratio.txt | awk '{print $1}'|sed 's/"//g' > $W_DIR/SRR5273878/ratio/prophage_id.txt
cat $W_DIR/SRR5273878/ratio/prophage_id.txt |while read line; do
find $W_DIR/SRR5273878/bin/ -maxdepth 1 -name "*fa"|xargs grep -w $line |awk -F ':' '{print $1}'|awk -F '/' '{print $NF}'|awk -F '.' '{print $1"."$2}' > $W_DIR/SRR5273878/ratio/tmp.txt
if test -s $W_DIR/SRR5273878/ratio/tmp.txt; then awk '{print line"\t"$0}' line=$line $W_DIR/SRR5273878/ratio/tmp.txt>> $W_DIR/SRR5273878/ratio/bin_prophage.txt;fi;done
sed -i 's/"//g' $W_DIR/SRR5273878/ratio/ratio.txt
python ${python_dir}taxonamy.py $W_DIR/SRR5273878/checkM/
mv $W_DIR/SRR5273878/checkM/out_put.csv $W_DIR/SRR5273878/checkM/out_put_withoutQC.csv
grep -wf $W_DIR/SRR5273878/checkM/afterQC_bin.txt $W_DIR/SRR5273878/checkM/out_put_withoutQC.csv > $W_DIR/SRR5273878/checkM/out_put.csv
sed -i '1s/^/Index,Bin,phylum,genus\n/' $W_DIR/SRR5273878/checkM/out_put.csv
Rscript ${python_dir}tax_ratio.r $W_DIR/SRR5273878/
```
### The information of lysogen contigs
```bash
mkdir $W_DIR/SRR5273878/prophage
awk '{print $1}' $W_DIR/SRR5273878/checkV/quality_summary.tsv|sed '1d'|awk -F '|' '{print $1}'|while read  id; do bin=` grep -w $id $W_DIR/SRR5273878/bin/*fa |awk -F ':' '{print $1}'|awk -F '/' '{print $NF}' `;ehcho -e $id"\t"$bin >> $W_DIR/SRR5273878/prophage/contig.txt;done;
cat $W_DIR/SRR5273878/vsout/final-viral-score.tsv |sed '1d'|awk '{print $1}'|awk -F '|' '{print $1"\t"$3}''> $W_DIR/SRR5273878/prophage/contig2.txt
awk '{print $10"\t"$3}' $W_DIR/SRR5273878/checkV/quality_summary.tsv |sed '1d'> $W_DIR/SRR5273878/prophagee/contig3.txt
paste $W_DIR/SRR5273878/prophage/contig.txt $W_DIR/SRR5273878/prophage/contig3.txt > $W_DIR/SRR5273878/prophage/contig4.txt
a=` Rscript ${python_dir}merge.r $W_DIR/SRR5273878/prophage/ |awk '{print $2}' `
echo -e "Completness10_Prophage_Number\t"$a >> $W_DIR/SRR5273878/prophage/CONTIG.txt
rm $W_DIR/SRR5273878/prophage/contig*.txt
awk '{if($3=="Yes"){print $1"\t"$3"\t"$8"\t"$10}}' $W_DIR/$line/SRR5273878/checkV/quality_summary.tsv > $W_DIR/SRR5273878/prophage/prophage_checkV.txt
grep "partial" $W_DIR/SRR5273878/vsout/final-viral-score.tsv |awk '{print $1}' > $W_DIR/SRR5273878/prophage/prophage_vsout.txt
Overlap=` grep -wf $W_DIR/SRR5273878/prophage/prophage_vsout.txt $W_DIR/SRR5273878/prophage/prophage_checkV.txt|wc -l `
echo -e "CheckV_Vs2_Overlap_Number\t"$Overlap >> $W_DIR/SRR5273878/prophage/CONTIG.txt
mv $W_DIR/SRR5273878/prophage/CONTIG.txt $W_DIR/SRR5273878/prophage/CONTIG_withoutBinQC.txt
grep -wf $W_DIR/SRR5273878/checkM/afterQC_bin.txt $W_DIR/SRR5273878/prophage/CONTIG_withoutBinQC.txt > $W_DIR/SRR5273878/prophage/CONTIG.txt
sed -i '1s/^/Contig_ID Bin Completeness CheckV Vsout\n/' $W_DIR/SRR5273878/prophage/CONTIG.txt
```












