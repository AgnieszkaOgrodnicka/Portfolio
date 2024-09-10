-- Select data that I'm going to be using 

	--SELECT "location", "date", total_cases, new_cases, total_deaths, population 
	--ROM public."CovidDeaths"
	--Where continent is not null 
	--order by "location", "date"

-- Total Cases vs Total Deaths (likelihood of dying)

	--SELECT "location", "date", total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage  
	--FROM public."CovidDeaths"
	--where location like 'Poland'
	--and continent is not null 
	--order by "location", "date"

-- Total Cases vs Population

	--SELECT "location", "date", total_cases, population , (total_cases/population)*100 as percent_population_infected  
	--FROM public."CovidDeaths"
	--where location like 'Poland'
	--and continent is not null
	--order by "location", "date"
	
-- Countries with Highest Infection Rate compared to Population

	--SELECT "location", max(total_cases) as highest_infection_count, population , max((total_cases/population))*100 as percent_population_infected  
	--FROM public."CovidDeaths"
	--Where continent is not null 
	--group by "location", population
	--order by percent_population_infected desc
	
	
-- Countries with Highest Death Count per Population
	--SELECT "location", max(total_deaths) as total_death_count
	--FROM public."CovidDeaths"
	--Where continent is not null 
	--group by "location"
	--order by total_death_count desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

	--SELECT "location", max(total_deaths) as total_death_count
	--FROM public."CovidDeaths"
	--Where continent is null 
	--group by "location"
	--order by total_death_count desc
	

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine using CTE to perform Calculation on Partition By

--Create View percent_population_vaccinated as
With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated  
--, (rolling_people_vaccinated/population)*100
From public."CovidDeaths" dea
Join public."CovidVaccinations" vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by "location", "date"
)
Select *, (cast(rolling_people_vaccinated as numeric)/cast(population as numeric)*100) as percent_population_vaccinated
From PopvsVac
--where location like 'Canada'
--and new_vaccinations is not null
--order by date desc


-- Creating View to store data for later visualizations


--Create View rolling_people_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_people_vaccinated
From public."CovidDeaths" dea
Join public."CovidVaccinations" vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
;