-- Total deaths worldwide

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM public."CovidDeaths"
where continent is not null 
order by 1,2

-- Total deaths per continent
-- I am removing locations that are not continents for the sake of consistency

Select location, SUM(new_deaths) as total_death_count
FROM public."CovidDeaths"
Where continent is null 
and location not in ('World','European Union (27)', 'High-income countries', 
					'Upper-middle-income countries', 'Lower-middle-income countries',
					'Low-income countries')
Group by location
order by total_death_count desc


-- Percentage of infected people in each country

SELECT "location", population, MAX(total_cases) as highest_infection_count,  
		Max((cast(total_cases as numeric)/cast(population as numeric))*100) as percent_population_infected
FROM public."CovidDeaths"
GROUP BY "location", population
ORDER BY percent_population_infected desc

-- Percentage of infected people in each country by day

SELECT "location", population, "date", MAX(total_cases) as highest_infection_count,  
		Max((cast(total_cases as numeric)/cast(population as numeric))*100) as percent_population_infected
FROM public."CovidDeaths"
where total_cases is not null
GROUP BY "location", population, "date"
ORDER BY percent_population_infected desc


