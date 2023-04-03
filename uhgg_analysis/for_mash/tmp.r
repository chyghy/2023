Proportion<-function(x,y){
df1<-read.delim(x,header=F)
df2<-read.delim("/public1/home/scg2154/jxy/uhgg/donnot_delete/plot_tmp/taxonamy.txt",header=T,sep="")

df2[,c("d","p","c,","o","f","g","s")]<-str_split_fixed(df2$Lineage,";",7)
df2<-df2%>%select(Genome,g)
