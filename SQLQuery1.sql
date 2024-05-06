--Select * from PortfolioProject.dbo.CovidDeaths
--order by 3,4

--Select * from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths , population
from PortfolioProject..CovidDeaths
where continent is not Null
order by 1,2 
--Looking at total cases vs total deaths

Select Location, Date, total_cases,  total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like 'Pakistan'
and continent is not Null
order by 1,2 


--Looking at total cases vs population
--Total Percentage of peoples got Covid

Select Location, Date, population ,total_cases,   (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
Where location like 'Pakistan'
and continent is not Null
order by 1,2 


---Countries with highest Infection rate compared to Population
Select Location,  population ,MAX(total_cases),   MAX((total_cases/population))*100 as 
PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not Null
Group by location, population
order by PercentPopulationInfected desc


--Countries with highest Death count per Population
Select Location,  MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is  Null
Group by location
order by TotalDeathCount desc

--Lets break down by Continent
Select continent,  MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not Null
Group by continent
order by TotalDeathCount desc


--Global Numbers
Select  Date, SUM(New_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, (SUM(cast(New_deaths as int))/SUM(New_cases))
*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where --location like 'Pakistan'
 continent is not Null
 Group by date
order by 1,2 


--Total Population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
inner Join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

--Using CTE
With PopvsVac (continent, location, date,population,new_vaccinations,RollingPeopleVaccinated )
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
inner Join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100 from popvsvac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population  numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
inner Join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null


Select * from #PercentPopulationVaccinated

---Create View to store data for later Tablue Visualisation
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int, vac.new_vaccinations)) over (Partition by dea.location
Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
inner Join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated