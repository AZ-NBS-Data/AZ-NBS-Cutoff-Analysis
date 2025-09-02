###########################################
# Newborn Screening Cutoff Analysis Template
# Author: [Your Name]
# Last Updated: [Date]
#
# This script provides a reproducible workflow 
# for cutoff analysis of newborn screening conditions.
#
# Instructions:
# 1. Update the file path and filename (CSV export).
# 2. Update analyte column names (e.g., C0, C2, C3_C16).
# 3. Update unsatisfactory codes if necessary.
# 4. Update cutoff thresholds for your condition(s).
# 5. Run the script in R or RStudio.
###########################################

# --- Load required packages ---
#Add more libraries for more complex analysis
library(tidyverse)
library(lubridate)
library(ggplot2)
library(pROC)
library(ggthemes)
library(dplyr)

# --- Step 1: Load your dataset ---
# Replace with the path and filename from your SQL export
path <- "./"
setwd(path)
df <- read.csv("INSERT_FILENAME.csv")


# --- Step 2: Data Preprocessing ---
# Trim whitespace from mnemonic fields
# (Update column names to match your dataset)
df$ANALYTE1_MNEMONIC <- trimws(df$ANALYTE1_MNEMONIC)
df$ANALYTE2_MNEMONIC <- trimws(df$ANALYTE2_MNEMONIC)

# List of unsatisfactory codes (edit as needed)
unsat_codes <- c("UIS","UMA","UNS","UMR","UST","UCC","UIO","ULA","ABQNS",
                 "UTO","UCE","UTS","UII","UNI","USC","UPR","NOT")

# Filter to remove unsats, keep valid specimen types, add received date
df <- df %>%
  filter(! ANALYTE1_MNEMONIC %in% unsat_codes) %>%
  filter(! ANALYTE2_MNEMONIC %in% unsat_codes) %>%
  filter(SPECTYPE %in% c(1, 2, 3, 7)) %>%
  mutate(RECVDT = as.Date(RECVDT))

# Create stratification variable for desired demographic fields, such as age at collection
df$age_group <- ifelse(df$AGECOLL_HRS < 120, "<120 hrs", "≥120 hrs")

# --- Step 3: Summary Statistics ---
#Summary statistics of analyte values
#Update field names and column names based on analyte (Shown here: C0 and C0/(C16+C18))
c0.stats <- df %>%
  summarise(
    c0_mean = mean(C0, na.rm = TRUE),
    c0_median = median(C0, na.rm = TRUE),
    c0_min = min(C0, na.rm = TRUE),
    c0_max = max(C0, na.rm = TRUE),
    c0_sd = sd(C0, na.rm = TRUE),
    c0_999 = quantile(C0, 0.999, na.rm = TRUE),
    c0_995 = quantile(C0, 0.995, na.rm = TRUE),
    c0_99 = quantile(C0, 0.99, na.rm = TRUE),
    c0_95 = quantile(C0, 0.95, na.rm = TRUE),
    c0_90 = quantile(C0, 0.90, na.rm = TRUE),
    c0_75 = quantile(C0, 0.75, na.rm = TRUE),
    c0_50 = quantile(C0, 0.50, na.rm = TRUE),
    c0_25 = quantile(C0, 0.25, na.rm = TRUE),
    c0_10 = quantile(C0, 0.10, na.rm = TRUE),
    c0_5 = quantile(C0, 0.05, na.rm = TRUE),
    c0_1 = quantile(C0, 0.01, na.rm = TRUE),
    c0_.1 = quantile(C0, 0.001, na.rm = TRUE),
    c0_.01 = quantile(C0, .0001, na.rm = TRUE),
    c0_Count = n()
  )

C0_C16C18.stats <- df %>%
  summarise(
    C0_C16C18_mean = mean(C0_C16C18, na.rm = TRUE),
    C0_C16C18_median = median(C0_C16C18, na.rm = TRUE),
    C0_C16C18_min = min(C0_C16C18, na.rm = TRUE),
    C0_C16C18_max = max(C0_C16C18, na.rm = TRUE),
    C0_C16C18_sd = sd(C0_C16C18, na.rm = TRUE),
    C0_C16C18_999 = quantile(C0_C16C18, 0.999, na.rm = TRUE),
    C0_C16C18_995 = quantile(C0_C16C18, 0.995, na.rm = TRUE),
    C0_C16C18_99 = quantile(C0_C16C18, 0.99, na.rm = TRUE),
    C0_C16C18_95 = quantile(C0_C16C18, 0.95, na.rm = TRUE),
    C0_C16C18_90 = quantile(C0_C16C18, 0.90, na.rm = TRUE),
    C0_C16C18_75 = quantile(C0_C16C18, 0.75, na.rm = TRUE),
    C0_C16C18_50 = quantile(C0_C16C18, 0.50, na.rm = TRUE),
    C0_C16C18_25 = quantile(C0_C16C18, 0.25, na.rm = TRUE),
    C0_C16C18_10 = quantile(C0_C16C18, 0.10, na.rm = TRUE),
    C0_C16C18_5 = quantile(C0_C16C18, 0.05, na.rm = TRUE),
    C0_C16C18_1 = quantile(C0_C16C18, 0.01, na.rm = TRUE),
    C0_C16C18_.1 = quantile(C0_C16C18, 0.001, na.rm = TRUE),
    C0_C16C18_.01 = quantile(C0_C16C18, .0001, na.rm = TRUE),
    C0_C16C18_Count = n()
  )

