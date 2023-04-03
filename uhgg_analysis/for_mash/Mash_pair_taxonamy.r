library(dplyr)
library(stringr)
library(ggplot2)

###taxonamy_ANI###
taxonamy_ANI<-function(x,y){
    df1<-read.delim(x,header=F)
    df2<-read.delim("/public1/home/scg2154/jxy/uhgg/donnot_delete/plot_tmp/taxonamy.txt",header=T,sep="")

    df2[,c("d","p","c,","o","f","g","s")]<-str_split_fixed(df2$Lineage,";",7)
    df2<-df2%>%select(Genome,p,g)%>%mutate(P_new=ifelse(grepl("Firmicutes",p),"p__Firmicutes",p))

    df_tmp<-left_join(df1,df2,by=c("V1"="Genome"))
    df_tmp2<-left_join(df_tmp,df2,by=c("V2"="Genome"))

    df_tmp2$Same_Phylum<-ifelse(df_tmp2$P_new.x==df_tmp2$P_new.y,"Yes","No")
    df_tmp2$Same_Genus<-ifelse(df_tmp2$g.x==df_tmp2$g.y,"Yes","No")

    write.csv(df_tmp2,paste0("table_",y,".txt"),row.names=F,quote=F)
}

j=0
for (i in list.files(pattern="^filter"))
{taxonamy_ANI(i,j)
j<-j+1}


###Location_ANI###
Location_ANI<-function(x,y){
df1<-read.delim(x,header=F)
df2<-read.delim("/public1/home/scg2154/jxy/uhgg_all/uhgg/donnot_delete/plot_tmp/location.txt",header=T,sep="\t")

df_tmp<-left_join(df1,df2,by=c("V1"="Genome"))
df_tmp2<-left_join(df_tmp,df2,by=c("V2"="Genome"))

df_tmp2$Same_Continent<-ifelse(df_tmp2$Continent.x==df_tmp2$Continent.y,"Yes","No")
df_tmp2$Same_Country<-ifelse(df_tmp2$Country.x==df_tmp2$Country.y,"Yes","No")

write.csv(df_tmp2,paste0("Location_",y,".txt"),row.names=F,quote=F)
}

j=0
for (i in list.files(pattern="^filter"))
{Location_ANI(i,j)
j<-j+1}
