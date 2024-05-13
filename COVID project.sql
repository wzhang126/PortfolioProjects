SELECT *
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM ProjectPortfolio..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows % of population that got COVID

SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with the Highest Death Rate

SELECT
	location,
	MAX(total_deaths) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing continents with the Highest Death Count per Populatio

SELECT
	continent,
	MAX(total_deaths) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	(SUM(new_deaths)/SUM(new_cases)) *100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY date
HAVING SUM(new_cases) !=0 OR SUM(new_deaths) !=0
ORDER BY 1,2


-- Total numbers to date

SELECT 
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	(SUM(new_deaths)/SUM(new_cases)) *100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
HAVING SUM(new_cases) !=0 OR SUM(new_deaths) !=0
ORDER BY 1,2


-- Total Population vs Vaccinations

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated	
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to calcualte Rolling Percent Vaccinated

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVacinated
CREATE Table #PercentPopulationVacinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVacinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVacinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVacinated AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVacinated