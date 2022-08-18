Select *
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$
Where continent is not null
Order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$
Where continent is not null
Order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS 
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN 'X' COUNTRY

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$
Where location like '%Costa Rica%'
and continent is not null
Order by 1,2

--LOOKING AT THE TOTAL CASES VS POPULATION 
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID 

Select Location, Date, population, total_cases, (total_cases/population)*100 AS Percent_of_Population_Infected
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$
Where location like '%Costa Rica%'
and continent is not null
Order by 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS Percent_of_Population_Infected
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$
--Where location like '%Costa Rica%'
Where continent is not null
GROUP BY location, population
Order by Percent_of_Population_Infected DESC

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 

Select Location, MAX(cast(total_deaths as int)) AS Total_DeathCount
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$
--Where location like '%Costa Rica%'
Where continent is not null
GROUP BY location
Order by Total_DeathCount DESC

--BREAK DOWN BY CONTINENT

--SHOWING THE CONTINENTS WITH THE HIGHEST DEATHCOUNT PER POPULATION 

Select continent, MAX(cast(total_deaths as int)) AS Total_DeathCount
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$
--Where location like '%Costa Rica%'
Where continent is not null
GROUP BY continent
Order by Total_DeathCount DESC

/*Select location, MAX(cast(total_deaths as int)) AS Total_DeathCount
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$
--Where location like '%Costa Rica%'
Where continent is null
GROUP BY location
Order by Total_DeathCount DESC

CHECK MINUTE 40 OF THE VIDEO*/

--GLOBAL NUMBERS

Select /*Date,*/ SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int)) / SUM (new_cases)*100 AS Death_Percentage 
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$
--Where location like '%Costa Rica%'
Where continent is not null
--GROUP BY date
Order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
--USE CTE

With POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.Date) AS Rolling_People_Vaccinated    
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$ dea
Join [Portfolio Project- Covid Deaths - Vaccinations]..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (Rolling_People_Vaccinated/Population)*100
From POPvsVAC

--TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinantions numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.Date) AS Rolling_People_Vaccinated    
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$ dea
Join [Portfolio Project- Covid Deaths - Vaccinations]..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS 

Create View PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.Date) AS Rolling_People_Vaccinated    
From [Portfolio Project- Covid Deaths - Vaccinations]..CovidDeaths$ dea
Join [Portfolio Project- Covid Deaths - Vaccinations]..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

SELECT * 
FROM PercentPopulationVaccinated