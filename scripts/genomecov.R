genomecov.temp <- scan(file="../genomecov.temp",what=character(),quiet=TRUE)

bed.col.names <- c("chrom","chromStart","chromEnd","name","score","strand")

genomecov.folder <- genomecov.temp[1]
genomecov.clusters <- genomecov.temp[2:length(genomecov.temp)]

dev.new(units="in",width=16,height=9)
par(mfrow=c(2,2),pty="m")

for (c in 1:length(genomecov.clusters)) {
	total.genomecov <- read.table(file=paste("../",genomecov.folder,"/",genomecov.clusters[c],".genomecov",sep=""),header=FALSE,sep="\t",col.names=c("chr","chrPos","depth"),as.is=1)
	total.genomecov.5 <- read.table(file=paste("../",genomecov.folder,"/",genomecov.clusters[c],".genomecov.5",sep=""),header=FALSE,sep="\t",col.names=c("chr","chrPos","depth"),as.is=1)
	total.genomecov.3 <- read.table(file=paste("../",genomecov.folder,"/",genomecov.clusters[c],".genomecov.3",sep=""),header=FALSE,sep="\t",col.names=c("chr","chrPos","depth"),as.is=1)

	total.genomecov <- total.genomecov[total.genomecov$depth != 0,]
	total.genomecov.5 <- total.genomecov.5[total.genomecov.5$depth != 0,]
	total.genomecov.3 <- total.genomecov.3[total.genomecov.3$depth != 0,]

	min.pos <- min(c(total.genomecov$chrPos,total.genomecov.5$chrPos,total.genomecov.3$chrPos))
	max.pos <- max(c(total.genomecov$chrPos,total.genomecov.5$chrPos,total.genomecov.3$chrPos))

	strand <- NA

	bedfile <- read.table(file=paste("../",genomecov.folder,"/",genomecov.clusters[c],".sorted.bed",sep=""),header=FALSE,sep="\t",col.names=bed.col.names,as.is=TRUE)
	bedreads <- bedfile$name

	for (r in 1:length(bedreads)) {
		if (length(bedreads[bedreads == bedreads[r]]) > 1) message(paste("WARNING (cluster ",genomecov.clusters[c],"): ",length(bedreads[bedreads == bedreads[r]])," reads bear the same name (",bedreads[r],")!",sep=""))
		}

	if (all(bedfile$strand == "+")) {
		strand <- "Plus"
		xlimits <- c(min.pos,max.pos)
		}
		else if (all(bedfile$strand == "-")) {
		strand <- "Minus"
		xlimits <- c(max.pos,min.pos)
		}
		else {
		strand <- "Plus"
		xlimits <- c(min.pos,max.pos)
		message(paste("WARNING (cluster ",genomecov.clusters[c],"): ",length(bedfile$strand[bedfile$strand == "+"])," reads were annotated on the plus strand, but ",length(bedfile$strand[bedfile$strand == "-"])," reads were annotated on the minus strand!",sep=""))
		}

	min.depth <- 0
	max.depth <- max(c(total.genomecov$depth,total.genomecov.5$depth,total.genomecov.3$depth))

	plot(total.genomecov$chrPos,total.genomecov$depth,type="l",lty=2,col=rgb(86,83,30,maxColorValue=255),main=paste("Cluster C",genomecov.clusters[c],": coverage",sep=""),xlab="Position on mtDNA",ylab="Coverage",xlim=xlimits,ylim=c(min.depth,max.depth),las=2,xaxp=c(min.pos,max.pos,max.pos-min.pos))
	rect(total.genomecov.5$chrPos-0.45,0,total.genomecov.5$chrPos+0.45,total.genomecov.5$depth,border="forestgreen",col=rgb(34,139,34,128,maxColorValue=255))
	rect(total.genomecov.3$chrPos-0.45,0,total.genomecov.3$chrPos+0.45,total.genomecov.3$depth,border="firebrick4",col=rgb(139,26,26,128,maxColorValue=255))

#	dev.copy2pdf(file=paste("../output.R/",genomecov.clusters[c],".genomecov.pdf",sep=""))
	}
