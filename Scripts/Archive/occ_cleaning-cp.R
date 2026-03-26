#R code for capstone project EDS programme- Yale
#Climate data cleanning
#Gabriela Pena-Bello
#Last modification : 24.02.2026


# Description

# My project is to determine the current distribution of oilbirds
#(Steatornis caripensis) in Colombia and assess potential changes under future 
#climate scenarios.

#This current script is for accesing and cleaning the ocurrence data

###########################################################################
#Prepare workspace
############################################################################
#load libraries
library (dplyr)
library (ggplot2)
library (readr)
library (here)

#review working directory 
here()

#load data 
oilbird_occ <- read_tsv(here("data","raw_data","Ocurrence","oilbirds_occ.csv"))

###############################################################################
#Explore data
#################################################################################

str(oilbird_occ)
summary(oilbird_occ)

#select variables
oilbird_occ_v <- oilbird_occ %>% 
  select("locality","stateProvince", "occurrenceStatus","individualCount",
         "decimalLatitude", "decimalLongitude", "coordinateUncertaintyInMeters", "elevation",
         "eventDate", "year","basisOfRecord","institutionCode","collectionCode", "issue")

#filter NA for coordinates
oilbird_occ_f <- oilbird_occ_v %>% 
  filter (!is.na(decimalLatitude) & !is.na(decimalLongitude))
dim(oilbird_occ_f)
str(oilbird_occ_f)

###############################
# occurence by year and region
###############################

oilbird_year_region <- oilbird_occ_f %>% 
  group_by(year,stateProvince) %>% 
  summarise(count = n(), .groups = "drop")

oilbird_year_region
#Plot 
plot_oilbird_yr <-ggplot (oilbird_year_region, aes(x=year, y=count, 
                                                   fill= stateProvince)) +
                  geom_col () +
                  labs(title = "Occurence per year and region", x = "year",
                       y = "Count", fill = "State")
plot_oilbird_yr

####################
# occurence by year 
####################
oilbird_year <- oilbird_occ_f %>% 
                group_by(year) %>% 
                summarise(count = n(), .groups = "drop")
head(oilbird_year)
#plot
plot_oilbird_y <-ggplot (oilbird_year, aes(x=year, y=count)) +
                 geom_col () +
                 labs(title = "Occurence per year", x = "year",
                      y = "Count")
plot_oilbird_y

ggsave( here("data", "Analysis","oilbird_occurrence_per_year.png"),
        plot = plot_oilbird_y,width = 8,height = 5, dpi = 300)

#####################
# occurence by region 
#####################

oilbird_region <- oilbird_occ_f %>% 
                  group_by(stateProvince) %>% 
                  summarise(count = n(), .groups = "drop")
head (oilbird_region)

#plot
plot_oilbird_r <-ggplot (oilbird_region, aes(x=stateProvince, y=count)) +
  geom_col () +
  coord_flip() +
  labs(title = "Occurence per region",
       x = "region",
       y = "Count")
plot_oilbird_r

#records per locality
oilbird_occ_f %>%
  count(locality) %>%
  arrange(desc(n)) 
#slice_head(n = 10)

##########################
# explore other variables
##########################
oilbird_occ_f %>% count(institutionCode) %>%
                  arrange(desc(n))
oilbird_occ_f %>% count(collectionCode) %>%
                  arrange(desc(n))
oilbird_occ_f %>% count(individualCount) %>%
                  arrange(desc(n))
oilbird_occ_f %>% count(occurrenceStatus) %>%
                  arrange(desc(n))

oilbird_occ_f %>% count(individualCount) %>%
                  arrange(desc(n))

#Check abscence and presence

Oilbird_absc <- oilbird_occ_f %>% 
                filter(occurrenceStatus == "ABSENT")

head(Oilbird_absc)
tail(Oilbird_absc)

oilbird_pre <- oilbird_occ_f %>% 
               filter(occurrenceStatus == "PRESENT")

###############################################################################
# Map data
################################################################################
library(sf)
library(terra)

#load shapefile
COL <- st_read(here("data","raw_data","colombia","COLOMBIA_LEVEL_1.shp"),
               layer = "COLOMBIA_LEVEL_1") 

# It has municipalities so join to have only boundary
COL <-st_union(COL)

head(oilbird_occ_f)

loc_map <- plot(COL)
           points(oilbird_occ_f$decimalLongitude, oilbird_occ_f$decimalLatitude, 
                  pch = 16)

write.csv(oilbird_occ_f, here("data","clean_data","ocurrence","oilbird_occf.csv"))





