select *
from PortfolioProject..CovidDeaths

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100'death percentage'
from PortfolioProject..CovidDeaths
where location='india' and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100'percentage of population contracted covid'
from PortfolioProject..CovidDeaths
--where location ='india'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,max(total_cases)'highest infection count',max((total_cases/population))*100'percentage of population contracted covid'
from PortfolioProject..CovidDeaths
--where location ='india'
group by location, population
order by max((total_cases/population))*100  desc

--showing countries with highest death count per population
select location,max(cast(total_deaths as int))'total death count'
from PortfolioProject..CovidDeaths
--where location ='india'
where continent is not null
group by location
order by max(cast(total_deaths as int)) desc

--showing continents with highest death count per population
select continent,max(cast(total_deaths as int))'total death count'
from PortfolioProject..CovidDeaths
--where location ='india'
where continent is not null
group by continent
order by max(cast(total_deaths as int)) desc

--global numbers
select sum(new_cases)'total cases', sum(cast(new_deaths as int))'total deaths',sum(cast(new_deaths as int))/sum(new_cases)*100'death percentage'
from PortfolioProject..CovidDeaths
--where location='india' 
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated,
(sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte

with popvsVac(Continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsVac

--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualizations
create view percentpopulationvaccinated as 
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated