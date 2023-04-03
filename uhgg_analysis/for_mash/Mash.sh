source activate fastani
n=1
for i in `cat downsample_5000_0.txt`;do
n=$(($n+1))
sed -n ''"$n"',$p' downsample_5000_0.txt > tmp.txt
for j in `cat tmp.txt`;do
mash dist $i $j >> bin_Mash_result2.txt;done;done
conda deactivate

#Then remove the Mash equal to 1 and the output filename format is filter*.txt
###Collate the output###
ls filter_*|while read id;do awk -F "seqs/" '{print $2"\t"$3}' $id |awk -F "_" '{print $1"\t"$2}'|awk '{print $1"\t"$4}' > ID.txt;awk '{print $3}' $id > value.txt; paste ID.txt value.txt > ../$id;done

