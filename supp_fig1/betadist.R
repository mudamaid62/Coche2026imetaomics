library(tidyverse)
library(vegan)
library(betapart)
library(pairwiseAdonis)
library(ggplot2)
library(ggstatsplot)
library(utf8)

pdf("beta_diversity.pdf")
beta_metadata <- read_tsv("blas_metadata.tsv")

beta_mx <- read_tsv("familiy_betadistance_matrix.tsv") %>% 
  column_to_rownames(var = "taxonomy") %>% t()

set.seed(91297)
distancias_bmx <- as.matrix(vegdist(beta_mx, method = "bray"))
metadist_bmx <- as.data.frame(distancias_bmx) %>% mutate(Metagenome=rownames(distancias_bmx)) %>%
  inner_join(beta_metadata, by = "Metagenome")

nmds_bmx <- metaMDS(comm = distancias_bmx, trymax = 1000)
ecotype <- as.factor(metadist_bmx$Geography)
stressplot(nmds_bmx)
gof <- goodness(nmds_bmx)
gof
plot(nmds_bmx, display = "sites", type = "n", cex = 0.7)
points(nmds_bmx, display = "sites", cex = 2*gof/mean(gof))

mod_dispersion <- betadisper(d = as.dist(distancias_bmx),group = ecotype, type = "median", bias.adjust = TRUE)
mod_dispersion

site.scrs <- as.data.frame(scores(nmds_bmx, display = "sites"))
ecotype.nmds.data <-
  tibble(
    NMDS1 = site.scrs$NMDS1,
    NMDS2 = site.scrs$NMDS2,
    Site = ecotype,
  )
ecotype.nmds.data

ecotype.nmds.data |>
	ggplot(aes(x=NMDS1, y=NMDS2)) +
	geom_point(aes(color = Site), size = 4) +
	ggforce::geom_mark_ellipse(aes(label = Site, color = Site),con.cap = 0) +
	scale_color_manual(values=c("dark blue","purple","dark green"),guide="none") +
	scale_x_discrete(breaks=c("Antarctic Dry Valley","Antarctic Peninsula and Islands","Subantarctic Islands"),labels=c("CD","AP","SI")) +
	ggtitle("Family NMDS") +
	theme_bw() +
	theme(plot.title = element_text(hjust = 0.5)) +
	theme(aspect.ratio=1)

bdmx_pwadonis_test <- pairwise.adonis2(distancias_bmx~Geography, metadist_bmx ,perm = 1000)

bdmx_pvalues <- as.numeric()
bdmx_pvalues["AntarcticPeninsulaandIslands_vs_AntarcticDryValley"] <-bdmx_pwadonis_test$`Antarctic Peninsula and Islands_vs_Antarctic Dry Valley`$`Pr(>F)`[1]
bdmx_pvalues["AntarcticPeninsulaandIslands_vs_SubantarcticIslands"] <- bdmx_pwadonis_test$`Antarctic Peninsula and Islands_vs_Subantarctic Islands`$`Pr(>F)`[1]
bdmx_pvalues["AntarcticDryValley_vs_SubantarcticIslands"] <- bdmx_pwadonis_test$`Antarctic Dry Valley_vs_Subantarctic Islands`$`Pr(>F)`[1]

bdmx_pvalues <- as.data.frame(bdmx_pvalues) %>% 
  mutate(padjustvalues = p.adjust(bdmx_pvalues, method = "fdr")) %>% 
  mutate(sig_diff=ifelse(padjustvalues<0.05, "different", "non appreciable difference"))

bdmx_pvalues

test_dispersion <- permutest(mod_dispersion, permutations = 999)
print(test_dispersion)
TukeyHSD(mod_dispersion, conf.level = 0.95)

dispersion_df <- data.frame(
	distance = mod_dispersion$distances,
	ecotype = mod_dispersion$group
)
statplot <- ggbetweenstats(
	dispersion_df,
        x = ecotype,
        y = distance,
        plot.type = "boxviolin",
        type = "np",
        xlab = "Ecotype",
        ylab = "Distance to centroid",
        pairwise.comparisons = TRUE,
        pairwise.display = "s",
        p.adjust.method = "fdr",
        centrality.plotting = TRUE,
	point.args = list(position = ggplot2::position_jitterdodge(dodge.width = 0.6), alpha = 1, size = 3, stroke = 0, na.rm = TRUE),
        violin.args = list(width = 0.5, linewidth = 0.2, alpha = 0.2, na.rm = TRUE),
	boxplot.args = list(width = 0.3, alpha = 0.2, na.rm = TRUE),
        ggtheme = ggplot2::theme_bw() + ggplot2::theme(text = element_text(colour = "black",size = 10,vjust = 0.5, hjust = 0.5),title = element_text(colour = "black",size = 10)),,
        ggsignif.args = list(textsize = 3, tip_length = 0.01, na.rm = TRUE),
	ggplot.component = list(ggplot2::scale_color_manual(values=c("dark blue","purple","dark green"),guide="none"),ggplot2::scale_x_discrete(breaks=c("Antarctic Dry Valley","Antarctic Peninsula and Islands","Subantarctic Islands"),labels=c("CD","AP","SI"))),
)
statplot

dev.off()
