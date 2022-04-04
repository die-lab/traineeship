#!/bin/bash

rm clusters_till.txt

organism=$2
output=$organism"_results"

output_fa=$output.fa
output_conf=$conf_temp
genomecov_conf=$genomecov_temp
output_centroids=$output.centroids.fa
output_selected_centroids=$output.centroids.selected.fa
output_clusters=$output.clusters
clusters_bed=$output.clusters.bedfiles
clusters_fasta=$output.clusters.fasta

c=0
maximum=$1

while [ $c -lt $maximum ]

do 

threshold=$(( $maximum - $c ))

python clusters1.py $output_fa $output_centroids.clstr $threshold $clusters_fasta
echo $threshold >> tmp1 
ls $clusters_fasta/*.fa | wc -l >> tmp2

cd $clusters_fasta
for i in `ls`
do grep ">" $i | wc -l | awk '{print $1}' >> tmp_length
done

sum=0
for value in `cat tmp_length`
do sum=$(( $sum + $value ))
done 

number_clusters=`ls *.fa | wc -l`
echo $(( $sum / $number_clusters )) >> ../tmp3

rm tmp_length
cd ..

rm $clusters_fasta/*.fa 

c=$(( $c + 1 ))
done

paste tmp1 tmp2 tmp3 > clusters_till.txt
rm tmp*
