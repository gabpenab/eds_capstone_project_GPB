#R code for capstone project EDS programme- Yale
#Climate data cleanning
#Gabriela Pena-Bello
#Last modification : 12.03.2026


# Description

# My project is to determine the current distribution of oilbirds
#(Steatornis caripensis) in Colombia and assess potential changes under future 
#climate scenarios.
#This current script is for modeling


################################################################################
# Prepare workspace and load data
###############################################################################
# Set working space
setwd("C:/Users/gabyo/Escritorio/EDS_capstone_R")
# Install and Load libraries we haven´t installed
library(pacman)
pacman::p_load(
   #Packages for visuals
  ggplot2, # graphics
  RColorBrewer, viridis, # Manipulate colors #colorspace,
  gridExtra, #Combine and align graphics
  ggrepel, #Labels
  ggspatial, #maps 
  
  #Packages for spatial data
  terra,sf,
  
  #Analysis
  dismo,#model
  biomod2, #model
  R.utils ### biomod needs it
)

install.packages("biomod2")
library(biomod2)
install.packages("R.utils")## biomod needs it
library(R.utils)
library(patchwork)
#Load libraries we already installed
library(dplyr)
library(tidyverse)
library (readr)

library (ggplot2)
library(sf)
library(terra)
library(tidyterra)

##############
##Load data
##############

path <-"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/Analysis/model"

#current bioclimatic raster
clima <- terra::rast('C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/climate/clima.tif')

#Future bioclimatic rasters

# ssp126 -years 2041-2070
clim_126_2040 <- terra::rast('C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/climate/clim_126_2040.tif')
#ssp126-years 2070-2100
clim_126_2071<- terra::rast('C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/climate/clim_126_2071.tif')

# ssp585 -years 2041-2070
clim_585_2040 <- terra::rast('C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/climate/clim_585_2040.tif')
#ssp585-years 2070-2100
clim_585_2071<- terra::rast('C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/climate/clim_585_2071.tif')

#Ocurrence data
occ_env_clean <- read_csv("C:/Users/gabyo/Escritorio/EDS_capstone_R/data/clean_data/ocurrence/occ_env_clean.csv")

################################################################################
# Format data and pseudo-abscences
###############################################################################

#standard colnames
colnames(occ_env_clean)
occ_env_clean <- rename(occ_env_clean, ID_o = "...2")
occ_env_clean <- select(occ_env_clean, -"...1")

#We need to split each argument
#Species name
species <-"Oilbird_Steatornis caripensis"
#Since is presence only data we create a vector with 1s, 1 is presence 0 is absence
cat <- rep(1,nrow(occ_env_clean))
# Coordinates longitud always first X, y is latitude
occ_coords <- occ_env_clean[, c("decimalLongitude","decimalLatitude")]


#Format data and generate pseudoabscence 
#set seed for aleatory process as pseudo-abscences and cross-validation
set.seed(123)

data_mod <- BIOMOD_FormatingData (resp.var = cat,
                                  expl.var = clima,
                                  resp.xy = occ_coords,
                                  resp.name = species,
                                  dir.name = path,
                                  data.type = "binary",
                                  # Number of repetitions of pseudo-abscence
                                  PA.nb.rep = 2,
                                  #Number of pb per repetition
                                  PA.nb.absences = 1000,
                                  #Way of doing pseudo-abscenses
                                  PA.strategy = "random")


################################################################################
# CURRENT MODEL 
###############################################################################

#################
# MODELS
#################
model_cur <- BIOMOD_Modeling( data_mod,
                              models = "MAXENT",
                              CV.strategy = "kfold", #use k fold cross-validation
                              CV.k = 5, #Number of folds
                              #training and validating split data 
                              CV.perc = 0.8,
                              CV.nb.rep = 2,#repetition
                              var.import = 3,#permutations for variable importance
                              metric.eval = c("TSS","AUCroc"))
