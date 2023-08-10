
--sp_help 'CovidDeaths' --Show data types within selected table

--Convert data type of selected column. It is IMPOSSIBLE to convert multiple columns at once
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths INT

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases INT

ALTER TABLE CovidDeaths
ALTER COLUMN new_cases INT

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths INT

ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations INT

USE SQL_Tutorial; --USE database statement can avoid the bug of not finding the table due to default database
ALTER TABLE CovidVaccinations
ALTER COLUMN total_vaccinations BIGINT

SELECT continent, population
FROM SQL_Tutorial..CovidDeaths
GROUP BY continent,population

--Looking at Total Deaths vs Total Cases
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths *1.0 / total_cases) *100 AS DeathPercentage
FROM SQL_Tutorial..CovidDeaths
WHERE location like '%australia%'
order by 1,2

--Looking at Total Cases vs Population
--Shows likelihood of contracting covid in your country
SELECT location, date, population, total_cases, (total_cases *1.0 / population) *100 AS PopInfected
FROM SQL_Tutorial..CovidDeaths
WHERE location like '%australia%'
order by 1,2

--Looking at countries with higest infection rates compared to Population
SELECT location, population, MAX(total_cases) as HighestInfetionCount, MAX((total_cases *1.0 / population) *100) AS PercentPopInfected
FROM SQL_Tutorial..CovidDeaths
GROUP BY location,population
order by PercentPopInfected DESC

--Showing Highest Death counts per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM SQL_Tutorial..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--Breaking down by continent
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM SQL_Tutorial..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT SUM(new_cases) as Infected, SUM(new_deaths) as Deaths, (SUM(new_deaths)*1.0/SUM(nullif (new_cases,0)))*100 AS DeathPercentage
FROM SQL_Tutorial..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 

--Looking at Total Vaccination vs Population
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM SQL_Tutorial..CovidDeaths dea
JOIN SQL_Tutorial..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date

--USE CTE

WITH PopvsVac (continent,Location,Date,Population, New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM (CAST (vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM SQL_Tutorial..CovidDeaths dea
JOIN SQL_Tutorial..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY dea.location, dea.date
)
SELECT *, (RollingPeopleVaccinated*1.0/Population)*100
FROM PopvsVac
ORDER BY location,date

--TEMP TABLE
DROP TABLE if exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM (CAST (vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM SQL_Tutorial..CovidDeaths dea
JOIN SQL_Tutorial..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated*1.0/Population)*100 AS PercentagePopulationVaccinated
FROM PercentPopulationVaccinated
ORDER BY location,date

--Create a View to see Rolling Population Vaccinated
USE SQL_Tutorial --Specify the database to create the view, since SQL Server will run on default database.
--However, this command must be run separately. CREATE VIEW must be the first command in query batch

DROP VIEW IF exists RollingPeopleVaccinated --Run this separately, for the above reason.

CREATE VIEW RollingPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM SQL_Tutorial..CovidDeaths dea
JOIN SQL_Tutorial..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY dea.location, dea.date --The ORDER BY clause is invalid in views.
