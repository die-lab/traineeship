#!/bin/bash

#to roduce stats usefuls for the analyses
#to run in tha main directory, so ../BedFiles

#as the $1 argument take the file of which u need to know the number of lines
#as the second argument write "paired" for paired reads, otherwise write "single"

to_analyze="*1."$1
layout=$2
remove_flag=$3

echo "the layout of your reads is set to "$layout", ctrl +c if it is not, and change this parameter."

sleep 10

if [ $layout == "paired" ]
then
echo "non hai ancora preparato la parte per le reads in paired mode, quindi vedi di farlo"
echo "stats on "$to_analyze >> stats_of_analyses.txt
for i in $to_analyze
do all=`wc -l $i | awk '{print $1}'`
echo $(( $all / 4 )) >> stats_of_analyses.txt
done
to_analyze2="*2."$1
echo "stats on "$to_analyze2 >> stats_of_analyses.txt
for i in $to_analyze2
do all=`wc -l $i | awk '{print $1}'`
echo $(( $all / 4 )) >> stats_of_analyses.txt
done
else
echo "stats on "$to_analyze >> stats_of_analyses.txt
for i in $to_analyze
do all=`wc -l $i | awk '{print $1}'`
echo $(( $all / 4 )) >> stats_of_analyses.txt
done
fi

if [ $remove_flag == "remove" ]
then 
rm $to_analyze $to_analyze2
else
echo "non ho rimosso nulla"
fi
