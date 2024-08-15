/* Retrieve all records from the covid_deaths table and covid_vacc2 where the continent column is not null
and order the results by the 3rd and 4th columns for better readability and analysis.*/
SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT *
FROM covid_vacc2
WHERE continent IS NOT NULL
ORDER BY 3,4 

/*Update the covid_deaths table to set the continent column to null where it is an empty string
to ensure data consistency and to handle missing values properly.*/
UPDATE covid_deaths
SET continent = NULL
WHERE continent = '';

 -- Select specific columns from the covid_deaths table for chronological analysis of COVID-19 data per location.

SELECT LOCATION,
       date_occured,
       total_cases,
       total_deaths,
       population
FROM covid_deaths
ORDER BY 1, 2

-- Create a view to identify locations with the TOTAL number of COVID-19 cases per population percentage and also total cases.

DROP VIEW IF EXISTS Total_cases_per_country;

CREATE VIEW Total_cases_per_country AS
  (
  SELECT location,
          population,
          max(total_cases) AS Confirmed_cases,
          max((total_cases/population))*100 AS Total_cases_percent
   FROM covid_deaths
   WHERE continent IS NOT NULL
   GROUP BY location,
            population
   );

SELECT *
FROM Total_cases_per_country
order by Total_cases_percent desc;



 /*Create a view to aggregate total COVID-19 cases by season (Winter, Spring, Summer, Fall) in each country.
This involves first grouping data by month, then mapping months to seasons, and finally summing cases per season. */

DROP VIEW IF EXISTS Seasonal_total_cases;

CREATE VIEW Seasonal_total_cases AS ( 
WITH monthwise AS (
SELECT location,
       population,
       month(date_occured) monthlynum,
       monthname(date_occured) monthly,
       sum(new_cases) total_new_cases
FROM covid_Deaths
WHERE continent IS NOT NULL
GROUP BY LOCATION,
         population,
         month(date_occured)
),
seasonal AS
  (
  SELECT location,
          population,
          total_new_cases,
          CASE
              WHEN monthlynum IN (12,1,2) THEN 'winter'
              WHEN monthlynum IN (3,4,5) THEN 'Spring'
              WHEN monthlynum IN (6,7,8) THEN 'Summer'
              ELSE 'Fall'
          END AS season
   FROM monthwise 
   )
SELECT LOCATION,
       population,
       season,
       sum(total_new_cases) AS totalcases_per_season
FROM seasonal
GROUP BY location,
         population,
         season
ORDER BY location ASC, totalcases_per_season DESC 
);

SELECT *
FROM seasonal_total_cases;


-- Create a CTE to calculate and rank the top 2 death percentages per country based on the ratio of total deaths to total cases.

WITH death_per AS
  (
  SELECT LOCATION,
          date_occured,
          total_cases,
          total_deaths,
          population,
          (total_deaths/total_cases)*100 AS death_percentage
   FROM covid_deaths
   WHERE continent IS NOT NULL 
   )
SELECT *
FROM
  (SELECT *,
          dense_rank() over (partition BY location ORDER BY death_percentage DESC) AS top3_death_rate
   FROM death_per ) Top_3
WHERE top3_death_rate IN (1, 2);
 
 
-- Create a view to identify the TOTAL number of deaths per country.
DROP VIEW IF EXISTS Total_deaths_per_country;

CREATE VIEW Total_deaths_per_country AS
  (
  SELECT location,
          population,
          max(total_deaths) AS confirmed_deaths
   FROM covid_deaths
   WHERE continent IS NOT NULL
   GROUP BY location, population);

SELECT *
FROM Total_deaths_per_country
ORDER BY confirmed_deaths DESC;


-- Create a view to identify the TOTAL number of deaths per Continent.

DROP VIEW IF EXISTS Total_deaths_per_continent;

CREATE VIEW Total_deaths_per_continent AS
  (
  SELECT continent, MAX(total_deaths) AS confirmed_deaths
   FROM covid_deaths
   WHERE continent IS NOT NULL
   GROUP BY continent);

SELECT *
FROM Total_deaths_per_continent
ORDER BY confirmed_deaths DESC;


-- Create a view to calculate the overall GLOBAL COVID-19 cases and deaths and also overall death percentage.

DROP VIEW IF EXISTS overall_cases_deaths;

CREATE VIEW overall_cases_deaths AS
  (SELECT sum(new_cases) total_covid_Cases,
			sum(new_deaths) overall_deaths,
				(sum(new_deaths)/sum(new_cases))*100 AS overall_covid_death_percentage
   FROM covid_deaths
   WHERE continent IS NOT NULL
   );

