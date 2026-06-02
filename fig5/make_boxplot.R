pdf("richness_boxplot.pdf")

datos <- read.table("richness_table", header=T)
attach(datos)
names(datos)
summary(datos)
library(ggplot2)
pg<-datos
a <- ggplot(pg,aes(x=Geografic_site,y=Richness,fill=Geografic_site)) +
scale_x_discrete(breaks=c("1DV","2API","3SI"),labels=c("DV","API","SI"))
a + geom_boxplot(outlier.colour="black",outlier.size=3) +
scale_fill_manual(values=c("#FF6700","#990f4B","#8080ff"),guide="none") +
labs(x="Environmental Type",y="Richness") +
theme_bw() +
theme(axis.title.y=element_text(angle=90,face="bold",size=20),axis.title.x=element_text(angle=0,face="bold",size=20,colour="black"),axis.text.x=element_text(colour="black",size=rel(2)),axis.text.y=element_text(colour="black",size=rel(2)))

dev.off()
