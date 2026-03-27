# Project: Impact of climate change on oilbirds (*Steatornis caripensis*) in Colombia

Author: Gabriela Peña Bello

Course: Environmental Data Science \- Yale the School of the Environment


Last update: 26.03.2026

## RESEARCH QUESTIONS

- How might climate change impact oilbird distribution in Colombia?
- What are the main climatic factors that shape the occurrence of oilbirds in Colombia?

## AUDIENCE 
Environmental authorities (national and local) and  local communities living alongside oilbirds

## ABSTRACT

Oilbirds are nocturnal, cave-dependent birds that play a key role in forest regeneration by dispersing seeds over long distances and sustaining cave ecosystems through nutrient inputs. This project uses species distribution models to estimate current habitat suitability in Colombia and project future changes under two climate scenarios: low emissions (SSP1-2.6)
and high emissions (SSP5-8.5). 

Results suggest that oilbirds may be less severely affected than expected.Favorable habitat for oilbirds does not dissapear, but contracts and shifts, with up to 18% of the area lost under the worst case scenario. Thefavorable habitat will move toward the western mountain range. Changes in suitability are primarily associated with diurnal temperature range and temperature seasonality.Thus, conservation efforts should focus on protecting roost sites and surrounding forests within current distribution in the western mountain range.

## PROCESS

To start working on this project in RStudio, open the .Rproj file. This ensures that the working directory is set to the project root. Opening only the .R or the .Rmd file may be insufficient.

1.	Download data 
2.	Clean ocurrence data: remove records without coordinates, remove unnecessary  collumns, correct errors  and filter for spatial redundance.

Script: /Cleaning/occ_cleaning_oilb.ipynb
3.	Clean climate data: Clip the raster to Colombia, analyze multicollinariaty and select key variables (correlation and PCA).

Script: /Cleaning/climate_cleaning
4.	Create pseudo-absence points

Script: this and all the following steps are in Analysis/modeling
5.	Create model with cross-validation
6. Evaluate model performance and variable importance
7.	Build the ensemble model
8. Project current habitat
9.	 Plot and refine the map
10.	 Project future suitability under both scenarios
11. Compare present and future suitability
12. Refine plots

## CAVEATS

Oilbirds depend strictly on caves for roosting and forest cover for foraging, but these variable were not included in the models, due to privacy of data or lack of future projection. This may lead to overestimation of suitable areas, particularly in regions like the Amazon, where there is few caves.


## DATA SOURCES 

- **Ocurrence data**: Occurrence data (presence/absence) was obtained from Global Biodiversity Information Facility (GBIF) and filtered by species and country (Colombia).                                           https://www.gbif.org/es/occurrence/search?country=CO&taxon_key=2497150
                
- **Colombia Shapefile**: Administrative boundarues of Colombia (municipal level) were obtained from previous academic coursework.

- **Climate data**: The climate data was obtained from CHELSA-bioclim. https://www.chelsa-climate.org/datasets/chelsa_bioclim
The dataset includes rasters of 19 bioclimatic variables at ~1 km resolution, derived from temperature and precipitation, cut to Colombia bounding box.
                
- **WDPA data**: Protected areas data obtained from the World Database on Protected Areas (WDPA) https://www.protectedplanet.net/en/thematic-areas/wdpa?tab=WDPA
             The dataset includes global spatial data (polygons and points)

## REQUIREMENTS
Maxent in working directory

## LICENSE
This project currently does not include a formal license. 
The materials are shared for academic and non-commercial use.  

If you wish to reuse or adapt any part of this repository, please provide appropriate credit to the author.

**Contact Info** gpenab19@gmail.com

## CITATION

Peña Bello, G. (2026). *Impact of Climate Change on Oilbirds in Colombia*.  
GitHub repository: [https://github.com/gabpenab/eds_capstone_project_GPB]

