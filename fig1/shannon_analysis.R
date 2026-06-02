library(tidyverse)
library(vegan)
library(betapart)
library(pairwiseAdonis)
library(ggplot2)
library(ggstatsplot)
library(utf8)
library(MNM)

pdf("shannon_analysis.pdf")
beta_metadata <- read_tsv("blas_metadata.tsv")

shannon_mx <- read_tsv("shannon_matrix") %>% 
  column_to_rownames(var = "ESCG") %>% t()

set.seed(91297)
distancias_smx <- as.matrix(vegdist(shannon_mx, method = "bray"))
metadist_smx <- as.data.frame(distancias_smx) %>% mutate(Metagenome=rownames(distancias_smx)) %>%
  inner_join(beta_metadata, by = "Metagenome")

nmds_smx <- metaMDS(comm = distancias_smx, trymax = 1000)
stressplot(nmds_smx)
ecotype <- as.factor(metadist_smx$Geography)

mod_dispersion <- betadisper(d = as.dist(distancias_smx),group = ecotype, type = "median", bias.adjust = TRUE)
mod_dispersion

site.scrs <- as.data.frame(scores(nmds_smx, display = "sites"))
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
	#ggforce::geom_mark_ellipse(aes(label = Site, color = Site),con.cap = 0) +
	scale_color_manual(values=c("dark blue","purple","dark green"),guide="none") +
	scale_x_discrete(breaks=c("Antarctic Dry Valley","Antarctic Peninsula and Islands","Subantarctic Islands"),labels=c("CD","AP","SI")) +
	ggtitle("Shannon NMDS") +
	theme_bw() +
	theme(plot.title = element_text(hjust = 0.5)) +
	theme(aspect.ratio=1)

sdmx_pwadonis_test <- pairwise.adonis2(distancias_smx~Geography, metadist_smx ,perm = 1000)

sdmx_pvalues <- as.numeric()
sdmx_pvalues["AntarcticPeninsulaandIslands_vs_AntarcticDryValley"] <-sdmx_pwadonis_test$`Antarctic Peninsula and Islands_vs_Antarctic Dry Valley`$`Pr(>F)`[1]
sdmx_pvalues["AntarcticPeninsulaandIslands_vs_SubantarcticIslands"] <- sdmx_pwadonis_test$`Antarctic Peninsula and Islands_vs_Subantarctic Islands`$`Pr(>F)`[1]
sdmx_pvalues["AntarcticDryValley_vs_SubantarcticIslands"] <- sdmx_pwadonis_test$`Antarctic Dry Valley_vs_Subantarctic Islands`$`Pr(>F)`[1]

sdmx_pvalues <- as.data.frame(sdmx_pvalues) %>% 
  mutate(padjustvalues = p.adjust(sdmx_pvalues, method = "fdr")) %>% 
  mutate(sig_diff=ifelse(padjustvalues<0.05, "different", "non appreciable difference"))

sdmx_pvalues

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
	title = "Multivariate homogeinity of group dispersions",
        centrality.plotting = TRUE,
	point.args = list(position = ggplot2::position_jitterdodge(dodge.width = 0.6), alpha = 1, size = 3, stroke = 0, na.rm = TRUE),
        violin.args = list(width = 0.5, linewidth = 0.2, alpha = 0.2, na.rm = TRUE),
	boxplot.args = list(width = 0.3, alpha = 0.2, na.rm = TRUE),
        ggtheme = ggplot2::theme_bw() + ggplot2::theme(text = element_text(colour = "black",size = 10,vjust = 0.5, hjust = 0.5),title = element_text(colour = "black",size = 10)),,
        ggsignif.args = list(textsize = 3, tip_length = 0.01, na.rm = TRUE),
	ggplot.component = list(ggplot2::scale_color_manual(values=c("dark blue","purple","dark green"),guide="none"),ggplot2::scale_x_discrete(breaks=c("Antarctic Dry Valley","Antarctic Peninsula and Islands","Subantarctic Islands"),labels=c("CD","AP","SI"))),
)
statplot

mvCsample <- mv.Csample.test(
	shannon_mx,
	g = ecotype,
	score = "r",
	stand = "o",
	method = "p",
	n.sim = 1000,
	na.action = na.fail,
)
print(mvCsample)

# --- Custom Pairwise Post-hoc Function ---
pairwise_mv_posthoc <- function(X, g, ...) {
  # Ensure g is a factor
  g <- as.factor(g)
  groups <- levels(g)
  
  # Generate all possible pairs
  pairs <- combn(groups, 2, simplify = FALSE)
  results <- data.frame()
  
  for (p in pairs) {
    # Subset the matrix and the grouping factor for the current pair
    idx <- g %in% p
    X_sub <- X[idx, , drop = FALSE]
    g_sub <- droplevels(g[idx])
    
    # Use mv.Csample.test for the two groups
    test_res <- mv.Csample.test(X = X_sub, g = g_sub, ...)
    
    results <- rbind(results, data.frame(
      Group1 = p[1],
      Group2 = p[2],
      p_val = test_res$p.value
    ))
  }
  
  # Adjust p-values using FDR
  results$p_adj <- p.adjust(results$p_val, method = "fdr")
  results$significance <- ifelse(results$p_adj < 0.05, "*", "ns")
  
  return(results)
}

# Run the pairwise test
# shannon_mx: your Sites x 43 genes matrix
# ecotypes: your vector of ecotype labels
posthoc_results <- pairwise_mv_posthoc(shannon_mx, ecotype, score = "r", stand = "o", method = "p")
print(posthoc_results)

# 1. Calculate the mean Shannon index across all 43 genes for each site
shannon_summary <- data.frame(
  Avg_Shannon = rowMeans(shannon_mx),
  Ecotype = as.factor(ecotype)
)

# 2. Plot with ggstatsplot (matches your previous style)
ggbetweenstats(
  data = shannon_summary,
  x = Ecotype,
  y = Avg_Shannon,
  type = "np",               
  pairwise.display = "s",   
  p.adjust.method = "fdr",
  centrality.plotting = TRUE,
  title = "Multivariate Shannon Index Comparison",
  ylab = "Mean Shannon Index (43 genes)",
  xlab = "Ecotype",
  point.args = list(position = ggplot2::position_jitterdodge(dodge.width = 0.6), alpha = 1, size = 3, stroke = 0, na.rm = TRUE),
  violin.args = list(width = 0.5, linewidth = 0.2, alpha = 0.2, na.rm = TRUE),
  boxplot.args = list(width = 0.3, alpha = 0.2, na.rm = TRUE),
  ggtheme = ggplot2::theme_bw() + ggplot2::theme(text = element_text(colour = "black",size = 10,vjust = 0.5, hjust = 0.5),title = element_text(colour = "black",size = 10)),,
  ggsignif.args = list(textsize = 3, tip_length = 0.01, na.rm = TRUE),
  ggplot.component = list(ggplot2::scale_color_manual(values=c("dark blue","purple","dark green"),guide="none"),ggplot2::scale_x_discrete(breaks=c("Antarctic Dry Valley","Antarctic Peninsula and Islands","Subantarctic Islands"),labels=c("CD","AP","SI"))),
)

dev.off()
