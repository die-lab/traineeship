#!/bin/bash

organism=MuMu
precursor_mirna=$organism"_mirna_precursor"

for infile in *1.trim.kraken2.fastq

do fastq_tomap=$infile
echo $fastq_tomap
sleep 5
prefile=${infile%.trim.kraken2.fastq}.precursor.sam
echo $prefile
sleep 5
mapped_precu_fastq=${infile%.trim.kraken2.fastq}.precu.mapped.fastq
echo $mapped_precu_fastq
echo $fastq_tomap
head $fastq_tomap
sleep 5
bowtie2 -x ../$precursor_mirna/$precursor_mirna -q $fastq_tomap -S $prefile -N 1 -i C,1 -L 18
echo $prefile
head $prefile
num_tot=`wc -l $fastq_tomap | awk '{print $1}'`
num_tot=$(( $num_tot / 4 ))
sleep 5
samtools view -b -F 4 $prefile > $mapped_precu_bam
echo $mapped_precu_bam
bedtools bamtofastq -i $mapped_precu_bam -fq $mapped_precu_fastq
num_mapped=`wc -l $mapped_precu_fastq`
echo tot $num_tot
echo mapped $num_mapped
echo $mapped_precu_fastq
head $mapped_precu_fastq

done
echo "fine del debugging"


#GGCUGCUUGGGUUCCUGGCAUGCUGAUUUGUGACUUGAGAUUAAAAUCACAUUGCCAGGGAUUACCACGCAACC
#questa sequenza è presa direttamente da MuMu_mirna_precursor
#inseriscila tra le sequenze da mappare per vedere se la trova (la allinea).


