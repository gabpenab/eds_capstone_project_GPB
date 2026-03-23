#R code for capstone project EDS programme- Yale
#Climate data cleanning
#Gabriela Pena-Bello
#Last modification : 24.02.2026


# Description

# My project is to determine the current distribution of oilbirds
#(Steatornis caripensis) in Colombia and assess potential changes under future 
#climate scenarios.

#This current script is for accesing and cleaning the climate data

###########################################################################
#data
#################################################################
#load libraries
library (dplyr)
library (ggplot2)
library (readr)

#load data and explore
oilbird_occ_f <- read_csv("C:/Users/gabyo/Escritorio/EDS_capstone_R/data/oilbird_occf.csv")

summary(oilbird_occ_f )

oilbird_pre <- oilbird_occ_f %>% 
  filter(occurrenceStatus == "PRESENT")