#Summary statistics with different grouping options (Shown here: Age group <120h and Age group >=120h)
c0.stats <- df %>%
  group_by(age_group) %>%
  summarise(
    c0_mean = mean(C0, na.rm = TRUE),
    c0_median = median(C0, na.rm = TRUE),
    c0_min = min(C0, na.rm = TRUE),
    c0_max = max(C0, na.rm = TRUE),
    c0_sd = sd(C0, na.rm = TRUE),
    c0_999 = quantile(C0, 0.999, na.rm = TRUE),
    c0_995 = quantile(C0, 0.995, na.rm = TRUE),
    c0_99 = quantile(C0, 0.99, na.rm = TRUE),
    c0_95 = quantile(C0, 0.95, na.rm = TRUE),
    c0_90 = quantile(C0, 0.90, na.rm = TRUE),
    c0_75 = quantile(C0, 0.75, na.rm = TRUE),
    c0_50 = quantile(C0, 0.50, na.rm = TRUE),
    c0_25 = quantile(C0, 0.25, na.rm = TRUE),
    c0_10 = quantile(C0, 0.10, na.rm = TRUE),
    c0_5 = quantile(C0, 0.05, na.rm = TRUE),
    c0_1 = quantile(C0, 0.01, na.rm = TRUE),
    c0_.1 = quantile(C0, 0.001, na.rm = TRUE),
    c0_.01 = quantile(C0, .0001, na.rm = TRUE),
    c0_Count = n()
  )

C0_C16C18.stats <- df %>%
  group_by(age_group) %>%
  summarise(
    C0_C16C18_mean = mean(C0_C16C18, na.rm = TRUE),
    C0_C16C18_median = median(C0_C16C18, na.rm = TRUE),
    C0_C16C18_min = min(C0_C16C18, na.rm = TRUE),
    C0_C16C18_max = max(C0_C16C18, na.rm = TRUE),
    C0_C16C18_sd = sd(C0_C16C18, na.rm = TRUE),
    C0_C16C18_999 = quantile(C0_C16C18, 0.999, na.rm = TRUE),
    C0_C16C18_995 = quantile(C0_C16C18, 0.995, na.rm = TRUE),
    C0_C16C18_99 = quantile(C0_C16C18, 0.99, na.rm = TRUE),
    C0_C16C18_95 = quantile(C0_C16C18, 0.95, na.rm = TRUE),
    C0_C16C18_90 = quantile(C0_C16C18, 0.90, na.rm = TRUE),
    C0_C16C18_75 = quantile(C0_C16C18, 0.75, na.rm = TRUE),
    C0_C16C18_50 = quantile(C0_C16C18, 0.50, na.rm = TRUE),
    C0_C16C18_25 = quantile(C0_C16C18, 0.25, na.rm = TRUE),
    C0_C16C18_10 = quantile(C0_C16C18, 0.10, na.rm = TRUE),
    C0_C16C18_5 = quantile(C0_C16C18, 0.05, na.rm = TRUE),
    C0_C16C18_1 = quantile(C0_C16C18, 0.01, na.rm = TRUE),
    C0_C16C18_.1 = quantile(C0_C16C18, 0.001, na.rm = TRUE),
    C0_C16C18_.01 = quantile(C0_C16C18, .0001, na.rm = TRUE),
    C0_C16C18_Count = n()
  )


# --- Step 4: In Silico Analysis ---
#Update field names and values to reflect analyte and cutoffs being tested 
#Add/modify result variables if needing to count different results
#Always perform analysis with current cutoffs to retrieve baseline
C0_hight <- 70
C0_ratiot <- 85
high_ratiot <- 150

norm_cpt <- df_clean %>%
  filter(C0_C16C18 < C0_ratiot)

#Counts stratified by age group
norm_counts <- norm_cpt %>%
  group_by(age_group) %>%
  summarize(n = n())

bdr_cpt <- df_clean %>%
  filter(C0 < C0_hight & C0_C16C18 >= C0_ratiot & C0_C16C18 <= high_ratiot)

#Counts stratified by age group
bdr_counts <- bdr_cpt %>%
  group_by(age_group) %>%
  summarize(n = n())

abn_cpt <- df_clean %>%
  filter(C0 >= C0_hight & C0_C16C18 >= C0_ratiot & C0_C16C18 <= high_ratiot)

#Counts stratified by age group
abn_counts <- abn_cpt %>%
  group_by(age_group) %>%
  summarize(n = n())

high_cpt <- df_clean %>%
  filter(C0_C16C18 > high_ratiot)

#Counts stratified by age group
high_counts <- high_cpt %>%
  group_by(age_group) %>%
  summarize(n = n())

norm_counts
bdr_counts
abn_counts
high_counts

# --- Step 5: (optional) Plot Distributions ---
#Use library you are comfortable with to plot the distributions of analyte values
#Use different methods to highlight differences call
