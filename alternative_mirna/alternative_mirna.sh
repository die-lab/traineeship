#!/bin/sh


#premessa: questo script dovrebbe riconoscere i mirna andando a mappare le fastq del campione preso in esame contro la banca dati di tutti i mirna riconosciuti per quel determinato organismo.
#dopo la parte di filtraggio ci si ricollega ai mappaggi di 01.core, per prendere solo le reads che si originano dal mitocondrio. Facendo così non ho trovato nula, ovvero nessuna reads originatesi dal mitocondrio che mappasse sui precursori dei mirna riconosciuti. Sono stato più fortunto nel caso in cui ho provato a mappare direttamente le reads filtrate sulla banca dati dei precursori mirna, senza passare per core.

organism=DrMe
sex=female
output=$organism"_results"

#next value True or False. In True case it will run the analyses looking for mirna only between sequence originated from mitochondria. Those are found whith the 01.core.sh pipeline
enable_mitounique=False

#next value True or False. If True the script will keep only sequences shorter then 27 and longer then 14, according to the paper.
#I suggest to  leave the value as False, 'cause the filtering script in python, added later, accounts also for the length check.
check_length=False


genome_mit=$organism"_mit_doubled"
genome_mit_file=$organism"_mit.fasta"
genome_nuc=$organism"_nuc"
genome_nuc_file=$organism"_nuc.fna"

precursor_mirna=$organism"_mirna_precursor"
precursor_mirna_file=$organism"_mirna_precursor.fa"
mature_mirna=$organism"_mirna_mature"
mature_mirna_file=$organism"_mirna_mature.fa"

#se la specie analizzata ha pi genomi mitocondriali, ossia uno per sesso, decomenntare la riga seguente e commentare quella per il mitocondriale).
#genome_mit_file=$organism"_mit"_$sex".fasta"

adapter_file="illumina.adapters.fa"
kraken2_db="kraken_20210616"
num_threads=12
cluster_threshold=200

#si riprende i genomi mitocondriali e nucleari dalla cartella apposita in base alla specie settata. Commenta se li hai inseriti a mano. E gli adapters.
cp /home/diegocarli/genome.fasta/$genome_mit_file .
cp /media/storage/diegocarli/nuc_genome/$genome_nuc_file .
cp /home/diegocarli/$adapter_file .
cp /media/storage/diegocarli/mirbase/mirna_precursor/$precursor_mirna_file .
cp /media/storage/diegocarli/mirbase/mirna_mature/$mature_mirna_file .

cp /home/diegocarli/scripts_nuc/duplicate_genome.R .
cp /home/diegocarli/scripts_nuc/remove_duplicate_region.R .
cp /home/diegocarli/scripts_nuc/01.core.modificato.sh .

#getting rRNA database from web
wget https://www.arb-silva.de/fileadmin/silva_databases/release_138.1/Exports/SILVA_138.1_SSURef_NR99_tax_silva.fasta.gz
wget https://www.arb-silva.de/fileadmin/silva_databases/release_138.1/Exports/SILVA_138.1_LSURef_NR99_tax_silva.fasta.gz
gzip -d SILVA_138.1_SSURef_NR99_tax_silva.fasta.gz
gzip -d SILVA_138.1_LSURef_NR99_tax_silva.fasta.gz

cat SILVA_138* >> rRNA_database.fa
rm SILVA_138*

rrna_database="rRNA_database"
rrna_database_file="rRNA_database.fa"

#getting tRNA databse from storage

cp /media/storage/diegocarli/nuc_genome/tRNA_database.fa .

trna_database="tRNA_database"
trna_database_file="tRNA_database.fa"

#le SRA corrette devono essere scritte nel file con il percorso visibile qua sotto (SRA_tabella). Commenta e decommenta quello sotto se preferisci inserirle a mano.
#oppure commenta entrambi e inserisci i file fastq a mano nella directory.
SRA_entries=`grep $organism"_"$sex /home/diegocarli/genome.fasta/SRA_tabella | awk '{print $2}' | sed 's/,/ /g'`
#SRA_entries="SRR3S3M910"

conf_temp=conf.temp
genomecov_temp=genomecov.temp

echo $output > output.basename
echo $genome_mit > genome_mit.db
echo $genome_mit_file > genome_mit.fa
echo $genome_nuc > genome_nuc.db


