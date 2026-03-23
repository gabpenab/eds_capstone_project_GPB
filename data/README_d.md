# Data Directory

This folder contains all datasets used in this project, organized into raw and processed data.

## Structure

### Raw_data
Original datasets as obtained from external sources. These files should not be modified, preserved for reproducibility.
See /raw_data/README.md for full descriptions of each dataset.

### Clean_data
Processed datasets used for analysis, derived from raw data after cleaning and filtering steps.
See /clean_data/README.md for details on data processing and transformations.

### Analysis
Intermediate outputs generated during exploratory and analytical steps. These files are not all included in the final report but are stored to document the analytical process.
See /scripts/Analysis for details on data analysis 

### Outputs
Final results, figures, materials used for communication and reporting.

### Archive 
Old versions and superseded files retained for reference but not used in the final analysis.

## Data Workflow

Raw data were downloaded from external sources and stored in /raw_data. These data were then cleaned and processed using scripts in /scripts/cleaning, resulting in the datasets available in /clean_data, which were used for modeling and analysis.

Intermediate outputs generated during the analysis are stored in /analysis, while final results and figures for communication are stored in /outputs. Files that are no longer used but were part of the workflow are kept in /archive for reference.

### Notes

All data processing steps are documented in the /scripts directory.

                