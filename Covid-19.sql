select *
From [portfolio covid]..CovidDeaths
where continent is not null
order by 3,4
select *
From [portfolio covid]..CovidVaccinations
where continent is not null
order by 3,4

--Qestion-> Which country has the highest number of total cases?
SELECT location, MAX(total_cases) AS highest_total_cases
FROM [portfolio covid]..CovidDeaths
GROUP BY location
ORDER BY highest_total_cases DESC

--How many new cases were reported each day for specific location and for a specific date range?
SELECT location, date, new_cases
FROM [portfolio covid]..CovidDeaths
WHERE date >= '01/01/2021' AND date <= '09/10/2022' AND location= 'India'
ORDER BY date;

--What is the average number of new deaths per million people in each continent?
select continent, AVG(cast(total_deaths as int)) as  average_new_deaths_per_million
from [portfolio covid]..CovidDeaths
where continent is not null
group by continent



--How does the median age correlate with the number of total cases in each country?
select location, median_age, total_cases
FROM [portfolio covid]..CovidDeaths
where location like 'India' --for specific location
order by median_age desc;


--looking at death data

select  location, date,  total_cases,new_cases, total_deaths, population
From [portfolio covid]..CovidDeaths
order by 1,2

--total case vs total death
select  location, date,  total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From [portfolio covid]..CovidDeaths
where location like '%india%'
and   continent is not null
order by 1,2


--total cases vs population in percentage

select  location, date,  population, total_cases, (total_cases/population)*100 as percentPopulation
From [portfolio covid]..CovidDeaths
--where location like '%india%'
order by 1,2

-- highest cases compared to population
select  location,  population, Max( total_cases) as HighestInfectionCount , Max(total_cases/population)*100 as percentPopulationInfected
From [portfolio covid]..CovidDeaths
--where location like '%india%'
Group by Location, Population
order by percentPopulationInfected desc

--highest death count per population
 select  location,   Max(cast(total_deaths as int)) as TotalDeathCount
From [portfolio covid]..CovidDeaths
where continent is not null
--where location like '%india%' 
Group by Location
order by TotalDeathCount desc

--breakdown by continent
select  location,   Max(cast(total_deaths as int)) as TotalDeathCount
From [portfolio covid]..CovidDeaths
where continent is  null
--where location like '%india%' 
Group by location
order by TotalDeathCount desc

-- global numbers
select     sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From [portfolio covid]..CovidDeaths
--where location like '%india%'
where   continent is not null
--group by date
order by 1,2

--total population vs total vaccination
select death.location, death.continent, death.date, death.population, 
vac.new_vaccinations, 
sum(convert (int, death.new_vaccinations)) 
over (partition by death.location order by death.location , death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*
from [portfolio covid]..CovidDeaths death
join [portfolio covid]..CovidVaccinations vac
on death.location = vac.location
and death.date = vac.date
where   death.continent is not null

order by 2,3


-- joining to tables

select *
from [portfolio covid]..CovidDeaths death
join [portfolio covid]..CovidVaccinations vac
on death.location = vac.location
and death.date = vac.date

--use cte
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(select death.location, death.continent, death.date, death.population, 
vac.new_vaccinations, 
sum(convert (int, death.new_vaccinations)) 
over (partition by death.location order by death.location , death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*
from [portfolio covid]..CovidDeaths death
join [portfolio covid]..CovidVaccinations vac
on death.location = vac.location
and death.date = vac.date
where   death.continent is not null

--der by 2,3
) select*, (RollingPeopleVaccinated/population)*100
from PopvsVac