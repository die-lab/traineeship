#!/bin/sh

cat ~/genome.fasta/SRA_tabella | awk '{print $1}' | tail -n +2 | sed '/^$/d' | head -9 > list_of_species.txt

for analyzed_species in `cat list_of_species.txt`
do species=`echo $analyzed_species | sed 's/_/ /g' | awk '{print $1}'`
sex=`echo $analyzed_species | sed 's/_/ /g' | awk '{print $2}'`

#mkdir $species"_"$sex
#cd $species"_"$sex
#cp /media/storage/diegocarli/mirbase/alternative_mirna/alternative_mirna.sh .
name=$species"_"$sex
SRA_entries=`grep $name /home/diegocarli/genome.fasta/SRA_tabella | awk '{print $2}' | sed 's/,/ /g'`
echo $name
echo $SRA_entries > SRA
sed -i 's/ /\n/g' SRA
for i in `cat SRA`
do timeout 10 fastq-dump --defline-seq '@$sn[_cds     $rn]/$ri' --split-files $SRA_entries
head -12 *.fastq >> $name".fq"
rm *.fastq
done
#echo $species $sex >> ../results.txt
#cat percentage_of_mapped >> ../results.txt
#echo >> ../results.txt
#rm -r *
#cd ..

done
