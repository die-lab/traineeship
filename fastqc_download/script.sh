#!/bin/bash

c=0

for sra in `cat SRA_tabella | awk '{print $3}'`

do c=$(( $c + 1 ))

mkdir $c
cd $c

SRA_entries=`echo $sra | sed 's/,/ /g'`

fastq-dump --defline-seq '@$sn[_cds$rn]/$ri' --split-files $SRA_entries
echo $SRA_entries 
echo $c

fastqc *fastq
rm *.fastq

cd ..

done


