#!/bin/bash

mkdir /media/storage/diegocarli/results_def/$organism"_"$sex/

path="/media/storage/diegocarli/results_def/$organism"_"$sex"

mkdir $path/fastqc
cp *fastqc* $path/fastqc/.

cp stats_of_analyses.txt $path/.
cp local_smithRNAs.fa $path/.
cp grepped_smithRNAs.txt $path/.

cp -r BedFiles/output.R/ $path/.
cp BedFiles/clusters_till.txt $path/.
