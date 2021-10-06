library(seqinr)

doubled.genome.file <- scan(file="../genome_mit.fa",what=character(),quiet=TRUE)
doubled.genome.mit <- read.fasta(file=paste("../",doubled.genome.file,sep=""),seqtype="DNA",forceDNAtolower=FALSE,strip.desc=TRUE)
genome.length <- length(doubled.genome.mit[[1]])/2
total.sorted.bed <- read.table(file="../total.sorted.bed",header=FALSE,as.is=TRUE)
total.sorted.bed <- total.sorted.bed[total.sorted.bed[,2] < genome.length,]
max.bases <- max(total.sorted.bed[,3])
if (max.bases > genome.length) {
	exceeding.bases <- max.bases-genome.length
	file.out <- paste("chrMT_",exceeding.bases,"emp.fna",sep="")
	write.fasta(c(doubled.genome.mit[[1]][1:genome.length],doubled.genome.mit[[1]][1:exceeding.bases]),names=getName(doubled.genome.mit)[1],file.out=paste("../../",file.out,sep=""),open="w",nbchar=genome.length+exceeding.bases)
	} else {
	file.out <- "chrMT_0emp.fna"
	write.fasta(doubled.genome.mit[[1]][1:genome.length],names=getName(doubled.genome.mit)[1],file.out=paste("../../",file.out,sep=""),open="w",nbchar=genome.length)
	}
writeLines(file.out,con="../../genome_out.out")
write.table(total.sorted.bed,file="../total.bedfile",quote=FALSE,sep="\t",eol="\n",col.names=FALSE,row.names=FALSE)