#Check results
structure(model_cur) # two models did not worked
get_evaluations(model_cur)# high performace AUC btw 0.8-0.9, TSS moderate 0.49-0.69
#Check variable importance
var_imp <- get_variables_importance(model_cur)
#get mean
var_imp_mean <- var_imp %>% group_by(expl.var)%>% 
                summarise(mean_importance = mean(var.imp))
#improve esthetics of plot  
plot_var_imp <- ggplot(var_imp, aes( x = expl.var, y= var.imp))+
                 geom_boxplot() +
              labs(x = "Bioclimatic variable",
                  y = "Importance",
                  title = "Variation of variable importance through the models")

# Plotting response curves


## Join models do an average
model_ensemble <- BIOMOD_EnsembleModeling( bm.mod = model_cur,
                                     models.chosen = "all",
                                     em.by = "all",
                              #Tss not affected by prevalence of pseudo-abscence
                                     metric.select = "TSS",
                              #since my metrics are lower than 0.69 cannot use a high thershold
                                     metric.select.thresh = 0.6,
                              #weighted ensemble, model contributes according to evaluation score
                                     em.algo ="EMwmean")
summary(model_ensemble)
get_evaluations(model_ensemble)

###############
# PROJECTIONS
##############

# Individual projections - needed for final map as argument
proj_model_cur <- BIOMOD_Projection(  bm.mod = model_cur,
                                    proj.name = "current",
                                    new.env = clima,#same raster
                                    models.chosen = "all",
                                    # Avoid prediction out of the range- more accuracy
                                    build.clamping.mask = TRUE)

##Project definitive model in present raster 
proj_ensemble <- BIOMOD_EnsembleForecasting(bm.em = model_ensemble,
                                             bm.proj = proj_model_cur,
                                             proj.name = "def_current")

##Plot
ensemble_pred <- get_predictions(proj_ensemble)
plot(ensemble_pred)# scale of color green-red so need to improve it
ensemble_pred <- rename(ensemble_pred, EMwmean = 
                             "Oilbird.Steatornis.caripensis_EMwmeanByTSS_mergedData_mergedRun_mergedAlgo")
#extract as data frame
ensemble_pred_df <- as.data.frame(ensemble_pred, xy = TRUE)
head(ensemble_pred_df)

#Improve plot with ggplot
ens_plot_im <- ggplot(ensemble_pred_df) +
              geom_raster(aes(x = x, y = y, fill = EMwmean)) +
              coord_equal() +
              scale_fill_viridis_c(name = "Suitability") +
              labs(title = "Present habitat suitability",
                   x= "Decimal Longitude ",
                   y =  "Decimal Latitude")+
              theme_minimal() +
              theme(plot.title = element_text(hjust = 0.5))
ens_plot_im
path_outputs <- "C:/Users/gabyo/Escritorio/EDS_capstone_R/data/Analysis/maps"
ggsave(filename = paste0(path_outputs, '/', 'ens_plot_current.tif'),
       plot = ens_plot_im, width = 9, height = 8 ,dpi=300)

################################################################################
# FUTURE PROJECTIONS
###############################################################################

########################
## LOOP FOR PROJECTIONs
#######################
#Save all future scenarios in one list
future_climates <- list(p_126_2071 = clim_126_2071,p_126_2040 = clim_126_2040,
                        p_585_2040 = clim_585_2040,p_585_2071 = clim_585_2071)

#Create empty lists for storing loop results
proj_list <- list()
ensemble_proj <- list()

# Loop for creating projections for all cases
for(i in names(future_climates)) {
  
  #Individual projections
  proj_list[[i]] <- BIOMOD_Projection(bm.mod = model_cur,
                                      new.env = future_climates[[i]],
                                      proj.name = i,
                                      models.chosen = "all",
                                      build.clamping.mask = TRUE)

  #Ensemble projections
  ensemble_proj[[i]] <- BIOMOD_EnsembleForecasting(bm.em = model_ensemble,
                                                   bm.proj = proj_list[[i]],
                                                   proj.name = paste0("ens_", i)
  )}

proj_list
ensemble_proj 

