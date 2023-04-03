library(dplyr)
library(stringr)

df1<-read.delim("All_prophage_Num.txt",header=F)
df2<-df1%>%group_by(Num = cut(V2,c(-Inf,0,1,2,3,4,Inf))) %>% summarise(n=n())
write.table(df2,"prophage_num_group.txt",row.names = F,col.names = T,quote = F)

df3<-read.delim("All_bin_size.txt",header=F)
df4<-merge(df1,df3,by="V1")
df4$Lysogen[df4$V2.x==0]<-"No"
df4$Lysogen[df4$V2.x!=0]<-"Yes"
colnames(df4)[1:3]<-c("ID","Prophage_num","Bin_size")

df5<-read.delim("taxonamy.txt",header=T,sep="")
df6<-merge(df4,df5,by.x="ID",by.y="Genome",all.x=T)
df6[,c("d","p","c,","o","f","g","s")]<-str_split_fixed(df6$Lineage,";",7)
df6 <- df6%>%select(c("ID","Prophage_num","Bin_size","Lysogen","p","g","s"))
write.table(df6,"All.txt",row.names = F,col.names = T,quote = F,sep="\t")