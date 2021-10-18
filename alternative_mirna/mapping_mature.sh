#1/bin/bash

#perform a serch for homologies between *fastq mapping on mirna precursor* and *mature_mirna_file*

#retrieve some variables, for running as standalone script
organism=DrMe
mature_mirna=$organism"_mirna_mature"
mature_mirna_file=$organism"_mirna_mature.fa"

#first, gotta create a db that fits blast requirements.
mkdir $mature_mirna
mv $mature_mirna_file $mature_mirna
cd $mature_mirna
makeblastdb –in $mature_mirna_file –dbtype nucl –parse_seqids
cd ..

#merge all the fastq files in one (still don't know if it is better to work whith the merged fastq or with each one separately
cat *.precu.mapped.fastq > $organism.precu.tot.mapped.fastq
mkdir $organism.precu.mapped
mv *.precu.mapped.fastq $organism.precu.mapped

paste - - - - < $organism.precu.tot.mapped.fastq | cut -f 1,2 | sed 's/^@/>/' | tr "\t" "\n" > $organism.precu.tot.mapped.fa


#search homologies using blastn
blastn –db $mature_mirna/$mature_mirna_file –query $organism.precu.tot.mapped.fa –out homologies