##duplication of mitochondrial genome
if [ -d R ]
	then rm -r R
	fi
mkdir R
cd R
 Rscript ../duplicate_genome.R
cd ..
rm -r R

##create indexed genomes for bowtie
bowtie2-build -f $genome_mit_file $genome_mit
bowtie2-build -f $genome_nuc_file $genome_nuc
bowtie2-build -f $precursor_mirna_file $precursor_mirna
bowtie2-build -f $rrna_database_file $rrna_database
bowtie2-build -f $trna_database_file $trna_database

##create directories and move files
if [ -d $genome_mit ]
	then rm -rf $genome_mit
	fi
mkdir $genome_mit

if [ -d $genome_nuc ]
	then rm -rf $genome_nuc
	fi
mkdir $genome_nuc

if [ -d $precursor_mirna ]
	then rm -rf $precursor_mirna
	fi
mkdir $precursor_mirna

if [ -d $rrna_database ]
then rm -rf $rrna_database
fi
mkdir $rrna_database

if [ -d $trna_database ]
then rm -rf $trna_database
fi
mkdir $trna_database


mv $genome_mit.* $genome_mit
if [ -f $genome_mit_file ]
	then mv $genome_mit_file $genome_mit
	fi
mv $genome_nuc.* $genome_nuc
if [ -f $genome_nuc_file ]
	then mv $genome_nuc_file $genome_nuc
	fi

mv $precursor_mirna.* $precursor_mirna
if [ -f $precursor_mirna_file ]
	then mv $precursor_mirna_file $precursor_mirna
	fi

mv $rrna_database.* $rrna_database
if [ -f $rrna_database ]
	then mv $rrna_database $rrna_database
	fi

mv $trna_database.* $trna_database
if [ -f $trna_database ]
	then mv $trna_database $trna_database
	fi

##downloading reads
fastq-dump --defline-seq '@$sn[_cds	$rn]/$ri' --split-files $SRA_entries

##filtering reads
cp /home/diegocarli/$adapter_file .

for fastq in *.fastq
	do java -jar /opt/Trimmomatic-0.38/trimmomatic-0.38.jar SE -threads $num_threads $fastq ${fastq%.fastq}.trim.fastq ILLUMINACLIP:$adapter_file:2:30:10 AVGQUAL:20 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20
	done
rm $adapter_file

for fastq in *.trim.fastq
	do kraken2 --db /media/storage/dbs/$kraken2_db --threads $num_threads --use-names --report kraken2.report --classified-out ${fastq%.trim.fastq}.cont.fastq --unclassified-out ${fastq%.trim.fastq}.trim.kraken2.fastq --output kraken2.out $fastq
	done

#fastqc *.trim.kraken2.fastq

##filtering out only reads that are shorter then 27 nt and longer then 14 nt, following instruction of the paper.
if [ "$check_length" = True ]
then
for i in *.trim.kraken2.fastq
        do
        echo "tengo solamente le sequenze >14 e <27 nt di " $i
        not_filtered=`wc -l $i  | awk '{print $1}'`
	cat $i | awk '{y= i++ % 4 ; L[y]=$0; if(y==3 && length(L[1])<=27 && length(L[1])>=14) {printf("%s\n%s\n%s\n%s\n",L[0],L[1],L[2],L[3]);}}' > $i.fastq
	mv $i.fastq $i
	right_length=`wc -l $i  | awk '{print $1}'`
	echo "di " $i " passano il filtro di lunghezza "$right_length >> percentage_of_mapped
        echo "($right_length/$not_filtered)" | bc -l >> percentage_of_mapped
        done
else 
echo "jumpin' length check step in bash"
fi

##formatting header on fastq
num_fastq=`ls *.trim.kraken2.fastq | grep -c trim\.kraken2\.fastq`
num_curr_fastq=0

while [ $num_curr_fastq -lt $num_fastq ]
	do num_curr_fastq=$(( num_curr_fastq+1 ))
	curr_fastq=`ls *.trim.kraken2.fastq | sed -n ''$num_curr_fastq' p'`
	sed -i '1~4 s/^@/@'$num_curr_fastq'_/g' $curr_fastq
	done

#01.core.pipeline
if [ "$enable_mitunique" = True ]
then

##mapping (detect only reads mapped on the mito, and not on the nuclear genoma).
sh 01.core.modificato.sh


