#!/bin/sh
type=fna
size=25
unit=MB

ls -lh --block-size=$unit *.$type> tmp1
awk '{print $5,$9}' tmp1 > tmp2
awk '{print $5}' tmp1 > tmp3

for i in `cat tmp3`
	do a=`echo $i | sed 's/MB//'`
	name=`grep $a tmp2| sed 's/.\+ //'`
	echo " "$name" ha "$a"MB di roba"
	dir=${name%.fna}"_split"
	
	if [ -d $dir ]
	then rm -r $dir
	fi
	mkdir $dir
	
	to_divide_in=$(( ($a / $size) +1 ))

	lines_tot=`cat $name | wc -l`
	linesxtext=$(( $lines_tot / $to_divide_in))
 	echo "Ogni pezzo avrà "$linesxtext" righe"
	echo " "
	
	c=1	
	while [ $c -le $to_divide_in ]
       	do 
       	#echo $c" di "$linesxtext" righe"
       	to=$(( $c * $linesxtext ))
       	from=$(( (($c - 1) * $linesxtext ) + 1 ))
       	       	
       	head -n +$to $name | tail -n +$from > $dir/$c"_"$dir  
       	#sleep 5
	c=$(( $c + 1 ))
       	done

	done
	
rm tmp1 tmp2 tmp3

#notes:
#1.Per trovare a quale file è associata la grandezza presa nel ciclo in for utilizzo un grep. Quindi potrebbe essere un problema nel malaugurato caso ci siano due files con la stessa identica grandezza.
