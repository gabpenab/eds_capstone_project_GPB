# Data Directory

This folder contains all datasets used in this project, organized into different folders.

## Structure

### Raw_data
Original datasets as obtained from external sources. These files should not be modified, preserved for reproducibility.
See /raw_data/README.md for full descriptions of each dataset.

### Clean_data
Processed datasets used for analysis, derived from raw data after cleaning and filtering steps.
See Scripts/Cleaning/README.md for details on data processing and transformations.

### Analysis
Intermediate outputs generated during exploratory and analytical steps. These files are not all included in the final report but are stored to document the analytical process.
See /scripts/Analysis for details on data analysis 

### Outputs
Final results and materials used for communication and reporting.

### Archive 
Old versions files retained for reference but not used in the final analysis.

## Data Workflow

Raw data were downloaded from external sources and stored in /raw_data. These data were then cleaned and processed using scripts in /scripts/cleaning, resulting in the datasets available in /clean_data, which were used for modeling and analysis.

Intermediate outputs generated during the analysis are stored in /analysis, while final results and figures for communication are stored in /outputs. Files that are no longer used but were part of the workflow are kept in /archive for reference.

### Notes

All data processing steps are documented in the /scripts directory.

### Ethical Considerations  

Data was obtained from open-access databases and used in accordance with their terms of use. Sensitive ecological information, such as precise locations of species dependent on vulnerable habitats (e.g., caves), should be handled with care to avoid potential disturbance or exploitation.

This project aims to support conservation planning and does not promote activities that may negatively impact wildlife or their habitats.

                