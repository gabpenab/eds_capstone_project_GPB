#R code for capstone project EDS programme- Yale
#Modeling
#Gabriela Pena-Bello
#Last modification : 25.03.2026


# Description

# My project is to determine the current distribution of oilbirds
#(Steatornis caripensis) in Colombia and assess potential changes under future 
#climate scenarios.

#This current script is for modelling, analysis and final visualizations

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
library(ggrepel)
library(rnaturalearth)
library(ggspatial)
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

# Set path for outputs
path_outputs <- "C:/Users/gabyo/Escritorio/EDS_capstone_R/data/Analysis/maps_model"

###################
# Standarize plots
###################
#Since plots show different fonts i defined a theme for all final figures
base_theme <- theme_minimal(base_size = 12) +
  theme(text = element_text(family = "sans"),
        plot.title = element_text(face = "bold", size = 12, hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
        axis.title = element_text(size = 11),
        axis.text = element_text(size = 10))
        #legend.text = element_text(size = 10),
        #legend.title = element_text(size = 12),
        #plot.margin = margin(10, 20, 10, 20))


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

## summarize variable importance
var_imp_sum <- var_imp %>% group_by(expl.var) %>%
               summarise(mean_imp = mean(var.imp, na.rm = TRUE),
                        sd_imp = sd(var.imp, na.rm = TRUE)) %>%
                arrange(mean_imp)

#Variation of variable importance - exploratory
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

# rescale suitability to 0 to 1 just for plot
ensemble_pred_df$EMwmean <- ensemble_pred_df$EMwmean / 1000

#Improve plot with ggplot
ens_plot_im <- ggplot(ensemble_pred_df) +
              geom_raster(aes(x = x, y = y, fill = EMwmean)) +
              coord_sf(crs = st_crs(4326),label_graticule = "SW") +
              scale_fill_viridis_c(name = "Suitability") +
              labs(title = "Present habitat suitability",
                   x= "Longitude ",
                   y =  "Latitude")+
             #add compass and scale
            annotation_scale(location = "bl", width_hint = 0.3) +
            annotation_north_arrow(location = "tr",which_north = "true",
                                   style = north_arrow_orienteering())+
              theme_minimal() +
              base_theme
ens_plot_im

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
colnames(delta_585_2071_df) <- c("x","y","delta")

# Rescale suitability change for plot 
delta_585_2071_df$delta <- delta_585_2071_df$delta / 1000
#plot
delta_585_2071_plot <- ggplot(delta_585_2071_df) +
                      geom_raster(aes(x = x, y = y, fill = delta)) +
                      geom_sf(data = st_as_sf(COL), fill = NA, col = 'black',
                              lwd = 0.2) +
                      coord_sf(crs = st_crs(4326),label_graticule = "SW")+
                      scale_fill_gradient2(low = "red",
                                           mid = "white",
                                           high = "blue",
                                           midpoint = 0,
                                        name = "Change in suitability" ) +
                      #add compass and scale
                     annotation_scale(location = "bl", width_hint = 0.3) +
                     annotation_north_arrow(location = "tr",which_north = "true",
                                            style = north_arrow_orienteering())+
                      theme_minimal() +
                       labs(title = "Change in habitat suitability",
                       #subtitle ="Under scenario SSP 585 for years 2071-2100",
                      x= " Longitude ",
                      y =  "Latitude")+
                    base_theme

delta_585_2071_plot

ggsave(filename = paste0(path_outputs, '/', 'changes_585_2071_plot.tif'),
       plot = delta_585_2071_plot, width = 9, height = 8 ,dpi=300)

######################################
## Comparaison of scenarios and times
#######################################
# For being able to compare between scenarios and calculate the percentage of area 
#lost we have to binarize the predictions in abscense /presence

#For this the ensemble model provides a threshold based in TSS
eval_table <- get_evaluations(model_ensemble)
head(eval_table)#342 pixel with s > 342 = suitable -presence
#Extract the cutoff value 
threshold <- eval_table$cutoff[eval_table$metric.eval == "TSS"]

# Since I have a new R session i have to reload some files, avoid this step if
#you are in the same session
model_path <- "C:/Users/gabyo/Escritorio/EDS_capstone_R/model" 

# Reload models from disk - biomod2 saves them automatically to your path
load(paste0(model_path, "/Oilbird.Steatornis.caripensis/Oilbird.Steatornis.caripensis.1773435014.models.out"))
load(paste0(model_path, "/Oilbird.Steatornis.caripensis/Oilbird.Steatornis.caripensis.1773435014.ensemble.models.out"))             

# Present
ensemble_pred <- rast(paste0(model_path, "/Oilbird.Steatornis.caripensis/proj_def_current/", 
                             "proj_def_current_Oilbird.Steatornis.caripensis_ensemble.tif"))

# Futures
ens_pred_126_2040 <- rast(paste0(model_path, "/Oilbird.Steatornis.caripensis/proj_ens_p_126_2040/",
                                      "proj_ens_p_126_2040_Oilbird.Steatornis.caripensis_ensemble.tif"))

ens_pred_126_2071 <- rast(paste0(model_path, "/Oilbird.Steatornis.caripensis/proj_ens_p_126_2071/",
                                      "proj_ens_p_126_2071_Oilbird.Steatornis.caripensis_ensemble.tif"))

ens_pred_585_2040 <- rast(paste0(model_path, "/Oilbird.Steatornis.caripensis/proj_ens_p_585_2040/",
                                      "proj_ens_p_585_2040_Oilbird.Steatornis.caripensis_ensemble.tif"))

ens_pred_585_2071 <- rast(paste0(model_path, "/Oilbird.Steatornis.caripensis/proj_ens_p_585_2071/",
                                      "proj_ens_p_585_2071_Oilbird.Steatornis.caripensis_ensemble.tif"))


#Binarise present and future predictions using the thershold
binary_present <- ensemble_pred >= threshold

# future
binary_126_2040 <- ens_pred_126_2040 >= threshold
binary_126_2071 <- ens_pred_126_2071 >= threshold
binary_585_2040 <- ens_pred_585_2040 >= threshold
binary_585_2071 <- ens_pred_585_2071 >= threshold

# Calculate suitable area in km²
# terra::expanse gives area per cell value, sum gives total suitable area
area_present    <- expanse(binary_present,  unit = "km", byValue = TRUE)
area_126_2040   <- expanse(binary_126_2040, unit = "km", byValue = TRUE)
area_126_2071   <- expanse(binary_126_2071, unit = "km", byValue = TRUE)
area_585_2040   <- expanse(binary_585_2040, unit = "km", byValue = TRUE)
area_585_2071   <- expanse(binary_585_2071, unit = "km", byValue = TRUE)

# Extract only suitable (value == 1) area from each
get_suit_area <- function(x) x$area[x$value == 1]
#define baseline
area_present_suit <- get_suit_area(area_present)

#Do a dataframe
area_df <- data.frame(scenario = c("SSP1-2.6", "SSP1-2.6", "SSP1-2.6",
               "SSP5-8.5", "SSP5-8.5", "SSP5-8.5"),
               period = c("Present", "2041-2070", "2071-2100","Present",
                          "2041-2070", "2071-2100"),
             area_km2 = c(area_present_suit,
               get_suit_area(area_126_2040),
               get_suit_area(area_126_2071),
               area_present_suit,#i am putting the present twice for the plot
               get_suit_area(area_585_2040),
               get_suit_area(area_585_2071)))
head(area_df )

#calculate change
area_df$pct_change <- ((area_df$area_km2 - get_suit_area(area_present)) / 
                         get_suit_area(area_present)) * 100

#  Plot
# Ensure correct order on x-axis
area_df$period <- factor(area_df$period,
                         levels = c("Present", "2041-2070", "2071-2100"))

area_plot <- ggplot(area_df, aes(x = period, y = area_km2, group = scenario, color=scenario)) +
             geom_line(linewidth = 1) +
             geom_point(size = 3) +
             #line of baseline present
             geom_hline(yintercept = area_present_suit, linetype = "dashed", 
                        color = "gray40") +
             # lab of the line
             annotate("text", x = "Present",  # or slightly to the right if you prefer
                       y = area_present_suit,label = "Baseline",
                       vjust = -1,hjust = 1.2, size = 3.5,color = "gray40")+
             #End of line label 
             geom_text_repel(data = subset(area_df, period == "2071-2100"),
                             aes(label = ifelse(scenario == "SSP1-2.6", 
                                      "Low emissions", "High emissions")),
                            nudge_x = 0.2,direction = "y",hjust = 0,
                            segment.color = NA) +
             labs(title = "Projected change in suitable habitat area for oilbirds in Colombia",
                  x = "Time period",
                  y = "Suitable area (km²)") +
                  scale_color_manual(values = c("SSP1-2.6" = "#577590",
                                              "SSP5-8.5" = "#F08A4B"),
                                     labels = c("SSP1-2.6" = "Low emissions",
                                                "SSP5-8.5" = "High emissions")) +
             base_theme +
             theme(legend.position = "none",
                   plot.margin = margin(10, 30, 10, 10) )

area_plot
path_final <- "C:/Users/gabyo/Escritorio/EDS_capstone_R/data/Outputs/figures"
ggsave(filename = paste0(path_final, '/', 'area_plot.png'),
       plot = area_plot, width = 9, height = 8 ,dpi=300)

################################################################################
## FINAL FIGURES DIFFERENT PANELS
###############################################################################
## Panel of change suitability for worst scenario

# Create Colombia locator map
#extract worldmap
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
#Plot
inset_map <- ggplot() +
            geom_sf(data = world, fill = "gray90", color = NA) +
            # plot colombia in other color
            geom_sf(data = st_as_sf(COL), fill = "#440154FF", color = "black", 
                    linewidth = 0.3) +
            #Cut worldmap to only america           
            coord_sf(xlim = c(-95, -30), ylim = c(-60, 20), expand = FALSE) +
            theme_void()+
            theme(panel.border = element_rect(color = "black", fill = NA,
                                              linewidth = 0.5))


# Insert the country locator in one panel
ens_plot_im_inset <- ens_plot_im +  
                       inset_element(inset_map + theme(plot.tag = element_blank()),
                                     left = 0.02, bottom = 0.72,
                                     right = 0.28, top = 0.98)

#Create full panel
panel_585_2071 <- (ens_plot_im_inset| delta_585_2071_plot)+
                 plot_annotation(
                 title = "Oilbirds could lose 18% of their habitat area in Colombia due to climate change",
                 subtitle = "Under High emissions scenario (SSP5-8.5) for years 2071-2100",
                 theme = theme(plot.title = element_text(size = 16, face ="bold",
                                                margin = margin(l = 10)),
                      plot.subtitle = element_text(size = 14, 
                                                   margin = margin(b = 10, l= 10)),
                      plot.margin = margin(t = 20)))


panel_585_2071

ggsave(filename = paste0(path_final, '/', "oilbird_change_585_2071_2.tiff"),
       panel_585_2071, width= 16, height=8, dpi =300)

#final visualization of variable importance
plot_var_imp_b <-ggplot(var_imp_sum, aes(x = reorder(expl.var, mean_imp), 
                                         y = mean_imp)) +
                 geom_col(fill = "#999999", width = 0.7) +
                 geom_errorbar(aes(ymin = mean_imp - sd_imp,ymax = mean_imp + 
                                     sd_imp),
                 width = 0.2, color = "gray30") +
                 coord_flip() +
                 scale_x_discrete(labels = c("bio_01" = "Mean annual 
                                             temperature",
                              "bio_02" = "Mean diurnal 
                              temperature range",
                              "bio_04" = "Temperature 
                              seasonality",
                              "bio_12" = "Annual
                              precipitation",
                              "bio_15" = "Precipitation 
                              seasonality",
                              "bio_18" = "Mean Monthly 
                              Precipitation of
                              the Warmest Quarter"))+
                 labs( x = NULL, y = "Relative importance",
                  title = "Key environmental drivers of oilbird distribution" ) +
                  base_theme
plot_var_imp_b 

ggsave(filename = paste0(path_final, '/', 'var_imp_plot_b.png'),
       plot = plot_var_imp_b, width = 9, height = 8 ,dpi=300)
