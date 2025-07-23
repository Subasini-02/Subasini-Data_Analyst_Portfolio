-- SQL DATA Exploration

-- CovidDeaths
SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- CovidVaccinations
SELECT * 
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location,date, total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--by location
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continent with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Global Numbers
SELECT date, SUM(new_cases) AS total_cases,
			 SUM(CAST(new_deaths AS INT)) AS total_deaths,
			 SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Overall Percentage
SELECT SUM(new_cases) AS total_cases,
	   SUM(CAST(new_deaths AS INT)) AS total_deaths,
	   SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Joining coviddeaths and covidvaccination
SELECT *
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidDeaths vacc
	ON death.location = vacc.location
	AND death.date = vacc.date

--Total population vs vaccination
SELECT death.continent, death.location,death.date,death.population,
	   vacc.new_vaccinations, 
	   SUM(CAST(vacc.new_vaccinations AS BIGINT)) 
	   OVER(PARTITION BY death.location ORDER BY death.location,death.date) AS PeopleVaccinated
From PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

--CTE
WITH PopvsVac ( continent, location, date, population,new_vaccinations,PeopleVaccinated)
AS
(
SELECT death.continent,death.location, death.date,death.population, 
	   vacc.new_vaccinations,
	   SUM(CONVERT (BIGINT, vacc.new_vaccinations)) 
	   OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS PeopleVaccinated
FROM PortfolioProject..Coviddeaths death
JOIN PortfolioProject..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (PeopleVaccinated / population)*100
FROM PopvsVac

--TEMP table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent,death.location, death.date, death.population,
	   vacc.new_vaccinations,
	   SUM(CONVERT ( BIGINT , vacc.new_vaccinations))
	   OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date

SELECT * , (PeopleVaccinated / Population)* 100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent,death.location,death.date,death.population,
	   vacc.new_vaccinations,
	   SUM(CONVERT ( BIGINT, vacc.new_vaccinations)) 
	   OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated


