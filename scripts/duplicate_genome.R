library(seqinr)

genome.file <- scan(file="../genome_mit.fa",what=character(),quiet=TRUE)
genome.mit <- read.fasta(file=paste("../",genome.file,sep=""),seqtype="DNA",forceDNAtolower=FALSE,strip.desc=TRUE)
genome.length <- length(genome.mit[[1]])
write.fasta(rep(genome.mit[[1]],2),names=getName(genome.mit)[1],file.out=paste("../",genome.file,sep=""),open="w",nbchar=genome.length*2)
