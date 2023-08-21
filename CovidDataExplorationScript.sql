SHOW DATABASES;

USE PortfolioProject;

SELECT *
FROM coviddeaths
WHERE continent is not null
order by 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent is not null
ORDER BY 1, 2;

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1, 2;

-- Looking at total cases vs population
-- Shows what percentage of population got Covid
SELECT Location, date,  population, total_cases, (total_cases/ population)*100 as ContractionRate
FROM coviddeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1, 2;

-- Looking at countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population)*100) as PercentPopulationInfected
FROM coviddeaths
-- WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(IFNULL(total_deaths, 0) AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc;




-- BREAK DOWN BY CONTINENT




-- Showing Countries with Highest Death Count per Population
SELECT continent, MAX(CAST(IFNULL(total_deaths, 0) AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Showing the continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount -- IFNULL replaces null values with 0
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as SIGNED)) as total_deaths, SUM(cast(new_deaths as SIGNED))/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1, 2;

-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as SIGNED)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;




-- use CTE



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as SIGNED)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac;




-- TEMP TABLES


drop table if exists PercentPopulationVaccinated;
Create TEMPORARY Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated DECIMAL(18, 2)
);


Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(IFNULL(vac.new_vaccinations,0) as SIGNED)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated; 



-- Table 4
-- Looking at countries with Highest Infection Rate compared to Population
SELECT Location, population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population)*100) as PercentPopulationInfected
FROM coviddeaths
-- WHERE continent is not null
GROUP BY location, population,date
ORDER BY PercentPopulationInfected desc;


















