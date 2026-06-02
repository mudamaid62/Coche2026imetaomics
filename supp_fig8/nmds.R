library(tidyverse)
library(ggplot2)
library(vegan)
set.seed(139808)

pdf("mf_go_terms.pdf")

table <- read.table("input_mf_go_matrix", header=T)
community_matrix <- as.data.frame(table)
#ecotype <- c("Feces","Feces","Feces","Feces","Sewage","Sewage","Sewage","Feces","WWTP","WWTP","WWTP","Soil","Soil","Soil","Cold_desert_soil","Cold_desert_soil","Soil","Soil","Cold_desert_soil","Cold_desert_soil","Cold_desert_soil","Soil","Soil","Soil","Soil","Cold_desert_soil","Cold_desert_soil","Cold_desert_soil","Soil","Natural_water","Natural_water","Natural_water","Soil","Soil","Soil","Marine_water","Marine_water","Marine_water")
#continent <- c("Europe","Africa","Africa","North_America","North_America","Africa","South_America","North_America","Europe","Asia","Asia","Maritime_Antarctica","Maritime_Antarctica","Maritime_Antarctica","Cold_Desert_Antarctica","Cold_Desert_Antarctica","Australia","North_America","Cold_Desert_Antarctica","Cold_Desert_Antarctica","Cold_Desert_Antarctica","Maritime_Antarctica","Maritime_Antarctica","Maritime_Antarctica","Maritime_Antarctica","Cold_Desert_Antarctica","Cold_Desert_Antarctica","Cold_Desert_Antarctica","North_America","Europe","South_America","Asia","Europe","Europe","Asia","Ocean","Ocean","Ocean")
#ug <- c(rep("no",14), "RD","RU", rep("no",22))
example_NMDS=metaMDS(community_matrix, k=2, trymax=10000, autotransform = FALSE)
stressplot(example_NMDS)

matrix.spp.fit <- envfit(example_NMDS, community_matrix, permutations = 999) # this fits species vectors
site.scrs <- as.data.frame(scores(example_NMDS, display = "sites")) #save NMDS results into dataframe

spp.scrs <- as.data.frame(scores(matrix.spp.fit, display = "vectors")) #save species intrinsic values into dataframe
spp.scrs <- cbind(spp.scrs, Species = rownames(spp.scrs)) #add species names to dataframe
spp.scrs <- cbind(spp.scrs, pval = matrix.spp.fit$vectors$pvals) #add pvalues to dataframe so you can select species which are significant
sig.spp.scrs <- subset(spp.scrs, pval<=0.05) #subset data to show species significant at 0.05
sig.spp.scrs

ecotype.nmds.data <- 
  tibble(
    NMDS1 = site.scrs$NMDS1,
    NMDS2 = site.scrs$NMDS2,
    #Ecotype = ecotype,
    #Continent = continent,
    #UG = ug,
  )
ecotype.nmds.data

ecotype.nmds.data |> 
  ggplot(aes(x=NMDS1, y=NMDS2)) +
  #geom_point(aes(color = Ecotype, shape = Continent), size = 3) +
  #ggforce::geom_mark_ellipse(aes(fill = Ecotype,label = Ecotype, color = Ecotype),con.cap = 0) +
  #stat_ellipse(aes(color = Ecotype)) +
  #scale_color_manual(values = c(Feces = "#4B0076", WWTP = "#D30000", Sewage ="#FEBE00", Soil = "#FD6A00", Cold_desert_soil = "#000080", Natural_water = "#0A6522", Marine_water= "#2B1700")) +
  #scale_shape_manual(values = c(Africa = 18, Asia = 17, Australia = 10, Cold_Desert_Antarctica = 19, Europe = 9, Maritime_Antarctica = 15, North_America = 7, Ocean = 8, South_America = 13)) + 
  #ggforce::geom_mark_ellipse(aes(filter = UG == "RD", description = "RD")) +
  #ggforce::geom_mark_ellipse(aes(filter = UG == "RU",description = "RU")) +
  ggtitle("NMDS of GO-terms") + 
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(aspect.ratio=1)

dev.off()

