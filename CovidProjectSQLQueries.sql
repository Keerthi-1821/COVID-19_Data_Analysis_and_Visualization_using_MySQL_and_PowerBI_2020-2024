/* Retrieve all records from the covid_deaths table and covid_vacc2 where the continent column is not null 
and order the results by the 3rd and 4th columns for better readability and analysis.*/

select * from covid_deaths
where continent is not null
order by 3,4

select * from covid_vacc2
where continent is not null
order by 3,4

/*Update the covid_deaths table to set the continent column to null where it is an empty string 
to ensure data consistency and to handle missing values properly.*/

update covid_deaths
set continent = null
where continent = '';
 
-- Select specific columns from the covid_deaths table for chronological analysis of COVID-19 data per location.

select location, date_occured, total_cases, total_deaths, population
from covid_deaths
order by 1,2

-- Create a view to identify locations with the TOTAL number of COVID-19 cases per population percentage and also total cases.

drop view if exists Total_cases_per_country
create view Total_cases_per_country as (
select location, population, max(total_cases) as Confirmed_cases, max((total_cases/population))*100 as Total_cases_percent
from covid_deaths
where continent is not null
group by location, population
order by location 
)
select * from Total_cases_per_country


 /*Create a view to aggregate total COVID-19 cases by season (Winter, Spring, Summer, Fall) in each country.
This involves first grouping data by month, then mapping months to seasons, and finally summing cases per season. */

drop view if exists Seasonal_total_cases
create view Seasonal_total_cases as (
with monthwise as (
select location, population, month(date_occured) monthlynum, monthname(date_occured) monthly, sum(new_cases) total_new_cases
from covid_Deaths
where continent is not null
group by location, population, month(date_occured)
),
seasonal as (
select location, population, total_new_cases,
case
	when monthlynum in (12,1,2) then 'winter'
    when monthlynum in (3,4,5) then 'Spring'
    when monthlynum in (6,7,8) then 'Summer'
    else
    'Fall'
end as season
    from monthwise
    )
    select location, population, season, sum(total_new_cases) as totalcases_per_season
    from seasonal
    group by location, population, season
	order by location asc, totalcases_per_season desc
)
select * from seasonal_total_cases


-- Create a CTE to calculate and rank the top 2 death percentages per country based on the ratio of total deaths to total cases.

with death_per as (
select location, date_occured, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage 
from covid_deaths
where continent is not null
order by location asc, death_percentage desc 
 )
 select *
 from (select *, dense_rank() over (partition by location order by death_percentage desc) as top3_death_rate
 from death_per
 ) Top_3
 where top3_death_rate in (1,2);
 
 
-- Create a view to identify the TOTAL number of deaths per country.
drop view if exists Total_deaths_per_country
create view Total_deaths_per_country as (
select location, population, max(total_deaths) as confirmed_deaths
from covid_deaths
where continent is not null
group by location, population
order by confirmed_deaths desc
)
select * from Total_deaths_per_country


-- Create a view to identify the TOTAL number of deaths per Continent.

drop view if exists Total_deaths_per_continent
create view Total_deaths_per_continent as (
select continent, max(total_deaths) as confirmed_deaths
from covid_deaths
where continent is not null
group by continent
order by confirmed_deaths desc
)
select * from Total_deaths_per_continent


-- Create a view to calculate the overall GLOBAL COVID-19 cases and deaths and also overall death percentage.

drop view if exists overall_cases_deaths
create view overall_cases_deaths as (
select sum(new_cases) total_covid_Cases, sum(new_deaths) overall_deaths, (sum(new_deaths)/sum(new_cases))*100 as overall_covid_death_percentage
from covid_deaths
where continent is not null
order by 1,2
)
select * from overall_cases_deaths

/* Create a view to calculate the YEARLY DEATH RATE by summing new cases and deaths for each year 
and calculating the death percentage based on these sums. */

drop view if exists yearly_death_rate
create view yearly_death_rate as (
select year(date_occured) as yearly, sum(new_cases) as sumofcases, sum(new_deaths) as sumofdeaths,  (sum(new_deaths)/sum(new_cases))*100 as death_percentage
from covid_deaths
where continent is not null
group by year(date_occured)
order by 1,2
)
select * from yearly_death_rate

/*Create a CTE to calculate the rolling number of vaccinations per country 
and determine the total percentage of the population vaccinated over time. */

With vacc_per_population (continent, location, date_occured, population, new_vaccinations, rolling_people_vaccinated)
as
 (
select dea.continent, dea.location, dea.date_occured, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date_occured) as rolling_people_vaccinated
from covid_deaths dea
join covid_vacc2 vac
on dea.location = vac.location
and dea.date_occured = vac.date_occured
where dea.continent is not null 
order by 2,3
)
select location, population, (max(rolling_people_vaccinated)/population)*100 as Total_people_vaccinated
from vacc_per_population
group by location, population
order by location asc


-- Create a view to identify the TOTAL DEATHS PER CASES ratio per country.

DROP VIEW IF EXISTS total_confirmed_deaths_percent;
create view total_confirmed_deaths_percent as
(
select location, population, max(total_deaths) as confirmed_deaths, max(total_cases) as confirmed_Cases,  max(total_deaths/total_cases)*100 as death_percent
from covid_deaths
where continent is not null
group by location, population
order by location  
)
select * from total_confirmed_deaths_percent


-- Create a stored procedure to calculate the death percentage based on total cases notified for a given country for each day.

