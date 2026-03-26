# Scripts Directory

This folder contains all scripts used for data processing, analysis, and visualization in this project.

## Structure

### Cleaning
Scripts used to clean and prepare raw data. 

### Analysis
Scripts used to build and evaluate species distribution models, generate projections (current and future), and produce maps and results.

### Archive
Older or unused scripts that were part of the development process but are not included in the final workflow.

## Workflow

The analysis follows a sequential workflow:
1. Open the .Rproj file. This ensures that the working directory is set to the project root.
Opening only the .R or the .Rmd file may be insufficient.
2. Run scripts in /cleaning to generate processed datasets (/clean_data)
3. Run scripts in /analysis to build models, generate projections, and produce outputs (/analysis and /outputs)
