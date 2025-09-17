# Newborn Screening Cutoff Analysis (R)

This repository contains an R script template used in the Arizona Newborn Screening Program for cutoff analysis.
The script is designed for population-based evaluation of analyte distributions, in silico cutoff testing, and visualization of results.

## 📂 Contents

AZ-R-Cutoff-Analysis.R
R script for preprocessing data, summarizing analyte distributions, simulating cutoff thresholds, and generating tables/plots.

## ⚙️ Usage

1. Open the R script in RStudio or your preferred R environment.

2. Load dataset exported from NATUS Neometrics (Oracle SQL) or another LIMS.

3. Update script parameters:

    a. File path and filename

    b. Column names for analytes of interest

    c. Cutoff thresholds to evaluate

    d. Unsatisfactory sample codes (if applicable)

4. Run the script to generate:

    a. Percentile summaries

    b. Stratified statistics (e.g., age group)
  
    c. Counts of Normal, Borderline, Abnormal, High calls

    d. Optional distribution plots
