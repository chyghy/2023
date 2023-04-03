i=0
j=1
mkdir -p batch/$j
ls uhgg|while read id;do
i=$((i+1));
if [[ $((i%500)) -ne 0 ]];then
mv uhgg/$id batch/$j
else
mv uhgg/$id batch/$j
j=$((j+1))
mkdir batch/$j
fi
done