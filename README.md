# COVID-19 Data Analysis Project

## Project Overview
This project demonstrates my skills in data analysis, including data cleaning, processing, querying, data analysis and data visualization. 
The raw and processed data are used to create tables in a MySQL database, which are then queried and visualized using Power BI. 

### COVID-19-Data-Analysis-and-Visualization/Raw_Sample_Data/ Folder
Due to the large size of the original dataset, this repository includes a subset of the data for demonstration purposes. 
The sample raw data files are located in the data/sample_raw_data/ folder which includes:

- `raw_Sample_data/Sample_data.csv`: The original raw data file with 1000 sample rows.
#### Processed Data from Original File
- `raw_sample_data/sample.covid_deaths.csv`: A sample file containing COVID-19 death statistics,
   featuring metrics such as total and new deaths, total and new cases and much more information about the infection worldwide.
  
- `raw_sample_data/sample.covid_vacc2.csv`: A sample file with COVID-19 vaccination data, including details on vaccination counts all over the world.
#### Original Dataset
- The complete original COVID-19 dataset, which includes data from 2020 to 2024, can be accessed from the following source:
  [this link](https://ourworldindata.org/coronavirus)
### SQL Scripts

#### Database Setup
- `sqldb_setup/table_definitions.sql`: Script to create the database schema and indexes.
- `sqldb_setup/Table_DataImport.sql`: Script to import processed data from excel into MYSQL database.

### Queries and Views
This file contains comprehensive SQL queries and in-depth analysis of the data. 
It includes complex queries using temporary tables, stored procedures, and views, providing detailed insights into the dataset.

## Power BI Report
- View the INTERACTIVE POWERBI report online using [this link](https://bit.ly/4bMZE7O)