drop procedure if exists death_percentage
delimiter $$
create procedure death_percentage (in country varchar(255))
begin
select location, date_occured, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths
where location = country;
end $$
delimiter ;
call death_percentage('United Kingdom')


-- Create a temporary table to identify the FIRST CASES in each country along with the respective date occurred.

drop table if exists first_cases;
create temporary table First_cases
(
location varchar(255),
mincase numeric,
date_occured date,
continent varchar(255),
num numeric
);
-- -- Insert the first cases data into the temporary table.
insert into first_cases 
WITH first_cases_list (location, mincase, date_occured, continent)
as
(
select location, min(total_cases) as mincase, date_occured, continent
from covid_deaths
where continent is not null
group by location, date_occured
)
select *,row_number() over (partition by location) as num from first_cases_list
where mincase is not null 
order by location ;

select * from first_cases
where num =1
order by mincase desc; 


-- Create a stored procedure to calculate the vaccination coverage rate with the cases ratio for a given country.

drop temporary table if exists ratio;
DROP PROCEDURE IF EXISTS rate_vaccinations;
DELIMITER $$
CREATE PROCEDURE rate_vaccinations(in country varchar(255))
BEGIN
    drop temporary table if exists ratio;
	DROP temporary table IF EXISTS rate_vaccinations;
-- Create a temporary table to store the yearly vaccination data.
    CREATE TEMPORARY TABLE temp_vaccinations AS
    SELECT cd.location, SUM(cv.new_vaccinations) AS yearly_vaccine, YEAR(cd.date_occured) AS yearly, max(cd.total_cases) AS max_cases 
    FROM covid_vacc2 cv
    JOIN covid_deaths cd ON cv.location = cd.location AND cv.date_occured = cd.date_occured
    WHERE cd.continent IS NOT NULL and cd.location = country
    GROUP BY cd.location, yearly
    ORDER BY location;
    
    CREATE TEMPORARY TABLE ratio AS
    SELECT location, yearly_vaccine, yearly, max_cases, (yearly_vaccine / max_cases) AS ratio_vacc_cases
    FROM temp_vaccinations;
        
    SELECT * from ratio
    order by location;
    
    DROP TEMPORARY TABLE temp_vaccinations;
END $$
DELIMITER ;

call rate_vaccinations('united kingdom');

-- Create a view to get FULLY VACCINATED information percent per country.

drop view if exists fully_vacc_information
create view fully_vacc_information as
(
WITH fully_vaccination_percent  (location, population, fully_vaccinated, fully_vaccinated_rate, includes_partially_vaccinated, Rate_of_vaccinated_people) as
 (
select location, population, max(people_fully_vaccinated) as fully_vaccinated, max((people_fully_vaccinated/population))*100 as fully_vaccinated_rate, max(total_vaccinations) as includes_partially_vaccinated, max((total_vaccinations/population))*100 as Rate_of_vaccinated_people
from covid_vacc2
where continent is not null
group by location, population
order by location 
)
select * from fully_vaccination_percent
)
-- Select all records from the fully_vacc_information view.
select * from fully_vacc_information


-- Create a view to identify the maximum vaccinations provided per DAY in each country.

drop view if exists maximum_vaccination_per_day
create view maximum_vaccination_per_day as
 (
SELECT t1.location, t1.new_vaccinations, t2.date_occured
FROM(SELECT location, MAX(new_vaccinations) AS new_vaccinations
     FROM covid_vacc2
     WHERE continent IS NOT NULL
     GROUP BY location) t1
JOIN covid_vacc2 t2
ON t1.location = t2.location AND t1.new_vaccinations = t2.new_vaccinations
WHERE continent IS NOT NULL
order by new_vaccinations desc
)
select * from maximum_vaccination_per_day


-- Create a view to identify the highest vaccination YEAR.

drop view if exists highest_vaccination_year
create view highest_vaccination_year as (
WITH rate_vaccinations as
(
select cd.location, sum(cv.new_vaccinations) as yearly_vaccine, year(cd.date_occured) as yearly, sum(cd.new_cases) as new_cases
from covid_vacc2 cv
join covid_deaths cd
on cv.location=cd.location
and cv.date_occured = cd.date_occured
where cd.continent is not null
group by cd.location, year(cd.date_occured)
),
max_vacc as (
select max(yearly_vaccine) as max_vaccination, location
from rate_vaccinations
group by location
)
select rv.location, rv.yearly, rv.new_cases, mv.max_vaccination
from rate_vaccinations rv
join max_vacc mv
on rv.location = mv.location and rv.yearly_vaccine = mv.max_vaccination
)
-- Select all records from the maximum_vaccination_per_day view.
select * from highest_vaccination_year


-- Create a view to identify the highest vaccinations done in a MONTH of the year by country.

drop view if exists highest_vaccination_month_year
create view highest_vaccination_month_year as (
with vacc_month as
(
select cd.location, sum(new_cases) cases, sum(new_vaccinations) vacc, date_format(cd.date_occured, '%M-%Y') monthly
from covid_deaths cd
join covid_vacc2 cv
on cd.location = cv.location and cd.date_occured = cv.date_occured
where cd.continent is not null
group by cd.location, monthly
order by location, vacc desc
),
max_vacc as
(
select location, max(vacc) maximum_vacc_location_monthly, monthly, cases
from vacc_month
group by location
)
select vm.location, vm.cases, vm.monthly, mv.maximum_vacc_location_monthly
from vacc_month vm
join max_vacc mv
on vm.location = mv.location
and vm.vacc = mv.maximum_vacc_location_monthly
)
select * from highest_vaccination_month_year


 