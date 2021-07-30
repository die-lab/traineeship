PITA_threshold <- -9

curr_smith <- scan(file="../curr_smith.in",what=character(),quiet=TRUE)

curr_smith_pita_results.tab <- read.table(file=paste("../",curr_smith,"_pita_results.tab",sep=""),header=TRUE,as.is=TRUE)
curr_smith_pita_results.tab <- curr_smith_pita_results.tab[curr_smith_pita_results.tab$ddG <= PITA_threshold,]
write.table(curr_smith_pita_results.tab,file=paste("../",curr_smith,"_pita_results.tab",sep=""),quote=FALSE,sep="\t",eol="\n",row.names=FALSE)