SELECT *
FROM overall_cases_deaths;


/* Create a view to calculate the YEARLY DEATH RATE by summing new cases and deaths for each year 
and calculating the death percentage based on these sums. */

DROP VIEW IF EXISTS yearly_death_rate;

CREATE VIEW yearly_death_rate AS
  (SELECT year(date_occured) AS yearly,
          sum(new_cases) AS sumofcases,
          sum(new_deaths) AS sumofdeaths,
          (sum(new_deaths)/sum(new_cases))*100 AS death_percentage
   FROM covid_deaths
   WHERE continent IS NOT NULL
   GROUP BY year(date_occured)
   );

SELECT *
FROM yearly_death_rate
ORDER BY yearly, sumofcases;


/*Create a CTE to calculate the rolling number of vaccinations per country 
and determine the total percentage of the population vaccinated over time. */

WITH vacc_per_population (continent, location, date_occured, population, new_vaccinations, rolling_people_vaccinated) AS
  (
  SELECT dea.continent, dea.location, dea.date_occured, dea.population, vac.new_vaccinations, 
			sum(vac.new_vaccinations) over (partition BY dea.location ORDER BY dea.location, dea.date_occured) AS rolling_people_vaccinated
   FROM covid_deaths dea
   JOIN covid_vacc2 vac ON dea.location = vac.location
   AND dea.date_occured = vac.date_occured
   WHERE dea.continent IS NOT NULL)
SELECT LOCATION, population,
       (max(rolling_people_vaccinated)/population)*100 AS Total_people_vaccinated
FROM vacc_per_population
GROUP BY location, population
ORDER BY location ASC;


-- Create a view to identify the TOTAL DEATHS PER CASES ratio per country.

DROP VIEW IF EXISTS total_confirmed_deaths_percent;

CREATE VIEW total_confirmed_deaths_percent AS
  (SELECT location,
          population,
          max(total_deaths) AS confirmed_deaths,
          max(total_cases) AS confirmed_Cases,
          max(total_deaths/total_cases)*100 AS death_percent
   FROM covid_deaths
   WHERE continent IS NOT NULL
   GROUP BY location, population);

SELECT *
FROM total_confirmed_deaths_percent
ORDER BY location;


-- Create a stored procedure to calculate the death percentage based on total cases notified for a given country for each day.

