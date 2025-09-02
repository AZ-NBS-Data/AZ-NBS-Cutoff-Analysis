# Newborn Screening SQL Scripts

This repository contains example SQL queries used in the Arizona Newborn Screening Program for data extraction, reporting, and cutoff analysis.  
The scripts are designed to run against the **NATUS Neometrics LIMS (Oracle SQL environment)** and may require adaptation for other systems.  

---

## 📂 Contents
- `cutoff_analysis_query.sql`  
  Example query for retrieving analyte data by condition. This script joins disorder, result, and lab accession tables to extract data used for cutoff analysis and quality monitoring.

---

## ⚙️ Usage
1. Open the SQL script in your preferred SQL editor or database client (e.g., SQL Developer, DBeaver, or TOAD).  
2. Connect to the **NATUS Neometrics LIMS database**.  
3. Modify the `WHERE` clause filters (e.g., condition, date range, analyte) as needed.  
4. Run the query to extract the dataset for further analysis in R, Python, or Power BI.  
