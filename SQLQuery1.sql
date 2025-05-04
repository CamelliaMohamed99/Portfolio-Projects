select * from [portfolio project]..CovidDeaths
order by 3,4

--select * from [portfolio project]..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases,population,total_deaths
from [portfolio project]..CovidDeaths
order by 1,2
--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select Location, date, total_cases,total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from [portfolio project]..CovidDeaths
where location like '%egypt%'
order by 1,2


--Looking at Total cases vs population 
--shows what percentage of population got the covid
select Location, date, total_cases,population, (total_cases / population) * 100 as PercentOfPopulationInfected
from [portfolio project]..CovidDeaths
where location like '%egypt%'
order by 1,2

--Looking at countries with Highest infection rate compared to Population

select Location, population, Max (total_cases) as HighestInfectionCount, Max((total_cases/ population)) * 100 as PercentOfPopulationInfected
from [portfolio project]..CovidDeaths
--where location like '%egypt%'
group by population, location 
order by PercentOfPopulationInfected desc

--Showing Countries with Highest Death Count per Population

select Location, Max (Cast(Total_deaths as int)) as TotalDeathsCount
from [portfolio project]..CovidDeaths
--where location like '%egypt%'
where continent is not null
group by location 
order by TotalDeathsCount desc

--let's BREAK THINGS DOWN BY CONTINENT

select location, Max (Cast(Total_deaths as int)) as TotalDeathsCount
from [portfolio project]..CovidDeaths
--where location like '%egypt%'
where continent is null
group by location 
order by TotalDeathsCount desc

--GLOBAL NUMBERS

select date, Sum(new_cases)as Totalcases, Sum(Cast(new_deaths as int))as TotalDeaths,SUM(CAST(new_deaths as int)) / 
SUM (new_cases)* 100 as DeathPercentage
from [portfolio project]..CovidDeaths
--where location like '%egypt%'
where continent is not null
group by date
order by 1,2

--LOOKING AT TOTAL POPULATION vs Vaccinations

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated

from [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
   where dea.continent is not null
   order by 2,3

-----Use Cte

with PopvsVac(Continent, location, date,Population,New_vaccinations, RollingPeopleVaccinated)
as 
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated

from [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
   where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated / Population)* 100
from PopvsVac

--TEMP TABLE



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

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated

from [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
 --where dea.continent is not null
--order by 2,3
select *,(RollingPeopleVaccinated / Population)* 100
from #PercentPopulationVaccinated

--CREATING VIEWS FOR VISUALIZATION LATER

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated

from [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated / Population)* 100
from #PercentPopulationVaccinated
