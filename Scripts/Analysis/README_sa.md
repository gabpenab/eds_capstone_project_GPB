# Analysis Scripts

This folder contains the script used to build, evaluate, and project species distribution models, as well as to generate final outputs. These scripts use processed datasets from /clean_data

## Workflow Description

The analysis follows these main steps:

Pseudo-absence generation:
Creation of background or pseudo-absence points to complement occurrence data.

Model fitting:
Multiple species distribution models are trained using cross-validation to ensure robust predictions.

Model evaluation:
Model performance is assessed using standard evaluation metrics, and variable importance is extracted.

Ensemble modeling:
Individual models are combined into an ensemble model to improve predictive performance.

Current projections:
The ensemble model is used to estimate current habitat suitability across Colombia.

Future projections:
Habitat suitability is projected under two climate scenarios (SSP1-2.6 and SSP5-8.5).

Comparison and analysis:
Current and future projections are compared to quantify changes in habitat suitability.

Visualization:
Maps and figures are generated and refined for interpretation and communication.

For further detail directly check the script or the notebook in /data/Analysis/Notebook

## Outputs

- Intermediate outputs are stored in data/Analysis

- Final maps and figures are stored in data/outputs