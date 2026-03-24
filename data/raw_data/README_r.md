**IMPORTANT**: Do not modify files in this folder. These are the original datasets used for all analyses in this project.


### Ocurrence data

This folder contains two csv files with species occurrence data (presence/absence), including geographic coordinates (decimal degrees) coordinates and other associated        variables. Data was obtained from Global Biodiversity Information Facility (GBIF) and filtered by species and country (Colombia).                     https://www.gbif.org/es/occurrence/search?country=CO&taxon_key=2497150
                  
Initially, the bat Natalus tumidirostris was considered; however, due to a limited number of independent records, the analysis was conducted using the oilbird Steatornis caripensis.
                
### Colombia Shapefile

This folder contains spatial data of Colombia administrative boundarues (municipal level), including all associated shapefile components (.shp, .shx, .dbf, etc). 
These data were obtained from previous academic coursework and are used to define the study area and for spatial visualization.

### Climate data

Due to large file sizes these data could not be hosted on github, you can find it in these google drive
with the same folder structure https://drive.google.com/drive/folders/12btA8UOC8NaSU5ZF-FKrL1LWxww0oX30?usp=drive_link

The climate data was obtained from CHELSA-bioclim (Climatologies at High Resolution for the Earth’s Land Surface). https://www.chelsa-climate.org/datasets/chelsa_bioclim
                The dataset includes rasters of 19 bioclimatic variables at ~1 km resolution, derived from temperature and precipitation, cut to Colombia bounding box.
                You will find two folders: V2.1 Climatologies (1981 to 2010) Baseline conditions
                CMIP6 climatologies,future climate scenarios under SSP 126 and SSP585 (subfolders), each scenario includes three time periods 2011-2040, 2041-2070, 2071-2100.  
                The variables represente annual trends, seasonality, and extreme conditions in temperature and precipitation.
                
- BIO1 = Annual Mean Temperature - Unit °C
- BIO2 = Mean Diurnal Range (Mean of monthly (max temp - min temp)) -Unit °C
- BIO3 = Isothermality (BIO2/BIO7) (×100) - Unit °C
- BIO4 = Temperature Seasonality (standard deviation)- Unit °C/100
- BIO5 = Max Temperature of Warmest Month - Unit °C
- BIO6 = Min Temperature of Coldest Month - Unit °C
- BIO7 = Temperature Annual Range (BIO5-BIO6) - Unit °C
- BIO8 = Mean Temperature of Wettest Quarter - Unit °C
- BIO9 = Mean Temperature of Driest Quarter - Unit °C
- BIO10 = Mean Temperature of Warmest Quarter - Unit °C
- BIO11 = Mean Temperature of Coldest Quarter - Unit °C

- BIO12 = Annual Precipitation - Unit  kg m2/ year
- BIO13 = Precipitation of Wettest Month - Unit  kg m2/ month
- BIO14 = Precipitation of Driest Month - Unit  kg m2/ month
- BIO15 = Precipitation Seasonality (Coefficient of Variation) - Unit  kg m2
- BIO16 = Precipitation of Wettest Quarter - Unit  kg m2/ month
- BIO17 = Precipitation of Driest Quarter - Unit  kg m2/ month
- BIO18 = Precipitation of Warmest Quarter - Unit  kg m2/ month
- BIO19 = Precipitation of Coldest Quarter - Unit  kg m2/ month


### WDPA data: 

Due to large file sizes these data could not be hosted on github, you can find it in these google drive
with the same folder structure https://drive.google.com/drive/folders/12btA8UOC8NaSU5ZF-FKrL1LWxww0oX30?usp=drive_link

This folder refers to Protected areas data obtained from the World Database on Protected Areas (WDPA) https://www.protectedplanet.net/en/thematic-areas/wdpa?tab=WDPA

The dataset includes global spatial data (polygons and points), provided in three folders with accompanying documentation. These data will used to assess overlap between predicted habitat suitability and protected areas.
However, is not used in the current analysis.
                