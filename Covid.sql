-- Deaths percentage (worldwide)

SELECT
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 2) as deathsPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths by Location and Date

SELECT 
	location, 
	CAST(date as date) AS date, 
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths, 
	ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 2) as deathsPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, CAST(date as date)
ORDER BY 1,2;


-- Total Cases vs Total Deaths by Country

SELECT 
	location, 
	MAX(population) as maxPopulation,
	SUM(new_cases) as total_cases, 
	SUM(new_deaths) as total_deaths, 
	ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 2) as deathsPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 5 DESC;

-- Rate Cases over Population by Year

SELECT 
	location, 
	MAX(population) as Population,
	SUM(new_cases) as TotalCases, 
	SUM(new_deaths) as TotalDeaths, 
	ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 2) as DeathsPercentage,
	SUM(new_cases) / NULLIF(MAX(population), 0) AS CasesOverPopulation_Rate --How many times has a person had Covid? 
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 6 DESC;

--Deaths by country

SELECT
	location,
	MAX(total_deaths) as TotalDeathCount
FROM
	CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


--Population vs Vaccination

WITH PopulationVsVaccination(
	continent,
	location,
	date,
	population,
	new_vaccinations,
	RollingPeopleVaccinated)
AS
(
SELECT
	dc.continent,
	dc.location,
	CAST(dc.date AS date) AS date,
	dc.population,
	vc.new_vaccinations,
	SUM(CONVERT(FLOAT, vc.new_vaccinations)) OVER (PARTITION BY dc.location ORDER BY dc.location, CAST(dc.date AS date)) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dc
JOIN CovidProject..CovidVaccinations vc
	ON dc.location = vc.location
	AND dc.date = vc.date
WHERE dc.continent IS NOT NULL
)
SELECT 
	*,
	(RollingPeopleVaccinated/population) *100 AS RollingPeopleVaccinatedPercentage
FROM PopulationVsVaccination
ORDER BY RollingPeopleVaccinatedPercentage DESC;
