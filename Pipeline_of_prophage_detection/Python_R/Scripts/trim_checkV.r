args=commandArgs(T)
table1<-read.table(paste0(args[1],"checkV/checkV_prophage.txt"),sep="\t",header=T,stringsAsFactor=F)
library(tidyverse)
Location<-separate(data = table1,col =region_coords_bp , into = c("R1", "R2"), sep = ",")[,c("R1","R2")]
Type<-separate(data = table1,col =region_types, into = c("T1", "T2"), sep = ",")[,c("T1","T2")]
T1<-which(Type$T1=="viral")
T2<-which(Type$T2=="viral")
Loc<-c(Location[T1,1],Location[T2,2])
seqname<-c(table1[T1,1],table1[T2,1])
TrimV<-data.frame(seqname,Loc)
TrimV<-separate(data = TrimV,col =Loc , into =c("trim_bp_start","trim_bp_end"), sep = "-")
TrimV$seqname<-sub("\\|.*", "", TrimV$seqname)
write.table(TrimV,file=paste0(args[1],"checkV/trimV.txt"),col.names=F,row.names=F,quote=F,sep="\t")
