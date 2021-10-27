Select * from ClassProjectPortfolio..CovidDeath$
where continent is not null
order by 3,4

--Select * from ClassProjectPortfolio..CovidVaccine$
--order by 3,4

--Select data

Select Location, date, total_cases, new_cases, total_deaths, population
from ClassProjectPortfolio..CovidDeath$
where continent is not null
order by 1,2

--Look at the total case vs total death
--The death % compare to the total case. The chace of dying if you have covid
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ClassProjectPortfolio..CovidDeath$
where location like '%state%' and continent is not null
order by 1,2

--Total case vs Population
--The percentage of population has covid
select Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from ClassProjectPortfolio..CovidDeath$
where location like '%state%' and continent is not null
order by 1,2

--Countries with highest infection rate 
Select Location, Population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentagePopulationInfected
from ClassProjectPortfolio..CovidDeath$
group by location, population
order by PercentagePopulationInfected desc

--Continents with highest death to lowest death
Select location, MAX(cast(total_deaths as int)) as HighestDeath from ClassProjectPortfolio..CovidDeath$
where continent is null
group by location
order by HighestDeath desc

--Countries with highest death 
Select location, MAX(cast(total_deaths as int)) as HighestDeath from ClassProjectPortfolio..CovidDeath$
where continent is not null
group by location
order by HighestDeath desc

--The percentage of total case and death case globally
Select SUM(new_cases) as Total_case, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from ClassProjectPortfolio..CovidDeath$
where continent is not null
order by 1,2


--Look at the total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as  int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountVaccinated
from ClassProjectPortfolio..CovidVaccine$ vac
join ClassProjectPortfolio..CovidDeath$ dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null
order by 1,2

--Create a common table expression between population and vaccinations
With PopulationVsVaccinations (Contient, Location, Date, Population, New_vaccinations, RollingCountVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountVaccinated
from ClassProjectPortfolio..CovidVaccine$ vac
join ClassProjectPortfolio..CovidDeath$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingCountVaccinated/Population)*100 as RollingPerentage
From PopulationVsVaccinations
order by 1,2

--Create/Drop a temporary table and perform an calculation on Partition by in the previous query

DROP Table if exists #PercentagePeopleVaccinated
Create Table #PercentagePeopleVaccinated
(
Continent nvarchar(500),
Location nvarchar(500),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountVaccinated numeric
)
Insert into #PercentagePeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountVaccinated
from ClassProjectPortfolio..CovidVaccine$ vac
join ClassProjectPortfolio..CovidDeath$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingCountVaccinated/Population)*100 as RollingPerentage
From #PercentagePeopleVaccinated
order by 1,2

--Creating view for data visualization
Create view PercentagePeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountVaccinated
from ClassProjectPortfolio..CovidVaccine$ vac
join ClassProjectPortfolio..CovidDeath$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

Select * from PercentagePeopleVaccinated