DROP PROCEDURE IF EXISTS death_percentage 
DELIMITER $$
CREATE PROCEDURE death_percentage (IN country varchar(255)) BEGIN
SELECT location,
       date_occured,
       total_cases,
       total_deaths,
       population,
       (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE LOCATION = country; 
END 
$$ DELIMITER ;

 CALL death_percentage('United Kingdom');


-- Create a temporary table to identify the FIRST CASES in each country along with the respective date occurred.

DROP TABLE IF EXISTS first_cases;

CREATE TEMPORARY TABLE First_cases (
				location varchar(255), 
				mincase numeric, 
                date_occured date, 
                continent varchar(255), 
                num numeric
                );

 -- Insert the first cases data into the temporary table.

INSERT INTO first_cases (location, mincase, date_occured, continent, num)
SELECT location,
       mincase,
       date_occured,
       continent,
       ROW_NUMBER() OVER (PARTITION BY location ORDER BY date_occured) AS num
FROM
  ( SELECT location,
           MIN(total_cases) AS mincase,
           date_occured,
           continent
   FROM covid_deaths
   WHERE continent IS NOT NULL
   GROUP BY location,
            date_occured) AS first_cases_list
WHERE mincase IS NOT NULL;

SELECT *
FROM first_cases
WHERE num =1
ORDER BY mincase DESC;


-- Create a stored procedure to calculate the vaccination coverage rate with the cases ratio for a given country.

DROP TEMPORARY TABLE IF EXISTS ratio;


DROP PROCEDURE IF EXISTS rate_vaccinations;

 DELIMITER $$
CREATE PROCEDURE rate_vaccinations(IN country varchar(255)) 
BEGIN 
-- Create a temporary table to store the yearly vaccination data.
CREATE TEMPORARY TABLE temp_vaccinations AS
SELECT cd.location,
       SUM(cv.new_vaccinations) AS yearly_vaccine,
       YEAR(cd.date_occured) AS yearly,
       max(cd.total_cases) AS max_cases
FROM covid_vacc2 cv
JOIN covid_deaths cd ON cv.location = cd.location
AND cv.date_occured = cd.date_occured
WHERE cd.continent IS NOT NULL
  AND cd.location = country
GROUP BY cd.location, yearly
ORDER BY location;
CREATE TEMPORARY TABLE ratio AS
SELECT location,
       yearly_vaccine,
       yearly,
       max_cases,
       (yearly_vaccine / max_cases) AS ratio_vacc_cases
FROM temp_vaccinations;
SELECT *
FROM ratio
ORDER BY location;
DROP
TEMPORARY TABLE temp_vaccinations; 
END 
$$ DELIMITER ;

 CALL rate_vaccinations('united kingdom');

-- Create a view to get FULLY VACCINATED information percent per country.

DROP VIEW IF EXISTS fully_vacc_information;
CREATE VIEW fully_vacc_information AS (WITH fully_vaccination_percent (location, population, fully_vaccinated, fully_vaccinated_rate, includes_partially_vaccinated, Rate_of_vaccinated_people) AS
                                         (SELECT location,
                                                 population,
                                                 max(people_fully_vaccinated) AS fully_vaccinated,
                                                 max((people_fully_vaccinated/population))*100 AS fully_vaccinated_rate,
                                                 max(total_vaccinations) AS includes_partially_vaccinated,
                                                 max((total_vaccinations/population))*100 AS Rate_of_vaccinated_people
                                          FROM covid_vacc2
                                          WHERE continent IS NOT NULL
                                          GROUP BY location, population
                                          ORDER BY location
                                          )
                                       SELECT *
                                       FROM fully_vaccination_percent
                                       )
                                       
-- Select all records from the fully_vacc_information view.

SELECT *
FROM fully_vacc_information


-- Create a view to identify the maximum vaccinations provided per DAY in each country.

DROP VIEW IF EXISTS maximum_vaccination_per_day
CREATE VIEW maximum_vaccination_per_day AS
  (SELECT t1.location,
          t1.new_vaccinations,
          t2.date_occured FROM
     (SELECT LOCATION, MAX(new_vaccinations) AS new_vaccinations
      FROM covid_vacc2
      WHERE continent IS NOT NULL
      GROUP BY LOCATION) t1
   JOIN covid_vacc2 t2 ON t1.LOCATION = t2.LOCATION
   AND t1.new_vaccinations = t2.new_vaccinations
   WHERE continent IS NOT NULL)
SELECT *
FROM maximum_vaccination_per_day


-- Create a view to identify the highest vaccination YEAR.

DROP VIEW IF EXISTS highest_vaccination_year
CREATE VIEW highest_vaccination_year AS (
WITH rate_vaccinations AS
				(SELECT cd.location,
						sum(cv.new_vaccinations) AS yearly_vaccine,
						year(cd.date_occured) AS yearly,
						sum(cd.new_cases) AS new_cases
				  FROM covid_vacc2 cv
				  JOIN covid_deaths cd ON cv.location=cd.location AND cv.date_occured = cd.date_occured
				  WHERE cd.continent IS NOT NULL
				  GROUP BY cd.location, year(cd.date_occured)),
max_vacc AS
				(SELECT max(yearly_vaccine) AS max_vaccination, location
				 FROM rate_vaccinations
				 GROUP BY location
                 )
                 
SELECT rv.location, rv.yearly, rv.new_cases, mv.max_vaccination
FROM rate_vaccinations rv
JOIN max_vacc mv ON rv.location = mv.location
				AND rv.yearly_vaccine = mv.max_vaccination) 
                
-- Select all records from the maximum_vaccination_per_day view.

SELECT *
FROM highest_vaccination_year


-- Create a view to identify the highest vaccinations done in a MONTH of the year by country.

DROP VIEW IF EXISTS highest_vaccination_month_year
CREATE VIEW highest_vaccination_month_year AS ( WITH vacc_month AS
  (SELECT cd.location,
          sum(new_cases) cases,
			sum(new_vaccinations) vacc, date_format(cd.date_occured, '%M-%Y') monthly
   FROM covid_deaths cd
   JOIN covid_vacc2 cv ON cd.location = cv.location
   AND cd.date_occured = cv.date_occured
   WHERE cd.continent IS NOT NULL
   GROUP BY cd.location,
            monthly),
max_vacc AS
  (SELECT location, MAX(vacc) maximum_vacc_location_monthly, monthly, cases
   FROM vacc_month
   GROUP BY LOCATION,
            monthly)
SELECT vm.LOCATION,
          vm.cases,
          vm.monthly,
          mv.maximum_vacc_location_monthly
FROM vacc_month vm
JOIN max_vacc mv
on vm.location = mv.location
and vm.vacc = mv.maximum_vacc_location_monthly
)

select * 
from highest_vaccination_month_year

