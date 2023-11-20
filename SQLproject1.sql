

select *
from PortfolioProject..CovidDeaths
order by 3,4




select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,
case
	when total_cases = 0 then NULL
	else (total_deaths/total_cases)*100
end as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location = 'United States'
order by 1,2



-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'United States'
group by location, population
order by PercentPopulationInfected desc



-- Showing Countries with Highest Death Count per Population
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null and continent != ''
group by location
order by TotalDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null and continent != ''
group by continent
order by TotalDeathCount desc





-- GLOBAL NUMBERS by each date
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
case
	when sum(new_cases) = 0 then NULL
	else sum(cast(new_deaths as int))/sum(new_cases)*100
end as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and continent != ''
group by date
order by 1,2




-- GLOBAL NUMBERS overall
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
case
	when sum(new_cases) = 0 then NULL
	else sum(cast(new_deaths as int))/sum(new_cases)*100
end as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and continent != ''
order by 1,2




-- Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent != ''
order by 2,3




-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent != ''
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPercentPopulationVaccinated
from PopvsVac






-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Locatiion nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent != ''
order by 2,3


select *, (RollingPeopleVaccinated/population)*100 as RollingPercentPopulationVaccinated
from #PercentPopulationVaccinated





-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent != ''
--order by 2,3


select *
from PercentPopulationVaccinated


