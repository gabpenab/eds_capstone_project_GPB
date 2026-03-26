#R code for capstone project EDS programme- Yale
#Climate data cleanning
#Gabriela Pena-Bello
#Last modification : 26.03.2026


# Description

# My project is to determine the current distribution of oilbirds
#(Steatornis caripensis) in Colombia and assess potential changes under future 
#climate scenarios.

#This current script is for cleaning the protected areas data.
# Before running this script you need to download the data, directly from the database
# and put it in the raw_data folder under WDPA folder
#https://www.protectedplanet.net/en/thematic-areas/wdpa?tab=WDPA
#Check raw data README for more information
################################################################################
#Prepare workspace
###############################################################################
# clear work space
rm(list=ls())
#load libraries
library (dplyr)
library (ggplot2)
library (readr)
###########################################################################
#data
#################################################################
#load occurrence data subset
occ_env_clean <- read_csv(here("data","clean_data","ocurrence","oilbird_occf.csv"))

summary(oilbird_occ_f )

# filter only presence points (absence ponts only in PNN, monitoring or error?)
oilbird_pre <- oilbird_occ_f %>% 
  filter(occurrenceStatus == "PRESENT")

#load WDPA - natural reserve shapefiles

reservas_1 <- st_read(here("data","raw_data","WDPA", "WDPA_Dec2025_Public_shp_0",
                       "WDPA_Dec2025_Public_shp-points.shp"))
reservas_2 <- st_read(here("data","raw_data","WDPA", "WDPA_Dec2025_Public_shp_1",
                           "WDPA_Dec2025_Public_shp-points.shp"))
                      
reservas_3 <- st_read(here("data","raw_data","WDPA", "WDPA_Dec2025_Public_shp_2",
                           "WDPA_Dec2025_Public_shp-points.shp"))

reservas_4 <- st_read(here("data","raw_data","WDPA", "WDPA_Dec2025_Public_shp_0",
                           "WDPA_Dec2025_Public_shp-polygons.shp"))
                    
reservas_5 <- st_read(here("data","raw_data","WDPA", "WDPA_Dec2025_Public_shp_1",
                           "WDPA_Dec2025_Public_shp-polygons.shp"))
                    
reservas_6 <- st_read(here("data","raw_data","WDPA", "WDPA_Dec2025_Public_shp_2",
                           "WDPA_Dec2025_Public_shp-polygons.shp"))

head(reservas_1)
head(reservas_4)

#See which file has data on Colombia
col_res_1 <- reservas_1 %>% filter(ISO3 == "COL")
nrow(col_res_1)
col_res_2 <- reservas_2 %>% filter(ISO3 == "COL")
nrow(col_res_2)
col_res_3 <- reservas_3 %>% filter(ISO3 == "COL")
nrow(col_res_3)
col_res_4 <- reservas_4 %>% filter(ISO3 == "COL")
nrow(col_res_4)
col_res_5 <- reservas_5 %>% filter(ISO3 == "COL")
nrow(col_res_5)
col_res_6 <- reservas_6 %>% filter(ISO3 == "COL")
nrow(col_res_6)
# not points but all the polygons have on COL

#joint polygons in one object
wdpa_col <-bind_rows(col_res_4,col_res_5,col_res_6)
plot(wdpa_col)
st_write(wdpa_col, here("data","clean_data","wdpa","wdpa_col.shp"))
st_crs(wdpa_col)

#Convert oilbirds data to spatial feature
oilbirds_occ_pre <- st_as_sf(oilbird_pre, coords = 
                             c("decimalLongitude", "decimalLatitude"), crs = 4326)
st_crs(oilbirds_occ_pre)

#Intersect reserves and occurence
occ_WDPA <- st_intersection(oilbirds_occ_pre, wdpa_col)
occ_WDPA_df <- as_data_frame(occ_WDPA)
head(occ_WDPA_df)
colnames(occ_WDPA_df)
write.csv(occ_WDPA_df, here("data","clean_data","wdpa","occ_wdpa_df.csv"))
          


