-- Drop table if exists
DROP TABLE whr_db;

-- Create new table for WHR 2008 to 2020 data and import CSV
CREATE TABLE WHR2008_to_2019 (
	Country_name VARCHAR,
	year INT,
	Life_Ladder DEC,
	Log_GDP_per_capita DEC,
	Social_support DEC,
	Healthy_life_expectancy_at_birth DEC,
	Freedom_to_make_life_choices DEC,
	Generosity DEC,
	Perceptions_of_corruption DEC
);

-- Create new table for WHR 2021 and import csv
CREATE TABLE WHR2021 (
	Country_name VARCHAR,
	year INT,
	Ladder_score DEC,
	Log_GDP_per_capita DEC,
	Social_support DEC,
	Healthy_life_expectancy DEC,
	Freedom_to_make_life_choices DEC,
	Generosity DEC,
	Perceptions_of_corruption DEC
);

-- Create new table for Covid Data and import csv
CREATE TABLE covid_data (
	Country_name VARCHAR,
	Population_2020 INT,
	Population_2019 INT,
	COVID_19_deaths_per_100000_population_in_2020 DEC,
	Median_age DEC,
	All_cause_death_count_2017 INT,
	All_cause_death_count_2018 INT,
	All_cause_death_count_2019 INT,
	All_cause_death_count_2020 INT
);

--Import international census data

-- Create new table for WHR 2008 to 2020 data and import CSV
CREATE TABLE population (
	Country_name VARCHAR,
	year INT,
	Population INT,
	Area_per_sq_km INT,
	Density_per_sq_km DEC
);

-- Perform an Union of the 2021 and main table
Create Table WHR2008_to_2021 as
SELECT *
FROM WHR2021
Union
Select *
FROM WHR2008_to_2019 
ORDER BY year DESC, country_name;

--Join Covid Data

ALTER TABLE covid_data
RENAME COLUMN Population_2020 TO "p2020";

ALTER TABLE covid_data
RENAME COLUMN Population_2019 TO "p2019";

Alter Table covid_data
Rename column COVID_19_deaths_per_100000_population_in_2020 to "covid_deaths"

--creating temp tables for 2017 population data to unpivot
Create table td2017 (country_name varchar,year INT, total_deaths INT);

INSERT INTO td2017(country_name, total_deaths) 
SELECT country_name,All_cause_death_count_2017
FROM covid_data;

UPDATE td2017
SET    year = '2017';

--creating temp tables for 2018 population data to unpivot
Create table td2018 (country_name varchar,year INT, total_deaths INT);

INSERT INTO td2018(country_name, total_deaths) 
SELECT country_name,All_cause_death_count_2018
FROM covid_data;

UPDATE td2018
SET    year = '2018';

--creating temp tables for 2019 population data to unpivot
Create table td2019 (country_name varchar,year INT,total_deaths INT);

INSERT INTO td2019(country_name, total_deaths) 
SELECT country_name,All_cause_death_count_2019
FROM covid_data;

UPDATE td2019
SET    year = '2019';


--creating temp table for 2020 population data to unpivot

Create table td2020 (country_name varchar,year INT, total_deaths INT);

INSERT INTO td2020(country_name, total_deaths) 
SELECT country_name, All_cause_death_count_2020
FROM covid_data;

UPDATE td2020
SET    year = '2020';

--creating complete table of 2017, 2018, 2019, and 2020 data
Create Table td_data as
SELECT *
FROM td2017
Union
Select *
FROM td2018
Union
SELECT *
FROM td2019
Union
Select *
FROM td2020
ORDER BY country_name, year DESC;

--Removing temporary tables for unpivot
DROP TABLE td2020;
DROP TABLE td2019;
DROP TABLE td2018;
DROP TABLE td2017;

--Create WHR Total Deaths table
CREATE TABLE WHR_td (
	Country_name VARCHAR,
	year INT,
	Ladder_score DEC,
	Log_GDP_per_capita DEC,
	Social_support DEC,
	Healthy_life_expectancy DEC,
	Freedom_to_make_life_choices DEC,
	Generosity DEC,
	Perceptions_of_corruption DEC,
	Country_Name2 VARCHAR,
	Year2 INT,
	Total_Deaths INT
);

--WHR table with total deaths data
Insert into WHR_td
Select *
from  WHR2008_to_2021
Left outer join td_data
	on WHR2008_to_2021.Country_name = td_data.Country_name 
	and WHR2008_to_2021.year = td_data.year;
	
--Remove Country_Name2 and Year2
ALTER TABLE WHR_td
DROP COLUMN Country_Name2,
DROP COLUMN Year2;

Select * from WHR_td;

--2020 Covid data table
Create table covid2020 (country_name varchar,year INT, population int, covid_deaths DEC, Median_age DEC);

INSERT INTO covid2020(country_name, population, covid_deaths, Median_age) 
SELECT country_name, P2020, covid_deaths, Median_age
FROM covid_data;

UPDATE covid2020
SET    year = '2020';

UPDATE covid2020
SET covid_deaths = round(population/100000*covid_deaths,0)::numeric;

ALTER TABLE covid2020
DROP COLUMN population;

--Create WHR_Covid table
CREATE TABLE WHR_COVID (
	Country_name VARCHAR,
	year INT,
	Ladder_score DEC,
	Log_GDP_per_capita DEC,
	Social_support DEC,
	Healthy_life_expectancy DEC,
	Freedom_to_make_life_choices DEC,
	Generosity DEC,
	Perceptions_of_corruption DEC,
	Total_Deaths INT,
	Country_Name2 VARCHAR,
	Year2 INT,
	Covid_Deaths INT,
	Median_Age DEC
);

--WHR table with COVID data
Insert into WHR_COVID
Select *
from  whr_td
Left outer join covid2020
	on WHR_td.Country_name = covid2020.country_name 
	and WHR_td.year = covid2020.year;
	
--Remove Country_Name2 and Year2
ALTER TABLE WHR_COVID
DROP COLUMN Country_Name2,
DROP COLUMN Year2;

--Join population data

CREATE TABLE WHR_DB (
	Country_name VARCHAR,
	year INT,
	Ladder_score DEC,
	Log_GDP_per_capita DEC,
	Social_support DEC,
	Healthy_life_expectancy DEC,
	Freedom_to_make_life_choices DEC,
	Generosity DEC,
	Perceptions_of_corruption DEC,
	Total_Deaths INT,
	Covid_Deaths INT,
	Median_Age DEC,
	Country_Name2 VARCHAR,
	Year2 INT,
	Population INT,
	Country_Area INT,
	Population_Density DEC
);

--WHR table with COVID data
Insert into WHR_DB
Select *
from  whr_covid
Left outer join population
	on WHR_COVID.Country_name = population.country_name 
	and WHR_COVID.year = population.year;
	
--Remove Country_Name2 and Year2
ALTER TABLE WHR_DB
DROP COLUMN Country_Name2,
DROP COLUMN Year2;

--Remove temp tables 
DROP TABLE covid2020;
DROP TABLE td_data;
DROP TABLE whr_covid;
DROP TABLE whr_td;

Select * from WHR_DB;