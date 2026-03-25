#R code for capstone project EDS programme- Yale
#Climate data cleanning
#Gabriela Pena-Bello
#Last modification : 12.03.2026


# Description
 
# My project is to determine the current distribution of oilbirds
#(Steatornis caripensis) in Colombia and assess potential changes under future 
#climate scenarios.

#This current script is for accessing and cleaning the climate data

###############################################################################
#Description of variables
###############################################################################
# Occurrence: Presence and absence of oilbirds
# Climate data: temperature and precipitation derived in bioclimatic variables
#from CHELSA database
#BIO1 = Annual Mean Temperature
#BIO2 = Mean Diurnal Range (Mean of monthly (max temp - min temp))
#BIO3 = Isothermality (BIO2/BIO7) (×100)
#BIO4 = Temperature Seasonality (standard deviation)
#BIO5 = Max Temperature of Warmest Month
#BIO6 = Min Temperature of Coldest Month
#BIO7 = Temperature Annual Range (BIO5-BIO6)
#BIO8 = Mean Temperature of Wettest Quarter
#BIO9 = Mean Temperature of Driest Quarter
#BIO10 = Mean Temperature of Warmest Quarter
#BIO11 = Mean Temperature of Coldest Quarter

#BIO12 = Annual Precipitation
#BIO13 = Precipitation of Wettest Month
#BIO14 = Precipitation of Driest Month
#BIO15 = Precipitation Seasonality (Coefficient of Variation)
#BIO16 = Precipitation of Wettest Quarter
#BIO17 = Precipitation of Driest Quarter
#BIO18 = Precipitation of Warmest Quarter
#BIO19 = Precipitation of Coldest Quarter

################################################################################
#Prepare workspace
###############################################################################
# clear work space
rm(list=ls())

# Set working space
setwd("C:/Users/gabyo/Escritorio/EDS_capstone_R")

#Install and Load  packages
install.packages("pacman") # allows to install and load on same line
library(pacman)

pacman::p_load(
  devtools,# allows to install from web
  # data manipulation
  dplyr,tidyverse, stringr,purrr,readr,
  
  #Packages for visuals
  ggplot2, # graphics
  factoextra,#See PCA
  GGally, # correlation plots
  
  #Packages for spatial data
  terra,sf,tidyterra
  
  #Analysis
  caret,# correlation
  usdm, #VIF and correlation
  FactoMineR, #PCA
  
)

remotes::install_github("HelgeJentsch/ClimDatDownloadR")# Package to extract data 
library(ClimDatDownloadR)
#from CHELSA 

###############################################################################
#Load data
###############################################################################
# Colombia shapefile
path <-"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/climate"
#read political map
COL <- st_read("C:/Users/gabyo/Escritorio/EDS_capstone_R/data/raw_data/colombia/COLOMBIA_LEVEL_1.shp",
               layer = "COLOMBIA_LEVEL_1") # Ithas municipalities
#join municipalities
COL <-st_union(COL)
plot(COL)
extent(COL)#extracts limits of shapefile
#save map
st_write(COL, "C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/colombia/Col.shp")

## Write shapefile clean
COL <- st_read("C:/Users/gabyo/Escritorio/EDS_capstone_R/data//clean_data/colombia/Col.shp")

#extracts bounding box
bb <- st_bbox(COL)
bb
col_limits <- c(bb["xmin"], bb["xmax"], bb["ymin"], bb["ymax"])

######################
#Climate data current
######################

options(timeout =3600)#extend time for download
bioclim_c <- ClimDatDownloadR:: Chelsa.Clim.download(  
                               save.location = path,  
                               version.var = "2.1",  
                               parameter = "bio",  
                               clipping = TRUE,
                               clip.extent = col_limits,  
                               clip.shapefile = COL,
                               convert.files.to.asc = FALSE,  
                               stacking.data = FALSE,  
                               combine.raw.zip = FALSE,  
                               delete.raw.data = TRUE,  
                               save.download.table = TRUE)


path_2 <-"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/raw_data/climate/ChelsaV2.1Climatologies/clipped_2026-03-10_18-04-53"
files_cur <- list.files(path_2, pattern = ".tif$", full.names = TRUE)
bioc_current <- rast(files_cur)
names(bioc_current)
plot(bioc_current) # it was not masked just cut to bounding box

#Mask files to colombia shapefile
bioc_current_m <- terra::mask(bioc_current, COL)
plot(bioc_current_m)

