args=commandArgs(T)
file1 <- read.table(paste0(args[1],"coverage/",args[2],".txt"),sep = "\t",header=T,stringsAsFactors = F)
file2 <- read.table(paste0(args[1],"coverage/trim_all_u.txt"),sep = "\t",header=T,stringsAsFactors = F)
library(dplyr)
file3 <- merge(file1, file2, by.x = "ID", by.y = "seqname",all=F)
partial.bed<-data.frame(contig= character(), start=numeric(), end=numeric(), Class = character(),stringsAsFactors=F)
Region<-10000
j=1
for (i in c(1:dim(file3)[1])){
	            if(file3[i,]$trim_bp_start != 1){
			                                if (file3[i,]$trim_bp_start > Region){partial.bed[j,]<-c(file3[i,]$ID,file3[i,]$trim_bp_start - Region,file3[i,]$trim_bp_start-1,"up")
j<-j+1}
        else{partial.bed[j,]<-c(file3[i,]$ID,1,file3[i,]$trim_bp_start-1,"up")
j<-j+1}
	            }
    partial.bed[j,]<-c(file3[i,]$ID,file3[i,]$trim_bp_start,file3[i,]$trim_bp_end,"partial")
j<-j+1
            if (file3[i,]$trim_bp_end != file3[i,]$Contig2){
		                            if ((file3[i,]$Contig2-file3[i,]$trim_bp_end)>Region){partial.bed[j,]<-c(file3[i,]$ID,file3[i,]$trim_bp_end+1,file3[i,]$trim_bp_end+Region,"down")
j<-j+1}
                else{partial.bed[j,]<-c(file3[i,]$ID,file3[i,]$trim_bp_end+1,file3[i,]$Contig2,"down")
j<-j+1}
		                }
}
colnames(partial.bed)<-c("contig","start","end","class")
partial.bed$start<-as.numeric(partial.bed$start)
partial.bed$end<-as.numeric(partial.bed$end)
write.table(partial.bed,file=paste0(args[1],"ratio/partial.bed"),row.names = FALSE, col.names = FALSE)
