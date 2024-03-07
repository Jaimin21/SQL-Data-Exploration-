Select *
From Portfolio..CovidDeaths
 

-- Select *
--From Portfolio ..CovidVaccination
-- Order by 3,4


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select Location, date, total_cases, population,(total_cases/population)*100 as populationaffected
From Portfolio ..CovidDeaths
--Where location like '%states%'
 Order by 1,2

 -- Highest Infection Rate compared to population
 Select Location, population, MAX(total_cases) as HighestInfected, Max((total_cases/population))*100 as populationaffected
 From Portfolio ..CovidDeaths
 Group by Location, population
 Order by populationaffected desc

 -- Showing Countries with highest cases count per population

 Select Location, MAX(total_cases) as TotalCases
 From Portfolio ..CovidDeaths
 where continent is not null --  This ensures that only rows with a non-null value for the continent column are included in the result set.
 Group by Location
 Order by TotalCases desc

 Select Location, MAX(total_cases) as TotalCases
 From Portfolio ..CovidDeaths
 where continent is null --  This ensures that only rows with a non-null value for the continent column are included in the result set.
 Group by Location
 Order by TotalCases desc


--Global Numbers

Select Location, date, total_cases, population,(total_cases/population)*100 as populationaffected
From Portfolio ..CovidDeaths
--Where location like '%states%'
 Order by 1,2

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
 From Portfolio ..CovidDeaths
 where continent is not null
 Group by date
 order by 1,2


 -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
 
SELECT 
    dea.continent, 
    dea.Location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) as RollingPeopleVaccinated
FROM 
    Portfolio..CovidDeaths dea
JOIN 
    Portfolio..CovidVaccination vac ON dea.location = vac.location
                                             AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    dea.Location, dea.Date;

-- CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
