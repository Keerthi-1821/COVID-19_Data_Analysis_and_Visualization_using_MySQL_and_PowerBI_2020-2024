# COVID-19 Data Analysis Project (2020-2024)

## Project Overview
This project shows my skills in data analysis, including data cleaning, processing, querying, analysis, and visualization. The dataset encompasses comprehensive COVID-19 information from 2020 to 2024, covering details about cases, deaths, vaccinations, and more. The raw and processed data were used to create tables in a MySQL database. These tables were then queried in MYSQL and visualized using Power BI to provide insightful data visualizations.

### COVID-19-Data-Analysis-and-Visualization/Raw_Sample_Data/ Folder
Due to the large size of the original dataset, this repository includes a subset of the data for demonstration purposes. 
The sample raw data files are located in the data/sample_raw_data/ folder which includes:

- `raw_Sample_data/Sample_data.csv`: The original raw data file with 1000 sample rows.
#### Processed Data from Original File
- `raw_sample_data/sample.covid_deaths.csv`: A sample file containing COVID-19 death statistics,
   featuring metrics such as total and new deaths, total and new cases, and much more information about the infection worldwide.
  
- `raw_sample_data/sample.covid_vacc2.csv`: A sample file with COVID-19 vaccination data, including details on vaccination counts worldwide.
#### Original Dataset
- The complete original COVID-19 dataset, which includes data from 2020 to 2024, can be accessed from the following source:
  [Original Data File](https://ourworldindata.org/coronavirus)
  
### COVID-19-Data-Analysis-and-Visualization/sqldb_setup/ Folder 
#### Database Setup
- `sqldb_setup/table_definitions.sql`: Script to create the database schema and indexes.
- `sqldb_setup/Table_DataImport.sql`: Script to import processed data from Excel into MYSQL database.

### Power BI Visualization File 
- 'CovidProjectReportPBI.pbix': This consists of all the visualizations and related Data Models
  
### Queries and Views
- `SQLQueriesandViews.sql` - This file contains comprehensive SQL queries and in-depth analysis of the data. 
  It includes complex queries using temporary tables, stored procedures, and views, providing detailed insights into the dataset.

## Power BI Report
- View the INTERACTIVE POWERBI report online using [PowerBI Report](https://bit.ly/4bMZE7O)
