#!/bin/bash

for i in *_split
do cd $i 

n_pieces=`ls | wc -l`
echo ""
echo "working on "$n_pieces" pieces of "${i%_split}

if [ -f ../${i%_split}.fna ]
then rm -r ../${i%_split}.fna
fi

c=1
while [ $c -le $n_pieces ] 
do cat $c"_"$i >> ../${i%_split}.fna 
c=$(( $c +1 ))
done
cd .. 

done
echo ""