# Change the names to the climate stack 
names(bioc_current_m) <- c("bio_01","bio_02","bio_03","bio_04","bio_05",
                           "bio_06","bio_07", "bio_08","bio_09","bio_10", "bio_11",
                           "bio_12","bio_13","bio_14", "bio_15","bio_16","bio_17",
                           "bio_18","bio_19")

#save mask data
terra::writeRaster(x = bioc_current_m, filename = paste0(path, '/', 'bioc_current_m.tif'), 
                   overwrite = T)

#####################
#climate data future
#####################
# CMIP6 future climate scenario ssp126, optimistic scenario, strong mitigation
#For the GCM i am using MPI-ESM1-2-HR because it shows low deviation to tropical
#temperature and rain observations and stability in simulations
bioc_126<- ClimDatDownloadR:: Chelsa.CMIP_6.download(  
                                save.location = path,  
                                parameter = "bio",
                                emission.scenario.var = "ssp126",
                                time.interval.var = c("2011-2040", "2041-2070",
                                                      "2071-2100"),
                                model.var= "mpi-esm1-2-hr",
                                clipping = TRUE,
                                clip.shapefile = COL,
                                convert.files.to.asc = FALSE,  
                                stacking.data = FALSE,  
                                combine.raw.zip = FALSE,  
                                delete.raw.data = TRUE)

path_3 <-"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/raw_data/climate/ChelsaCMIP6Climatologies/clipped_2026-03-10_20-57-26"
files_126 <- list.files(path_3, pattern = ".tif$", full.names = TRUE)

###Split by time range

## 2041-2070
bioc_126_2040 <- files_126[grep("2041-2070",files_126)]
bioc_126_2040 <- rast(bioc_126_2040 )
names(bioc_126_2040 )

# Change the names to the climate stack 
names(bioc_126_2040) <- c("bio_01","bio_02","bio_03","bio_04","bio_05",
                          "bio_06","bio_07", "bio_08","bio_09","bio_10", "bio_11",
                          "bio_12","bio_13","bio_14", "bio_15","bio_16","bio_17",
                          "bio_18","bio_19")
plot(bioc_126_2040)
#mask to colombia shapefile
bioc_126_2040_m <- terra::mask(bioc_126_2040, COL)

#2071-2100
bioc_126_2071 <- files_126[grep("2071-2100",files_126)]
bioc_126_2071 <- rast(bioc_126_2071 )
names(bioc_126_2071)

# Change the names to the climate stack 
names(bioc_126_2071) <- c("bio_01","bio_02","bio_03","bio_04","bio_05",
                          "bio_06","bio_07", "bio_08","bio_09","bio_10", "bio_11",
                          "bio_12","bio_13","bio_14", "bio_15","bio_16","bio_17",
                          "bio_18","bio_19")
plot(bioc_126_2071)
bioc_126_2071_m <- terra::mask(bioc_126_2071, COL)

#save rasters
terra::writeRaster(x = bioc_126_2040_m, filename = paste0(path, '/', 'bioc_126_2040_m.tif'), overwrite = T)
terra::writeRaster(x = bioc_126_2071_m, filename = paste0(path, '/', 'bioc_126_2071_m.tif'), overwrite = T)

#______________________________________________________
#scenario ssp585 extreme scenario, with high emissions

bioc_585<- ClimDatDownloadR:: Chelsa.CMIP_6.download(  
                              save.location = path,  
                              parameter = "bio",
                              emission.scenario.var = "ssp585",
                              time.interval.var = c("2011-2040", "2041-2070",
                                                   "2071-2100"),
                              model.var= "mpi-esm1-2-hr",
                              clipping = TRUE,
                              clip.shapefile = COL,
                              convert.files.to.asc = FALSE,  
                              stacking.data = FALSE,  
                              combine.raw.zip = FALSE,  
                              delete.raw.data = TRUE,
                              save.bib.file = FALSE)

class(bioc_585)
#object bioc_585 is an integrer need to read raster directly from folder

path_4 <-"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/raw_data/climate/ChelsaCMIP6Climatologies/clipped_2026-03-10_22-03-54"
files_585 <- list.files(path_4, pattern = ".tif$", full.names = TRUE)

###Split by time range

## 2041-2070
bioc_585_2040 <- files_585[grep("2041-2070",files_585)]
bioc_585_2040 <- rast(bioc_585_2040 )
names(bioc_585_2040 )
plot(bioc_585_2040[1])## is recognizing someting as categorical
#modify
levels(bioc_585_2040) <- NULL
plot(bioc_585_2040[1])
# Change the names to the climate stack 
names(bioc_585_2040) <- c("bio_01","bio_02","bio_03","bio_04","bio_05",
                           "bio_06","bio_07", "bio_08","bio_09","bio_10", "bio_11",
                           "bio_12","bio_13","bio_14", "bio_15","bio_16","bio_17",
                           "bio_18","bio_19")