##########
##Plots
##########

#Function to extract predictions & create plots
create_future_plot <- function(ensemble_obj, scenario_name, long_name) {
                      # Get predictions
                      pred <- get_predictions(ensemble_obj)
                      # Rename the long column name
                      pred <- rename(pred, EMwmean = all_of(long_name))
                      # Convert to data frame
                      pred_df <- as.data.frame(pred, xy = TRUE)
                      # Create plot
                      plot <- ggplot(pred_df) +
                        geom_raster(aes(x = x, y = y, fill = EMwmean)) +
                        coord_equal() +
                        # 
                        scale_fill_viridis_c(name = "Suitability") +  
                        labs(
                          title = paste("Future habitat suitability -", scenario_name),
                          x = "Decimal Longitude",
                          y = "Decimal Latitude"
                        ) +
                        theme_minimal() +
                        theme(plot.title = element_text(hjust = 0.5, size = 10))
                      
                      return(list(data = pred_df, plot = plot))
}

# Loop for creating plots
#Change name of the column in predictions is too long
long_name <- "Oilbird.Steatornis.caripensis_EMwmeanByTSS_mergedData_mergedRun_mergedAlgo"
# Create empty list for storing loop results
future_plots <- list()

#Loop using the function defined above
for(i in names(ensemble_proj)) {
  future_plots[[i]] <- create_future_plot(
    ensemble_obj = ensemble_proj[[i]],
    scenario_name = i,
    long_name = long_name
  )
}

plot(p_126_2040)
# SAVE ALL PLOTS

for(i in names(future_plots)) {
  ggsave(
    filename = file.path(path_outputs, paste0("plot_", i, ".png")),
    plot = future_plots[[i]]$plot,
    width = 9,
    height = 8,
    dpi = 300
  )
}


################################################################################
##COMPARAISON
###############################################################################

##################
## Change Map SSp585_2071-2100 
#################
## Review raster outputs of the model
structure(ensemble_pred)
structure(pred_ens_585_2071)

#rasters can be compared?
compareGeom(ensemble_pred, pred_ens_585_2071)#True

#Create difference
delta_585_2071 <- pred_ens_585_2071 - ensemble_pred
structure(delta_585_2071)

# Metrics
global(delta_585_2071, mean, na.rm=TRUE) # -26.7
val_delta_585_2071  <- values(delta_585_2071)
summary(val_delta_585_2071)

##Plotting
delta_585_2071_df <- as.data.frame(delta_585_2071, xy = TRUE, na.rm=TRUE)
colnames(delt
                       geom_raster(aes(x = x, y = y, fill = delta)) +
                       scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "blue",
                       midpoint = 0,
                       name = "Change in suitability" ) +
  coord_equal() +
  theme_minimal() +a_585_2071_df) <- c("x","y","delta")
delta_585_2071_plot <- ggplot(delta_585_2071_df) +
  labs(title = "Change in habitat suitability",
       #subtitle ="Under scenario SSP 585 for years 2071-2100",
       x= "Decimal Longitude ",
       y =  "Decimal Latitude")+
  theme(plot.title = element_text(hjust = 0.5, size = 10))

delta_585_2071_plot

######################################
## Comparaison of scenarios and times
#######################################



################################################################################
## FINAL FIGURES DIFFERENT PANELS
###############################################################################

panel_585_2071 <- (ens_plot_im + plot_pred_ens_585_2071_df +delta_585_2071_plot)+
                  #plot_layout(guides = "collect") +
                 plot_annotation(
    title = "Oilbirds could lose 26% of their habitat suitability in Colombia due to climate change",
    subtitle = "Under scenario SSP 585 for years 2071-2100",
    tag_levels="A",
    theme = theme ( plot.title = element_text(size = 16, face ="bold"),
                    plot.subtitle = element_text(size = 12))
     )
panel_585_2071

ggsave("oilbird_change_585_2071.tiff",panel_585_2071, width= 27, height=8,
       units="cm", dpi =300)

