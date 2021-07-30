#!/bin/sh

path="federicoplazzi@137.204.139.103:/media/storage/federicoplazzi/small_transcriptomes/HoSa_results/female/female/BedFiles"
output="HoSa_results"
pre_dG=$output.RNAfold

scp $path/../*.log .
scp $path/../*.html .
scp $path/pre_smithRNAs.* .
scp $path/*smithRNAs.fa .
scp $path/*.target.fa .
scp -r $path/output.R .
scp -r $path/$pre_dG .
scp $path/../../Transcriptome/*.log .
scp $path/../../Transcriptome/*.html .
scp $path/../../Transcriptome/*_trinity.Trinity.fasta .
