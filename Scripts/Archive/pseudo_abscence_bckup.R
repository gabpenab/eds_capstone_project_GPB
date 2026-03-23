
pacman::p_load(
  devtools,# allows to install from web
  # data manipulation
  dplyr,tidyverse,  writexl, stringr,purrr,
  
  #Packages for visuals
  ggplot2, # graphics
  RColorBrewer, viridis, # Manipulate colors #colorspace,
  #ggthemes, ggtext,# improved themes and text in ggplot
  gridExtra, #Combine and align graphics
  ggrepel, #Labels
  factoextra,#See PCA
  ggspatial, #maps 
  
  #Packages for spatial data
  terra,sf,
  
  #Analysis
  dismo,#model
  biomod2, #model
  R.utils ### biomod needs it
)

################################################################################
#Background points- pseudoabscence
###############################################################################
#Extract only coordinates of clean occurences
occ_c_coords <- occ_env_clean[, c("decimalLongitude","decimalLatitude")]

#Create an empty mask with the pixels
mask <- bioc_current_m[[1]]* 0 + 1

#Locate coordinates in pixels, with clean occurrences
clls <- terra::extract(mask, occ_c_coords, cells = TRUE) 
#transform in table 
clls <- as_tibble(clls)
#Joint occurrences with correspondent pixel
clls_2 <- as_tibble(cbind(occ_c_coords, clls[,'cell']))

# turn cells with presence into NA to avoid use as background
mask[clls$cell] <- NA

# Do random  background points
bckg_coords <- as_tibble(terra::spatSample(x = mask, 
                                           size = nrow(clls_2)*10, # No. of occurrence *10 
                                           na.rm = TRUE, 
                                           replace = FALSE, 
                                           as.df = TRUE, 
                                           xy = TRUE, 
                                           warn = TRUE, 
                                           values = TRUE))
# To make a simple plot
plot(mask)
points(bckg_coords$x, bckg_coords$y, pch = 16, col = 'red')

# Extract value of climate for backgrounds points
bckg <- as_tibble(cbind(bckg_coords[,1:2], terra::extract(bioc_current_m,
                                                          bckg_coords[,c('x', 'y')])))
bckg_env_clean <- select(bckg, x, y, bio_01,bio_02,bio_04,bio_12,bio_15,bio_18)

#Verify no pseudoabscence is over presence 
dup_points <- inner_join(occ_env_clean, bckg_env_clean, 
                         by = c("decimalLongitude","decimalLatitude"))
nrow(dup_points)
# Save  datasets
write.csv(bckg,"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/background.csv" )
write.csv(bckg_env_clean ,"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/bckg_env_clean.csv" )

# Join presences and pseudo-absences into only one dataframe --------------
occ_env_clean <- rename(occ_env_clean, ID_o = "...2")
occ_env_clean <- select(occ_env_clean, -"...1")

#Create a column defining presence or pseudo absence
occ_env_clean <- mutate(occ_env_clean, pb = 1)
bckg_env_clean <- mutate(bckg_env_clean, pb = 0)
#create ID for background points
occ_env_clean$ID_o <- as.character(occ_env_clean$ID_o)
bckg_env_clean$ID_o <- paste0("bg_", seq_len(nrow(bckg_env_clean)))
#change colnames to match
colnames(bckg_env_clean)[1:2] <- c('decimalLongitude', 'decimalLatitude')
colnames(occ_env_clean)
colnames(bckg_env_clean)

# reorder columns to be the same 
bckg_env_clean <- bckg_env_clean[, colnames(occ_env_clean)]
#Join
all_data <- bind_rows(occ_env_clean, bckg_env_clean)
head(all_data)

# Save  dataset
write.csv(all_data,"C:/Users/gabyo/Escritorio/EDS_capstone_R/data/pre_abs_env_clean.csv" )
