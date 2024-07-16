SELECT * FROM covid.coviddeaths 
Where continent is not null
ORDER BY 3,4;


SELECT * FROM covid.covidvacanations
ORDER BY 3,4;

SELECT location , date , total_cases , new_cases, total_deaths, population
FROM covid.coviddeaths ORDER BY 1, 2;

SELECT location , date , total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covid.coviddeaths 
Where location like '%Egypt%'
ORDER BY 1, 2 and date desc;

-- looking at total cases vs population
 SELECT location , date , total_cases, population, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM covid.coviddeaths 
Where location like '%Egypt%'
ORDER BY 1, 2 and date desc;

-- Looking at countries with the highest infection rate compared yo population
 SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM covid.coviddeaths 
-- Where location like '%Egypt%'
Group by location ,  population
ORDER BY 1, 2 ;

 SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM covid.coviddeaths 
-- Where location like '%Egypt%'
Where continent is not null
Group by location ,  population
ORDER BY PercentOfPopulationInfected desc;

-- Higest deaths count per population
SELECT location, MAX(convert(total_deaths, unsigned)) as Highestdeathscount
FROM covid.coviddeaths 
-- Where location like '%Egypt%'
Where continent is not null
Group by location 
ORDER BY Highestdeathscount desc;

-- lets break things by continent
SELECT continent, MAX(convert(total_deaths, unsigned)) as Highestdeathscount
FROM covid.coviddeaths 
-- Where location like '%Egypt%'
Where continent is not null
Group by continent
ORDER BY Highestdeathscount desc;

-- globbal numbers
SELECT SUM(new_cases) as Total_cases, SUM(convert(new_deaths, unsigned)) AS Total_deaths, SUM(convert(new_deaths, unsigned))/SUM(new_cases)*100 AS DeathPercentage
FROM covid.coviddeaths 
-- Where location like '%Egypt%'
Where continent is not null
-- GROUP BY date
ORDER BY 1, 2;



-- Total population vs vaccinations
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(convert(vac.new_vaccinations, unsigned)) 
OVER (partition by death.location order by death.location, death.date) as Rolling_people_vaccinated
FROM covid.coviddeaths death
join covid.covidvacanations vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null 
ORDER BY 2, 3;


-- USE CTE

With PopvsVac(Continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(convert(vac.new_vaccinations, unsigned)) 
OVER (partition by death.location order by death.location, death.date) as Rolling_people_vaccinated
FROM covid.coviddeaths death
join covid.covidvacanations vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null 
ORDER BY 2, 3)
SELECT *, RollingPeoplevaccinated FROM PopvsVac;

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
continent nvarchar (255),
location nvarchar (255),
Date datetime, 
population numeric,
new_vaccinations_numeric,
Rollingpeoplevaccinated numeric
);

insert into #PercentPopulationVaccinated 
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(convert(vac.new_vaccinations, unsigned)) 
OVER (partition by death.location order by death.location, death.date) as Rollingpeoplevaccinated
FROM covid.coviddeaths death
join covid.covidvacanations vac
on death.location = vac.location
and death.date = vac.date
-- where death.continent is not null 
-- ORDER BY 2, 3

SELECT*, (Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated





-- create view to store data for visualiztions

create view percentpopulationvaccinated as 
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(convert(vac.new_vaccinations, unsigned)) 
OVER (partition by death.location order by death.location, death.date) as Rollingpeoplevaccinated
FROM covid.coviddeaths death
join covid.covidvacanations vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null 
-- ORDER BY 2, 3

SELECT * FROM percentpopulationvaccinated;







