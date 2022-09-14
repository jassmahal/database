Select * from [Portfolio ]..['owid-covid-deaths$']
--where continent is not null
order by 3,4

--Select * from [Portfolio ]..['owid-covid-vaccinations$']
--order by 3, 4

--Select Data that we are going to be using--

Select Location, date, total_cases, new_cases, total_deaths, population from [Portfolio ]..['owid-covid-deaths$']
order by 1,2


--Looking at the Total caeses vs Total deaths
--shows likelihood of dying if you contracy covid in your country

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio ]..['owid-covid-deaths$']
where location like'%states'
order by 1,2

--looking at total cases vs Population
---show what percentage of population got covid

Select Location, date,Population, total_cases, (total_deaths/population)*100 as PercentagePopulationInfected
from [Portfolio ]..['owid-covid-deaths$']
where location like'%states'
order by 1,2

---looking at countries with highest infection rate compared rate compared to population

Select Location,Population, MAX(total_cases) as HighestInfectionCount,MAX( (total_cases/population))*100 as PercentagePopulationInfected
from [Portfolio ]..['owid-covid-deaths$']
--where location like'%states'
Group by location, Population
order by PercentagePopulationInfected desc

----showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio ]..['owid-covid-deaths$']
--where location like'%states'
Where continent is not null
Group by location
order by TotalDeathCount desc

-------------

Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
from [Portfolio ]..['owid-covid-deaths$']
--where location like'%states'
Where continent is null
and location not in('world','European Union','International','high income','upper middle income', 'low income','lower middle income')
Group by location
order by TotalDeathCount desc

-----------------------

Select Location,population,date,MAX(total_cases)as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopulationInfected 
from [Portfolio ]..['owid-covid-deaths$']
--where location like'%states'
Group by location, Population, date
order by PercentPopulationInfected desc
--lets break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio ]..['owid-covid-deaths$']
--where location like'%states'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--showing the continents with the highest death counts per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio ]..['owid-covid-deaths$']
--where location like'%states'
Where continent is not null
Group by continent
order by TotalDeathCount desc

---Global numbers

Select SUM(new_cases) as totalcases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100  DeathPercentage
from [Portfolio ]..['owid-covid-deaths$']
--where location like'%states'
Where continent is not null
--Group by date
order by 1,2

---looking at total Population va vaccinations

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from [Portfolio ]..['owid-covid-deaths$'] dea
Join [Portfolio ]..['owid-covid-vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.Location, dea.Date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) as RollingPeopleVaccinated
from [Portfolio ]..['owid-covid-deaths$'] dea
Join [Portfolio ]..['owid-covid-vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac

----Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
from [Portfolio ]..['owid-covid-deaths$'] dea
Join [Portfolio ]..['owid-covid-vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select *,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated




---creating view to store data for later visulizations


Create view PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
from [Portfolio ]..['owid-covid-deaths$'] dea
Join [Portfolio ]..['owid-covid-vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated