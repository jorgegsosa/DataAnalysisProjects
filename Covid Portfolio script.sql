--Death Table
SELECT location, date, total_deaths
FROM PorfolioProject..covidDeaths$
order by 1,2

--Looking at total cases vs population
-- Show the percentsge of people in the US who caught covid
SELECT location, date, total_cases, total_deaths,population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PorfolioProject..covidDeaths$
WHERE location = 'United States'
AND total_deaths IS NOT NULL
ORDER BY 1,2



--Which countries have the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestepercentagePopulation, MAX(total_cases/population) AS PercentagePopulationInfected
FROM PorfolioProject..covidDeaths$
WHERE NOT location IN ('World', 'High Income', 'Europe', 'Asia', 'European Union', 'Upper middle income', 'North America', 'United Kingdom', 'Lower middle income', 'Oceania','Africa')
Group by location,population
order by HighestepercentagePopulation desc

--create view for Which countries have the highest infection rate compared to population
CREATE VIEW CountrieswithHighestInfecctionRate
as
SELECT location, population, MAX(total_cases) AS HighestepercentagePopulation, MAX(total_cases/population) AS PercentagePopulationInfected
FROM PorfolioProject..covidDeaths$
WHERE NOT location IN ('World', 'High Income', 'Europe', 'Asia', 'European Union', 'Upper middle income', 'North America', 'United Kingdom', 'Lower middle income', 'Oceania','Africa')
Group by location,population




--Showing countires with the highest mortal rate
SELECT location, MAX(total_deaths) AS Highest_Deaths
FROM PorfolioProject..covidDeaths$
Group By location
Order By Highest_Deaths DESC
--We know that something is wrong with the data. We have to in and fix it



--Fixing the the total_deaths data using the Cast function
-- Finding the higest death count by country
SELECT location, MAX(cast(total_deaths as bigint)) AS totalDeathCount
FROM PorfolioProject..covidDeaths$
WHERE continent IS NOT NULL
Group By location
Order By totalDeathCount DESC

--create view for Finding the higest death count by country

CREATE VIEW HighestDeathToll_by_Country
as
SELECT location, MAX(cast(total_deaths as bigint)) AS totalDeathCount
FROM PorfolioProject..covidDeaths$
WHERE continent IS NOT NULL
Group By location


--Highest death toll by continent
select continent, MAX(cast(total_deaths as bigint)) AS totalDeathCount
from PorfolioProject..covidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount desc

--CREATE VIEW for Highest death toll by continent

CREATE VIEW HighestDeathToll_by_Continet
as
select continent, MAX(cast(total_deaths as bigint)) AS totalDeathCount
from PorfolioProject..covidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent




--Worldwide covid numbers
SELECT date, SUM(new_cases) as totalnewcases, SUM(cast(new_deaths as bigint)) as totalnewdeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS Newdeathpercentage
FROM PorfolioProject..covidDeaths$
where continent is not null
group by date
order by 1,2



--Total worlwide death percentage
SELECT  SUM(new_cases) as totalnewcases, SUM(cast(new_deaths as bigint)) as totalnewdeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS Newdeathpercentage
FROM PorfolioProject..covidDeaths$
where continent is not null
--group by date
order by 1,2

--creat view for Total worlwide death percentage
CREATE VIEW WorldwideDeathPercentage
as
SELECT  SUM(new_cases) as totalnewcases, SUM(cast(new_deaths as bigint)) as totalnewdeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 AS Newdeathpercentage
FROM PorfolioProject..covidDeaths$
where continent is not null




--Vaccine's table
SELECT*
FROM PorfolioProject..covidVaccinations$



-- Joining death table and vaccine table on location and date
SELECT*
FROM PorfolioProject..covidDeaths$ death
JOIN PorfolioProject..covidVaccinations$ vacc
    on death.location = vacc.location
    and death.date = vacc.date



--Total population and vaccines
SELECT death.location, death.date, death.population, vacc.new_vaccinations
FROM PorfolioProject..covidDeaths$ death
JOIN PorfolioProject..covidVaccinations$ vacc
    on death.location = vacc.location
    and death.date = vacc.date
order by 1,2

--Create views
CREATE VIEW TotalPopulation_and_Vaccines
as
SELECT death.location, death.date, death.population, vacc.new_vaccinations
FROM PorfolioProject..covidDeaths$ death
JOIN PorfolioProject..covidVaccinations$ vacc
    on death.location = vacc.location
    and death.date = vacc.date



--Doing Partions
-- Looking at total population vs vaccinations
SELECT death.continent, death.location,  death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint)) 
OVER(partition by death.location order by death.location, death.date) AS RollingPeopleVacc
FROM PorfolioProject..covidDeaths$ death
JOIN PorfolioProject..covidVaccinations$ vacc
    on death.location = vacc.location
    and death.date = vacc.date
WHERE death.continent is not null
and vacc.new_vaccinations is not null
order by 1,2



--Using CTE to divide death.population by RollingPeopleVacc

WITH PopvsVac (continent, location,date,population,new_vaccinations, RollingPeopleVacc)

as
(
SELECT death.continent, death.location,  death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint)) 
OVER(partition by death.location order by death.location, death.date) AS RollingPeopleVacc
FROM PorfolioProject..covidDeaths$ death
JOIN PorfolioProject..covidVaccinations$ vacc
    on death.location = vacc.location
    and death.date = vacc.date
WHERE death.continent is not null
and vacc.new_vaccinations is not null

)
SELECT*, (RollingPeopleVacc/population)*100
FROM PopvsVac


--Using temp table divide death.population by RollingPeopleVacc
--DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVacc numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location,  death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint)) 
OVER(partition by death.location order by death.location, death.date) AS RollingPeopleVacc
FROM PorfolioProject..covidDeaths$ death
JOIN PorfolioProject..covidVaccinations$ vacc
    on death.location = vacc.location
    and death.date = vacc.date
WHERE death.continent is not null
and vacc.new_vaccinations is not null
order by 1,2

SELECT*, (RollingPeopleVacc/population)*100
FROM #PercentPopulationVaccinated

--Create View to store data for Vizs

CREATE VIEW PercentPopulationVaccinated as

SELECT death.continent, death.location,  death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint)) 
OVER(partition by death.location order by death.location, death.date) AS RollingPeopleVacc
FROM PorfolioProject..covidDeaths$ death
JOIN PorfolioProject..covidVaccinations$ vacc
    on death.location = vacc.location
    and death.date = vacc.date
WHERE death.continent is not null
and vacc.new_vaccinations is not null

