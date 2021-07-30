library(seqinr)

conf.temp <- scan(file="../conf.temp",what=character(),quiet=TRUE)
mit.fa <- read.fasta(file=paste("../",conf.temp[4],sep=""),seqtype="DNA",forceDNAtolower=FALSE,strip.desc=TRUE)

genome.file <- paste(getName(mit.fa)[1],length(mit.fa[[1]]),sep="\t")
writeLines(genome.file,con=paste("../",getName(mit.fa)[1],".genome",sep=""))
