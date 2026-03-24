# Data Cleaning Scripts
This folder contains scripts used to clean and prepare raw datasets for analysis.

## Workflow Description

The following steps were applied:

### Occurrence data:
Data was filtered removing records without geographic coordinates and unnecessary columns,  

### Climate data:
Data was clipped to country level. Then a mask of the raster was used to filter ocurrence data to reduce spatial redundance retain one record per climate raster pixel.

Bioclimatic variables were evaluated to reduce multicollinearity and retain ecologically relevant predictors. Variables were selected based on correlation analysis and principal components analysis, maintaining a Variance Inflation Factor (VIF) below 10 and at least one explanatory variable per axis of the PCA.


### Colombia shapefile:
Municipality-level boundaries were dissolved to obtain a single polygon representing the country boundary.

### Protected areas (WDPA):
The global dataset was filtered to retain only protected areas within Colombia.