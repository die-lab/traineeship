#!/bin/bash

#script per creare un fasta unico dal fasta scaricabile da ncbi, diviso in scaffold.
#lo script assume che il genoma mitocondriale è messo come ultimo contigs nel fasta passato.

mito_line=`grep -n "mitocho" $1 | sed 's/\([0-9]\+\):.\+/\1/'`
n=$(( $mito_line - 1 ))
head -n +$n $1 > tmp
cat tmp > $1
rm tmp

sed -i '0,/>/s//@/' $1
sed -i '/--/d' $1
sed -i '/>/d' $1

echo $1 >tmp
name=`cat tmp`
rm tmp 

sed -i 's/>.\+/>\'$name'/' $1
sed -i 's/.fna//' $1

#sed -e '/^[^>]/s/[^ATGC]/X/g' 
