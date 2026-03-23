# Clean data
This folder contains processed datasets derived from the raw data. These files were used directly in the analyses.

All data were derived from raw datasets after cleaning and filtering steps. Detailed methods are documented in /scripts/cleaning/README.md.

### Ocurrence data

Filtered and clean records used for an addtional step in climate script

**Processing script**: /scripts/Cleaning/ occ_cleaning_oilb.ipnyb

### Colombia shapefile 
Country-level polygon used to define the study extent.

**Processing script:** /scripts/Cleaning/climate_cleaning.R

### Climate data
Selected bioclimatic variables used as predictors in the models.

- BIO1 (Annual Mean Temperature)
- BIO2 (Mean Diurnal Range)
- BIO4 (Temperature Seasonality)
- BIO12 (Annual Precipitation)
- BIO15 (Precipitation Seasonality)
- BIO18 (Precipitation of Warmest Quarter)

**Processing script:** /scripts/Cleaning/climate_cleaning.R

### WDPA data
Filtered dataset containing only protected areas within Colombia. This subset was used to evaluate overlap with predicted habitat suitability.

**Processing script:** /scripts/Cleaning/protected_areas.R