-----------------------------------------------------------------------------------------------------------
-- base queries
-----------------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4




SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-----------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
-----------------------------------------------------------------------------------------------------------
SELECT location, date, total_cases, total_deaths,
case
	when total_cases = 0 then NULL
	else (total_deaths/total_cases)*100
end as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-----------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
-----------------------------------------------------------------------------------------------------------
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2


-----------------------------------------------------------------------------------------------------------
-- Looking at Countries with Highest Infection Rate compared to Population
-----------------------------------------------------------------------------------------------------------
SELECT location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
group by location, population
ORDER BY PercentPopulationInfected desc


-----------------------------------------------------------------------------------------------------------
-- Showing Countries with Highest Death Count per Population
-----------------------------------------------------------------------------------------------------------
SELECT location, max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null AND continent != ''
group by location
ORDER BY TotalDeathCount desc


-----------------------------------------------------------------------------------------------------------
-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
-----------------------------------------------------------------------------------------------------------
SELECT continent, max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null AND continent != ''
group by continent
ORDER BY TotalDeathCount desc




-----------------------------------------------------------------------------------------------------------
-- GLOBAL NUMBERS by each date
-----------------------------------------------------------------------------------------------------------
SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
case
	when sum(new_cases) = 0 then NULL
	else sum(cast(new_deaths as int))/sum(new_cases)*100
end as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null AND continent != ''
group by date
ORDER BY 1,2



-----------------------------------------------------------------------------------------------------------
-- GLOBAL NUMBERS overall
-----------------------------------------------------------------------------------------------------------
drop view if exists GlobalDeathPercentage
GO
Create View GlobalDeathPercentage as
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
case
	when sum(new_cases) = 0 then NULL
	else sum(cast(new_deaths as int))/sum(new_cases)*100
end as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null AND continent != ''
GO
SELECT *
FROM GlobalDeathPercentage



-----------------------------------------------------------------------------------------------------------
-- Looking at total population vs vaccinations
-----------------------------------------------------------------------------------------------------------
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND dea.continent != ''
ORDER BY 2,3



-----------------------------------------------------------------------------------------------------------
-- USE CTE
-----------------------------------------------------------------------------------------------------------
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND dea.continent != ''
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as RollingPercentPopulationVaccinated
FROM PopvsVac





-----------------------------------------------------------------------------------------------------------
-- TEMP TABLE
-----------------------------------------------------------------------------------------------------------
drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locatiion nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND dea.continent != ''
ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/population)*100 as RollingPercentPopulationVaccinated
FROM #PercentPopulationVaccinated




-----------------------------------------------------------------------------------------------------------
-- Creating View to store data for later visualizations
-----------------------------------------------------------------------------------------------------------
drop view if exists PercentPopulationVaccinated
GO
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND dea.continent != ''
--ORDER BY 2,3
GO


SELECT *
FROM PercentPopulationVaccinated






