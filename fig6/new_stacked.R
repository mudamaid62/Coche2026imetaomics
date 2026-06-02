library(ggplot2)
library(ggthemes)

# create a dataset
col <- c("#73a5fb","#f8809a","#fe9aaf","#ffb7c3","#ffd3d8","#e59257","#c0a637","#dcc05a","#f8db7d","#f37ad5","#82b436","#39be70","#ca8df4","#39c1ad","#5fdac6","#7ff4e1","#3fbbde")
table <- read.table("figure_6A_table", header = T)
rel <- table$rel
bla <- table$bla
Phylum_and_class <- table$Phylum_and_class

data <- data.frame(bla,rel,Phylum_and_class)
	ggplot(data,aes(fill=Phylum_and_class,y=rel,x=bla)) +
		geom_bar(position="stack",stat="identity",color = "black") +
		scale_fill_manual(values=col) +
		theme_classic() +
		#Move Origin
		scale_y_continuous(expand = c(0, 0), limits =c(0,40)) +
		theme(plot.background = element_rect(colour = "black", linewidth = 0)) +
		#theme(legend.background = element_rect(colour = "black", linewidth = 0)) +
		theme(axis.ticks.x = element_line(linewidth = 0)) +
		theme(legend.text = element_text(color= "black", size = 10, hjust=0)) +
		theme(legend.title = element_text(color= "black",size = 12, face ="bold", hjust=0)) +
		theme(panel.background = element_rect(colour = "black", linewidth = 0.3)) +
		theme(axis.title.y = element_text(color= "black", size = 12, vjust=0.5)) +
		theme(axis.title.x = element_text(color= "black", size = 10, hjust=0.5)) +
		theme(axis.text.x = element_text(color= "black", size = 12, angle = 0)) +
		theme(legend.key.size = unit(4, "mm")) +
		#theme(plot.title = element_text(color="black", size = 15, face="bold",hjust=0.5)) +
		xlab("Beta-lactamase class") +
		ylab("Relative abundance (%)")

#ggsave permite cambiar las dimensiones del gráfico completo y especificar el dpi
ggsave("corrected_figure_6A.pdf",device="pdf",width = 17, height = 11, dpi = 300, unit = "cm")
