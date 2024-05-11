Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4;

Select * 
From PortfolioProject..CovidVaccinations
order by 3, 4;

-- Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2;

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2;


-- Looking at the Total Cases vs the Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2;


-- Looking at countries with highest infection rate compared to population 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc;


-- Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT


-- Showing the continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
group by date
order by 1, 2;


-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location 
  ,dea.date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3;

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location 
  ,dea.date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location 
  ,dea.date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location 
  ,dea.date) as RollingPeopleVaccinated
--,  (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
;

select * from PercentPopulationVaccinated;

--Next: create more views for data you want to visualize in tableau
