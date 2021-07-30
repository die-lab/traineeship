library(seqinr)

bed.col.names <- c("chrom","chromStart","chromEnd","name","score","strand","clusterID")
read.length.hist.col <- "royalblue4"
alignment.check.checkpoints <- 20

alignment.check <- scan(file="alignment_check.in",what=character(),quiet=TRUE)

conf.temp <- scan(file="../conf.temp",what=character(),quiet=TRUE)
output.fa <- read.fasta(file=paste("../",conf.temp[1],sep=""),seqtype="DNA",forceDNAtolower=FALSE,strip.desc=TRUE)
centroid.fa <- read.fasta(file=paste("../",conf.temp[2],sep=""),seqtype="DNA",forceDNAtolower=FALSE,strip.desc=TRUE)
centroid.read.fa <- read.fasta(file=paste("../",conf.temp[3],"/complete.fa",sep=""),seqtype="DNA",forceDNAtolower=FALSE,strip.desc=TRUE)
mit.fa <- read.fasta(file=paste("../",conf.temp[4],sep=""),seqtype="DNA",forceDNAtolower=FALSE,strip.desc=TRUE)
map.bed <- read.table(file=paste("../",conf.temp[5],sep=""),col.names=bed.col.names,as.is=TRUE)
if (length(conf.temp) > 5) {
	for (b in 6:length(conf.temp)) map.bed <- rbind(map.bed,read.table(file=paste("../",conf.temp[b],sep=""),col.names=bed.col.names,as.is=TRUE))
	}

if (alignment.check == TRUE) {
	alignment.check.checkpoint.rows <- round(dim(map.bed)[1]/alignment.check.checkpoints*c(1:alignment.check.checkpoints),digits=0)
	mismatches.aln <- "Mismatches\n"
	for (r in 1:dim(map.bed)[1]) {
		if (length(output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]]) != (map.bed[r,3]-map.bed[r,2])) {
			read.bases <- character()
			alignment.symbols <- character()
			found.mismatches <- 0
			mit.bases <- character()
			for (s in 1:min(length(output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]]),map.bed[r,3]-map.bed[r,2])) {
				read.bases <- paste(read.bases,output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]][s],sep="")
				if (output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]][s] == mit.fa[[1]][(map.bed[r,2]+s)]) {
					alignment.symbols <- paste(alignment.symbols,"|",sep="")
					} else {
					alignment.symbols <- paste(alignment.symbols," ",sep="")
					found.mismatches <- found.mismatches+1
					}
				mit.bases <- paste(mit.bases,mit.fa[[1]][(map.bed[r,2]+s)],sep="")
				}
			mismatches.aln <- paste(mismatches.aln,map.bed[r,4],paste(read.bases," ",length(output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]]),sep=""),paste(alignment.symbols," ",map.bed[r,5],"(",found.mismatches,")",sep=""),paste(mit.bases," ",map.bed[r,3]-map.bed[r,2],sep=""),"\n",sep="\n")
			}
			else if (!any(all(rev(comp(output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]])) == mit.fa[[1]][(map.bed[r,2]+1):map.bed[r,3]]),all(output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]] == mit.fa[[1]][(map.bed[r,2]+1):map.bed[r,3]]))) {
			read.bases <- character()
			alignment.symbols <- character()
			found.mismatches <- 0
			mit.bases <- character()
			for (s in 1:length(output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]])) {
				read.bases <- paste(read.bases,output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]][s],sep="")
				if (output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]][s] == mit.fa[[1]][(map.bed[r,2]+s)]) {
					alignment.symbols <- paste(alignment.symbols,"|",sep="")
					} else {
					alignment.symbols <- paste(alignment.symbols," ",sep="")
					found.mismatches <- found.mismatches+1
					}
				mit.bases <- paste(mit.bases,mit.fa[[1]][(map.bed[r,2]+s)],sep="")
				}
			mismatches.aln <- paste(mismatches.aln,map.bed[r,4],paste(read.bases," ",length(output.fa[attr(output.fa,which="name") == map.bed[r,4]][[1]]),sep=""),paste(alignment.symbols," ",map.bed[r,5],"(",found.mismatches,")",sep=""),paste(mit.bases," ",map.bed[r,3]-map.bed[r,2],sep=""),sep="\n")
			}
		if (r %in% alignment.check.checkpoint.rows) message(paste("Checking alignments. ",round(r/dim(map.bed)[1]*100,digits=0),"% completed.",sep=""))
		}
	if (!mismatches.aln == "Mismatches\n") {
		writeLines(mismatches.aln,con="../mismatches.aln")
		}
	}

dev.new(units="in",width=16,height=9)
par(mfrow=c(1,2),pty="m")

# Length distribution of reads included in all the Multi_MitoUnique.bam files saved to the BedFiles folder, #
# i. e. all reads mapping to the mitochondrial genome, but not to the nuclear one and written to output.fa. #

read.lengths <- numeric()
for (l in 1:length(output.fa)) read.lengths <- c(read.lengths,length(output.fa[[l]]))
unique.read.lengths <- sort(unique(read.lengths))
unique.read.length.count <- numeric()
for (l in 1:length(unique.read.lengths)) unique.read.length.count <- c(unique.read.length.count,length(read.lengths[read.lengths == unique.read.lengths[l]]))
plot(unique.read.lengths,unique.read.length.count,type="l",lty=2,main="Read length distribution",xlab="Read length",ylab="Read count",col=read.length.hist.col)

# Length distribution of selected centroids, i. e. centroids of clusters with at least 200 sequences. #

read.lengths <- numeric()
for (l in 1:length(centroid.read.fa)) read.lengths <- c(read.lengths,length(centroid.read.fa[[l]]))
unique.read.lengths <- sort(unique(read.lengths))
unique.read.length.count <- numeric()
for (l in 1:length(unique.read.lengths)) unique.read.length.count <- c(unique.read.length.count,length(read.lengths[read.lengths == unique.read.lengths[l]]))
plot(unique.read.lengths,unique.read.length.count,type="l",lty=2,main="Selected centroid length distribution",xlab="Centroid length",ylab="Read count",col=read.length.hist.col)

#dev.copy2pdf(file="../output.R/length.hist.pdf")