##la parte seguente riguarda il rimappaggio sul genoma "giusto", quindi con le eventuali regioni a cavallo tra inizio e fine del genoma mitocondriale, su cui mappano le fastq.

mv genome_mit.fa BedFiles
cp remove_duplicate_region.R BedFiles

cd BedFiles

#Prepara la cartella di R

mkdir R

#Concatena i file .bed e ne costruisce uno unico, che mette in ordine.

cat *.bed > total.bed
bedtools sort -i total.bed > total.sorted.bed
rm total.bed

#Esegue uno script R che va a cercare l'ultima riga in cui ci sono mappature di read che cominciano prima della fine del genoma mitocondriale non duplicato e toglie tutte le righe successive.

cd R
Rscript ../remove_duplicate_region.R
cd ..

rm total.sorted.bed

cd ..

genome_mit="mit_emp"
genome_mit_file=`cat genome_out.out`

bowtie2-build -f $genome_mit_file $genome_mit

if [ -d $genome_mit ]
	then rm -rf $genome_mit
	fi
mkdir $genome_mit
mv $genome_mit.* $genome_mit
mv $genome_mit_file $genome_mit

echo $genome_mit > genome_mit.db
echo $genome_mit_file > genome_mit.fa

sh 01.core.modificato.sh

cd BedFiles

rm *Cluster.csv
rm *Map.bed

fi


if [ "$enable_mitounique" = True ]
then

for infile in *Multi_MitoUnique.bam
	do fastq_tomap=${infile%.trim.kraken2.fastq_Multi_MitoUnique.bam}.MitoUnique.fastq
	prefile=${infile%.trim.kraken2.fastq_Multi_MitoUnique.bam}.precursor.sam
	mapped_precu_sorted_bam=${infile%.trim.kraken2.fastq_Multi_MitoUnique.bam}.precu.mapped.sorted.bam
	mapped_precu_bam=${infile%.trim.kraken2.fastq_Multi_MitoUnique.bam}.precu.mapped.bam
	mapped_precu_fastq=${infile%.trim.kraken2.fastq_Multi_MitoUnique.bam}.precu.mapped.fastq
	bedtools bamtofastq -i $infile -fq $fastq_tomap
	bowtie2 -x ../$precursor_mirna/$precursor_mirna -q $fastq_tomap -S $prefile -N 1 -i C,1 -L 18
	num_tot=`wc -l $fastq_tomap | awk '{print $1}'`
	samtools sort $mapped_precu_bam -o $mapped_precu_sorted_bam
	samtools view -b -F 4 $prefile > $mapped_precu_bam
	bedtools bamtofastq -i $mapped_precu_sorted_bam -fq $mapped_precu_fastq
	num_mapped=`wc -l $mapped_precu_fastq  | awk '{print $1}'`
	echo tot $num_tot
	echo mapped $num_mapped
	echo $mapped_precu_fastq "/" $infile >> percentage_of_mapped
	echo "($num_mapped/$num_tot)" | bc -l >> percentage_of_mapped
	cat percentage_of_mapped
	done
else
for infile in *1.trim.kraken2.fastq
	do fastq_tomap=$infile
	prefile=${infile%.trim.kraken2.fastq}.precursor.sam
	mapped_precu_bam=${infile%.trim.kraken2.fastq}.precu.mapped.bam
	mapped_precu_sorted_bam=${infile%.trim.kraken2.fastq_Multi_MitoUnique.bam}.precu.mapped.sorted.bam
	mapped_precu_fastq=${infile%.trim.kraken2.fastq}.precu.mapped.fastq
	bowtie2 -x $precursor_mirna/$precursor_mirna -q $fastq_tomap -S $prefile -N 1 -i C,1 -L 18
	num_tot=`wc -l $fastq_tomap | awk '{print $1}'`
	samtools view -b -F 4 $prefile > $mapped_precu_bam
	samtools sort $mapped_precu_bam -o $mapped_precu_sorted_bam
	bedtools bamtofastq -i $mapped_precu_sorted_bam -fq $mapped_precu_fastq
	num_mapped=`wc -l $mapped_precu_fastq  | awk '{print $1}'`
	echo tot $num_tot
	echo mapped $num_mapped
	echo $mapped_precu_fastq "/" $infile >> percentage_of_mapped
	echo "($num_mapped/$num_tot)" | bc -l >> percentage_of_mapped
	cat percentage_of_mapped
	done
fi