plot(bioc_585_2040)
#mask to colombia shapefile
bioc_585_2040_m <- terra::mask(bioc_585_2040, COL)

#2071-2100
bioc_585_2071 <- files_585[grep("2071-2100",files_585)]
bioc_585_2071 <- rast(bioc_585_2071 )
names(bioc_585_2071)

# Change the names to the climate stack 
names(bioc_585_2071) <- c("bio_01","bio_02","bio_03","bio_04","bio_05",
                            "bio_06","bio_07", "bio_08","bio_09","bio_10", "bio_11",
                            "bio_12","bio_13","bio_14", "bio_15","bio_16","bio_17",
                            "bio_18","bio_19")
plot(bioc_585_2071)
bioc_585_2071_m <- terra::mask(bioc_585_2071, COL)

#save rasters
terra::writeRaster(x = bioc_585_2040_m, filename = paste0(path, '/', 'bioc_585_2040_m.tif'), overwrite = T)
terra::writeRaster(x = bioc_585_2071_m, filename = paste0(path, '/', 'bioc_585_2071_m.tif'), overwrite = T)

#####################
#Load occurence data
#####################
oilbird_occ_f <- read_csv("C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/occurence/oilbird_occf.csv")

summary(oilbird_occ_f )

# filter just present data
oilbird_pre <- oilbird_occ_f %>% 
  filter(occurrenceStatus == "PRESENT")
points <- unique(oilbird_pre$locality)
summary(points)#654

#Extract only coordinates
oilbird_cord <- oilbird_pre[, c("decimalLongitude","decimalLatitude")]
oilbird_cord

###########################################################################
#Spatial redundace
###########################################################################
#For the model we only want 1 occurrence per pixel of raster to avoid spatial
#redundance , that is the reason for the next steps

#Create an empty mask with the pixels
mask <- bioc_current_m[[1]]* 0 + 1
names(mask) <- 'mask'
plot(mask)

# Locate coordinates in pixels
clls <- terra::extract(mask, oilbird_cord, cells = TRUE) 
#transform in table 
clls <- as_tibble(clls)
head(clls)

# Check duplicated cells
vect <- duplicated(clls$cell)
nodup <- oilbird_pre[!vect,]#cells unique
dup <- oilbird_pre[vect,]#cells duplicated
nrow(nodup) #515
nrow(dup) #4949

# Add a column to original database stating if is duplicated
dup <- dup %>% mutate(class = 'Duplicado')
nodup <- nodup %>% mutate(class = ' No Duplicado')
oilbird_an <- rbind(dup, nodup)
occ_clean <-nodup

###########################################################################
#Outliers
###########################################################################

#Extract only coordinates of clean occurences
occ_c_coords <- occ_clean[, c("decimalLongitude","decimalLatitude")]

#Extract values of raster for the coordinates
values_occ <- terra::extract(bioc_current_m, occ_c_coords)
colnames(values_occ)
colnames(values_occ) <- c("ID","bio_01","bio_02","bio_03","bio_04","bio_05",
                          "bio_06","bio_07", "bio_08","bio_09","bio_10", "bio_11",
                          "bio_12","bio_13","bio_14", "bio_15","bio_16","bio_17",
                          "bio_18","bio_19")
#Add values to data set
occ_env <- cbind(occ_clean, values_occ)
head(occ_env)

# Save complete dataset
write.csv(occ_env,"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/occ_clean.csv" )
write.csv(values_occ,"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/values_occ.csv" )

# Select only data essential for analysis, remove metadata
occ_env_f <- select(occ_env,decimalLongitude, decimalLatitude, ID,
                               starts_with("bio"))
sum(is.na(occ_env_f))#0

#Exploratory visualizations
occ_long <- pivot_longer(occ_env_f,
                         cols = starts_with("bio"),
                         names_to = "variable",
                         values_to = "value")

occ_long_plot <-ggplot(occ_long, aes(x = variable, y = value)) +
                geom_boxplot() +
                theme_bw()

## Before deleting any outliers it is better to do PCA, since the variables are 
##related

###########################################################################
#Selection of variables by PCA and VIF
###########################################################################

##Transform in data frame
values_occ_2 <- dplyr::select(values_occ, -ID)

