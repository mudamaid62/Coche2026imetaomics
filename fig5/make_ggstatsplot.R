
datos <- read.table("repeated_measures_BLA_class_table", header=T)
library(ggplot2)
library(ggstatsplot)
attach(datos)

df <- data.frame(BLA,Abundance)

statplot <- ggwithinstats(
	data = df, 
	x = BLA, 
	y = Abundance, 
	plot.type = "boxviolin",
	type = "np", 
	xlab = "BLA Class",
	ylab = "BLA abundance (copies/cell)",
	pairwise.comparisons = TRUE, 
	pairwise.display = "s", 
	p.adjust.method = "BH",
	centrality.plotting = TRUE,
	notch = FALSE,
)
statplot
#statplot + scale_x_discrete(breaks=c("A","B1","B2","B3","C","D"),labels=c("A\n(n = 81)","B1\n(n = 81)","B2\n(n = 81)","B1\n(n = 81)"))

ggsave("corrected_figure_5A.pdf",device="pdf",width = 20, height = 20, dpi = 300, unit = "cm")
