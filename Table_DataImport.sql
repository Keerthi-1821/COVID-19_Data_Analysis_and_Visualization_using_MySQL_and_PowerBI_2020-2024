
-- Data import - Load data into covid_deaths table.

load data infile 'C:/covid_deaths.csv' into table covid_deaths
fields terminated by ','
lines terminated by '\r\n'
ignore 1 rows
(iso_code, continent, location, population, date_occured, @total_cases, @new_cases, @total_deaths, @new_deaths,	@icu_patients, @hosp_patients, @total_tests, @new_tests, @positive_rate)
set
	total_cases = nullif(@total_cases, ''),
    new_cases = nullif(@new_cases, ''),
	total_deaths = nullif(@total_deaths, ''),
	new_deaths = nullif(@new_deaths, ''),
	icu_patients = nullif(@ice_patients, ''),
	hosp_patients = nullif(@hosp_patients, ''),
	total_tests = nullif(@total_tests, ''),
	new_tests = nullif(@new_tests, ''),
	positive_rate = nullif(@positive_rate, '');

-- Displays the entire covid_deaths table with all columns, replacing any empty strings with NULL values to improve the accuracy and efficiency of querying.    
   select * from covid_deaths
    
    
-- Data import - Load data into covid_vacc2 table.
  
    load data infile 'C:/updatecsvtable.csv' into table covid_vacc2
    fields terminated by ','
    lines terminated by '\r\n'
    ignore 1 rows
    (iso_code, continent, location,	date_occured, population, @total_vaccinations, @people_vaccinated, @people_fully_vaccinated, @total_boosters, @new_vaccinations, @median_age, @aged_65_older, @aged_70_older, @diabetes_prevalence,
    @female_smoker, @male_smokers)
    set
	total_vaccinations = nullif(@total_vaccinations, ''),
    people_vaccinated = nullif(@people_vaccinated, ''),
    people_fully_vaccinated = nullif(@people_fully_vaccinated, ''),
    total_boosters = nullif(@total_boosters, ''),
    new_vaccinations = nullif(@new_vaccinations, ''),
    median_age = nullif(@median_age, ''),
    aged_65_older = nullif(@aged_65_older, ''),
    aged_70_older = nullif(@aged_70_older, ''),
    Diabetes_prevalence = nullif(@Diabetes_prevalence, ''),
    female_smokers = nullif(@female_smokers, ''),
    male_smokers = nullif(@male_smokers, '');


-- Displays the entire covid_vacc2 table with all columns, replacing any empty strings with NULL values to improve the accuracy and efficiency of querying.    
   select * from covid_vacc2;