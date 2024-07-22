
/* This script creates the 'covid_deaths' table to store and manage comprehensive data on COVID-19 infections across vairous locations. The table includes columns for key statistics such as total and new cases,
-- total and new deaths, and other COVID-19 related metrics. This table is used to creating multiple queries and views. */

create table covid_deaths
(
	iso_code char(50),
    Continent varchar(50),
    Location varchar(255),
    population bigint,
    Date_occured date,
    total_cases int null,
    new_cases int null,
    total_deaths int null,
    new_deaths int null,
    icu_patients int null,
    hosp_patients int null,
    total_tests int null,
    new_tests int null,
    positive_rate int null
    )

-- Displays the empty table with all the created columns
select * from covid_deaths


/* This script creates the 'covid_vaccination' table, which mirrors the location and date structure of the 'covid_deaths' table and is also 
designed to store comprehensive data on COVID-19 vaccinations worldwide, allowing for integrated querying with the 'covid_deaths' table. */

create table covid_vacc2
    (
    iso_code char(50),
    Continent varchar(50),
    Location varchar(255),
	Date_occured date,
	population bigint,
    total_vaccinations int ,
    people_vaccinated int ,
    people_fully_vaccinated int ,
    total_boosters int,
    new_vaccinations int ,
    median_age int,
    aged_65_older int,
    aged_70_older int , 
    Diabetes_prevalence int,
    female_smokers int ,
    male_smokers int 
    )
    
-- Confirms the table creation with the empty rows and respective columns.
    
select * from covid_vacc2

/* Create an index for the following column to enhance performance for 
queries that filter or sort records based on the columns. */
 
CREATE INDEX idx_date ON covid_deaths (date_occured);
CREATE INDEX idx_location_total_cases_deaths ON covid_deaths (location, totak_cases, total_deaths);
