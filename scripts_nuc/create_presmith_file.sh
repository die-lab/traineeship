#!/bin/bash

size=$1

if [ $# -eq 0 ]
  then
    echo "No size argument supplied"
    echo "Give the size as an argument to the script"
    exit 1
fi

grep ">" smithRNAs.fa > smithRNAs_name.txt

for a in `cat smithRNAs_name.txt`
do echo $a > tmp
start=`sed 's/_/ /g' tmp | awk '{print $3}'`
end=`sed 's/_/ /g' tmp | awk '{print $4}'`
export start end size

python3 - <<'END_SCRIPT'

import os
pstart=int(os.environ["start"])
pend=int(os.environ["end"])

#check if start comes before end
if (pstart < pend):
	print("tutto ok!")
else:
	print("posizioni invertite, inversione in corso")
	tmp=pend
	pend=pstart
	pstart=tmp
	
size=int(os.environ["size"])
size_half=size/2

half=int((pstart+pend)/2)
new_start=int(half-size_half)
new_end=int(new_start+size)

with open("new_positions.txt", "a") as new_pos:
	new_pos.write(str(new_start) + "\t" + str(new_end) + "\n")
new_pos.close()

END_SCRIPT

done

#generate the presmithRNAs.region.list
paste smithRNAs_name.txt new_positions.txt > pre_smithRNA_regions.list
sed -i 's/^>/pre/g' pre_smithRNA_regions.list

rm new_positions.txt
rm smithRNAs_name.txt

rm tmp
