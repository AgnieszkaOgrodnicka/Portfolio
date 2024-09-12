-- Select data that I'm going to be using 

SELECT 	"location", 
		"date", 
		total_cases, 
		new_cases, 
		total_deaths, 
		population 
FROM public."CovidDeaths"
WHERE continent IS NOT NULL 
ORDER BY "location", "date"
;

-----------------------------------------------------------------

-- Total Cases vs Total Deaths (likelihood of dying)

SELECT 	"location", 
		"date", 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 AS death_percentage  
FROM public."CovidDeaths"
WHERE "location" LIKE 'Poland'
	AND continent IS NOT NULL
ORDER BY "location", "date"
;

-------------------------------------------------------------------------

-- Total Cases vs PopulatiON

SELECT 	"location", 
		"date", 
		total_cases, 
		population, 
		(total_cases/population)*100 AS percent_population_infected  
FROM public."CovidDeaths"
WHERE location LIKE 'Poland'
	AND continent IS NOT NULL
ORDER BY "location", "date"
;

--------------------------------------------------------------------------
	
-- Countries with Highest Infection Rate Compared to Population

SELECT 	"location", 
		MAX(total_cases) AS highest_infection_count, 
		population, 
		MAX((total_cases/population))*100 AS percent_population_infected  
FROM public."CovidDeaths"
WHERE continent IS NOT NULL 
GROUP BY "location", population
ORDER BY percent_population_infected DESC
;

------------------------------------------------------------------------------
	
-- Countries with Highest Death Count per Population

SELECT "location", MAX(total_deaths) AS total_death_count
FROM public."CovidDeaths"
WHERE continent IS NOT NULL 
GROUP BY "location"
ORDER BY total_death_count DESC
;

-----------------------------------------------------------------------------

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT "location", MAX(total_deaths) AS total_death_count
FROM public."CovidDeaths"
WHERE continent IS NULL 
GROUP BY "location"
ORDER BY total_death_count DESC
;

----------------------------------------------------------------------------

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine 
-- using CTE to perform Calculation on Partition By

--CREATE VIEW percent_population_vaccinated as
WITH PopvsVac (continent, "location", "date", population, new_vaccinations, rolling_people_vaccinated)
AS(
	SELECT 	dea.continent, 
			dea.location, 
			dea.date, 
			dea.population, 
			vac.new_vaccinations,
			SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated  
	--, (rolling_people_vaccinated/population)*100
	FROM public."CovidDeaths" dea
	JOIN public."CovidVaccinations" vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--order by "location", "date"
)
SELECT 	*, 
		(CAST(rolling_people_vaccinated AS NUMERIC)/CAST(population AS NUMERIC)*100) AS percent_population_vaccinated
FROM PopvsVac
--where location like 'Canada'
--and new_vaccinations is not null
--order by date desc
;

-------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualizations


--CREATE VIEW rolling_people_vaccinated as
SELECT 	dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 			
		vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS rolling_people_vaccinated
FROM public."CovidDeaths" dea
JOIN public."CovidVaccinations" vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL