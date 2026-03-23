# PROJECT: IMPACT OF CLIMATE CHANGE ON OILBIRDS IN COLOMBIA

Author: Gabriela Peña Bello

Course: Environmental Data Science \- Yale the School of the Environment


Last update: 17.03.2026

## RESEARCH QUESTIONS

- How might climate change impact oilbird distribution in Colombia?
- What are the main climatic factors that shape the occurrence of oilbirds in Colombia?

## AUDIENCE 
Environmental authorities (national and local) and  local communities living alongside oilbirds

## ABSTRACT

Oilbirds are unique nocturnal birds that depend on caves. They contribute to forest regeneration, by dispersing seeds over long distances, especially for native palms. In cave ecosystems, their guano supports entire communities of organisms. 

However, climate change is altering temperature and rainfall patterns, which can shift ecosystems and reduce the suitable habitats for this species. To address this, this project uses species distribution models to estimate current habitat suitability and project it to future conditions under two scenarios: SSP 126 (low-emissions scenario, less drastic climate change) and SSP 585 (high emissions scenario, intense climatic changes).

Results suggest that oilbirds may be less severely affected than expected. Under the worst-case scenario (SSP5-8.5), favorable habitat decreases by 26% on average but does not disappear. Instead, suitability shifts toward the western mountain range. These results indicate that conservation efforts should prioritize protecting existing roost sites and surrounding forests in current western distribution areas.

## PROCESS
1.	Download data 
2.	Clean ocurrence data: remove records without coordinates, remove unnecessary  collumns, correct errors  and filter for spatial redundance.
Script: 
3.	Clean climate data: Clip the raster to Colombia, analyze multicollinariaty and select key variables (correlation and PCA).
Script: 
4.	Create pseudo-absence points
Script: this and all the following steps are in 
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
License –Educational use only
**Contact Info** Gabriela Peña Bello 
                 gpenab19@gmail.com



