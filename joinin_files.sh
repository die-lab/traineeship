#!/bin/bash

type=.fna.prova

for i in *_split
do cd $i 

n_pieces=`ls | wc -l`
echo ""
echo "working on "$n_pieces" pieces of "${i%_split}

if [ -f ../${i%_split}$type ]
then rm -r ../${i%_split}$type
fi

c=1
while [ $c -le $n_pieces ] 
do cat $c"_"$i >> ../${i%_split}$type 
c=$(( $c +1 ))
done
cd .. 

done
echo ""

