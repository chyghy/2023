args=commandArgs(T)
library(dplyr)
file1 <- read.table(paste0(args[1],"ratio/partial_counts.txt"),sep = "\t",header=F,stringsAsFactors = F)
contig_name <- unique(file1$V1)
ratio_matrix<-data.frame(contig= character(),pro_up=numeric(),pro_down=numeric(),stringsAsFactors = F)
j<-1
for (i in c(1:length(contig_name))){
    tmp_file1<-filter(file1, V1 == contig_name[i])
    if (nrow(tmp_file1)==2){
        if (tmp_file1[1,]$V4=="up"){
        ratio_matrix[j,]<-c(contig_name[i],(tmp_file1[2,5]/(tmp_file1[2,3]-tmp_file1[2,2]))/(tmp_file1[1,5]/(tmp_file1[1,3]-tmp_file1[1,2])),"NA")
j<-j+1
        }else {
            ratio_matrix[j,]<-c(contig_name[i],"NA",(tmp_file1[1,5]/(tmp_file1[1,3]-tmp_file1[1,2]))/(tmp_file1[2,5]/(tmp_file1[2,3]-tmp_file1[2,2])))
j<-j+1
        }
    }
    else{
        ratio_matrix[j,]<-c(contig_name[i],(tmp_file1[2,5]/(tmp_file1[2,3]-tmp_file1[2,2]))/(tmp_file1[1,5]/(tmp_file1[1,3]-tmp_file1[1,2])),(tmp_file1[2,5]/(tmp_file1[2,3]-tmp_file1[2,2]))/(tmp_file1[3,5]/(tmp_file1[3,3]-tmp_file1[3,2])))
j<-j+1
    }
    }
colnames(ratio_matrix)<-c("contig","pro_up","pro_down")
ratio_matrix$pro_up<-as.numeric(ratio_matrix$pro_up)
ratio_matrix$pro_down<-as.numeric(ratio_matrix$pro_down)
write.table(ratio_matrix,file=paste0(args[1],"ratio/ratio.txt"),row.names = FALSE, col.names = TRUE)
