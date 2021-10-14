#!/bin/bash

number=1

for i in *.fastq
do 

sed -i '1~4 s/^@/>/g' $i

n=600000
#n=`grep ">" $i| wc -l | awk '{print $1}'` 

c=0
while [ $c -lt $n ]
do c=$(( $c + 1 ))
#going_down=$(( $n -$c ))
#sum=$(( $c + $going_down ))

echo "working on "$c" of "$n", file number "$number
sed -i 's/>'$c'/>'$c'_'$going_down'_'$number'/g' $i
done

c=$(( $c + 1 ))
done
