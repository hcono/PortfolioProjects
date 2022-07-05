select * from [dbo].[CovidDeaths$]
order by 3,4;

select * from [dbo].[CovidVaccinations$]
order by 3,4;

--- select data we ae going to be using
select location,date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths$]
order by 1,2;

-- shows the liklihood of death if you have covid in your country
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths$]
where location like '%Ireland%'
order by 1,2;

-- look at total cases verses the population
-- what percentage of population got covid
select location,date, total_cases, population, (total_cases/population)*100 as CasesPerPop
from [dbo].[CovidDeaths$]
where location like '%Ireland%'
order by 1,2;


-- what countries have the highest infection rate compared to population

select location, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as highest
from [dbo].[CovidDeaths$]
-- where location like '%Ireland%'
group by location, population
order by highest desc;

-- countries with highest death count per population
-- total_deaths has a wrong data type change to integer using cast
select location, max(cast(total_deaths as int)) as totalDeathCount
from [dbo].[CovidDeaths$]
-- where location like '%Ireland%'
where continent is not null
group by location
order by totalDeathCount desc;
-- note that columns for location have continents are included

select * from [dbo].[CovidDeaths$]
where continent is not null

-- LETS break things down by continent
select continent, max(cast(total_deaths as int)) as totalDeathCount
from [dbo].[CovidDeaths$]
-- where location like '%Ireland%'
where continent is not null
group by continent
order by totalDeathCount desc;
-- it only gets the max value for the continent

select location,max(cast(total_deaths as int)) as totalDeathCount
from [dbo].[CovidDeaths$]
-- where location like '%Ireland%'
where continent is null
group by location
order by totalDeathCount desc;

-- show continents by highest death count per population
select continent,max(cast(total_deaths as int)) as totalDeathCount
from [dbo].[CovidDeaths$]
-- where location like '%Ireland%'
where continent is not null
group by continent
order by totalDeathCount desc;

-- drill down, create the layers
-- global numbers
-- use aggregate functions (functions that perform a calculation)
select --date, 
sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
--location, dat, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths$]
where continent is not null
--group by date
order by 1,2;


-- looking at total population vs vacinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- this creates a new  column that counts the new vaccinations, by location by date
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingVacinations -- is not callable
-- therefor we use a CTE, 
from [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- CTE, number of columns in CTE has to equal number of columns in query
with PopsvsVac (continent, location, date, population, new_vaccinations,rollingVacinations)
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- this creates a new  column that counts the new vaccinations, by location by date
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingVacinations -- is not callable
-- therefor we use a CTE, 
from [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingVacinations/Population)*100 as VacPerPop
from PopsvsVac

-- Temp Table
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- this creates a new  column that counts the new vaccinations, by location by date
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingVacinations -- is not callable
-- therefor we use a CTE, 
from [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingPeopleVaccinated/Population)*100 as VacPerPop
from #percentPopulationVaccinated





-- create a view to store data for later visualisations

create view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- this creates a new  column that counts the new vaccinations, by location by date
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingVacinations -- is not callable
-- therefor we use a CTE, 
from [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null