#######################################
#Correlation of bioclimatic variables
#######################################
#Correlation by pairs
cor_matrix <- cor(values_occ_2)
#Visuals
cor <- ggcorr(values_occ_2) # problem with version ggplot2
corpairs <- ggpairs(values_occ_2)

# Find high correlation
high_cor <- findCorrelation(cor_matrix, cutoff = 0.8)
climate_cor <-values_occ_2[,-high_cor]
colnames(climate_cor)

#Multicorrelation: Is more complete considering a group of vairables
#Calculate Variance inflaction factors

vif.res <- vif(x = values_occ_2)
#test for multicollinearity, stepwise procedure with a threashold of 10
vif.step <- vifstep(x = values_occ_2, th = 10)
#store results
vif.step
vrs <- vif.step@results$Variables %>% as.character()
vrs # bio 2,3,4,6,12,15,18,19, but do they represent each gradient ecological?

write.csv(vrs,"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/Analysis/climate_cleaning/vif_vars.csv" )

#############
##PCA: Understand variation - ecological importance
############

# Doing PCA
#temperature and precipitation different scales so we use scale and center to 
#standarize
pca <- prcomp(values_occ_2, scale. = TRUE, center = TRUE, rank. = 4)
summary(pca)
#plot 
pca_plot <-fviz_pca_biplot(pca,
                geom.ind = "point",
                col.ind = "grey30",
                col.var = "red",
                repel = TRUE)
ggsave (filename= "pca_plot.png", plot=pca_plot, path = path, 
        dpi=300,width = 8,height=6)

# Variance explain per each component
var_explain <- pca$sdev^2
# Percentage of variance explaines
per_var_explicada <- (var_explain / sum(var_explain)) * 100
per_var_explicada

#Measures
pca$center
pca$scale
pca$x

load <- pca$rotation[, 1:3]
#Select more important variables for each component
vars_pca <- c(
  rownames(load)[order(abs(load[,1]), decreasing=TRUE)[1:3]],
  rownames(load)[order(abs(load[,2]), decreasing=TRUE)[1:3]],
  rownames(load)[order(abs(load[,3]), decreasing=TRUE)[1:3]]
)
vars_pca # PC1 10,9,1 PC2 17,18,14, PC3 7,2,4

#there is a point that seems outlier-check
which.max(pca$x[,1] + pca$x[,2])#13

# To avoid correlation but keeping ecological importance
#chosen variables should be: bio_1,2,4,12,15,18

#verify correlation btw chosen variables
value_occ_clean <- select(values_occ_2, bio_01,bio_02,bio_04,bio_12,bio_15,bio_18)
vif.2 <- vif(x = value_occ_clean)

###########################################################################
#Filter final datasets and rasters
###########################################################################
#final occurence and env dataset 
colnames(occ_env)
occ_env_clean <- select(occ_env, ...1,decimalLatitude,decimalLongitude,
                        bio_01,bio_02,bio_04,bio_12,bio_15,bio_18)
write.csv(occ_env_clean,"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/occ_env_clean.csv" )

# Filter rasters of bioblimatic variables with defined variables

##  Current
clima <- bioc_current_m[[c("bio_01","bio_02","bio_04","bio_12","bio_15","bio_18")]]
terra::writeRaster(x = clima, filename = paste0(path, '/', 'clima.tif'), overwrite = T)

## Future
#ssp126-2040-2070
clim_126_2040 <- bioc_126_2040_m [[c("bio_01","bio_02","bio_04","bio_12","bio_15","bio_18")]]
#ssp585-2070-2100
clim_126_2071 <- bioc_126_2071_m [[c("bio_01","bio_02","bio_04","bio_12","bio_15","bio_18")]]

terra::writeRaster(x = clim_126_2040, filename = paste0(path, '/', 'clim_126_2040.tif'), overwrite = T)
terra::writeRaster(x = clim_126_2071, filename = paste0(path, '/', 'clim_126_2071.tif'), overwrite = T)

#ssp585-2040-2070
clim_585_2040 <- bioc_585_2040_m [[c("bio_01","bio_02","bio_04","bio_12","bio_15","bio_18")]]
#ssp585-2070-2100
clim_585_2071 <- bioc_585_2071_m [[c("bio_01","bio_02","bio_04","bio_12","bio_15","bio_18")]]

terra::writeRaster(x = clim_585_2040, filename = paste0(path, '/', 'clim_585_2040.tif'), overwrite = T)
terra::writeRaster(x = clim_585_2071, filename = paste0(path, '/', 'clim_585_2071.tif'), overwrite = T)
