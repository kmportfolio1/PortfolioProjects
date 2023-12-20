SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER by 3,4

SELECT *
FROM CovidVaccinations
ORDER by 1

SELECT Location, to_char(date, 'YYYY-MM-DD'), total_cases_per_million, new_cases,total_deaths_per_million, population
FROM CovidDeaths
ORDER by 1,2

SELECT Location, date, total_cases_per_million,total_deaths_per_million, (total_deaths_per_million/total_cases_per_million)*100 as death_percentage
FROM CovidDeaths
ORDER by 1,2,3

SELECT  total_deaths_per_million), 0) / NULLIF(CONVERT(float, total_cases_per_million), 0)) * 100 AS death_percentage
FROM CovidDeaths
ORDER by 1

SELECT Location, population, MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
GROUP BY 1,2 ORDER by PercentagePopulationInfected Desc

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY 1 ORDER by TotalDeathCount DESC

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY 1 ORDER by continent DESC

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY 1 ORDER by continent DESC

SELECT to_char(date, 'YYYY-MM-DD'), SUM(new_cases)as total_cases, SUM(new_deaths)as total_deaths,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY 1 ORDER by 1,2 desc

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations::numeric) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as d
JOIN CovidVaccinations as v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent is not null
ORDER by 2,3

with PopsVac (Continent, location, date, new_vaccinations, population,RollingPeopleVaccinated) as
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations::numeric) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM CovidDeaths as d
JOIN CovidVaccinations as v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent is not null
ORDER by 2,3)
SELECT * ,(RollingPeopleVaccinated/population::numeric)*100 FROM PopsVac


CREATE TABLE PercentPopulationVaccinated (
    Continent varchar(255),
    location varchar(255),
    date date,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated (
    Continent,
    location,
    date,
    Population,
    New_vaccinations,
    RollingPeopleVaccinated
)
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations::numeric,
    SUM(v.new_vaccinations::numeric) OVER (PARTITION BY d.location ORDER BY d.date) as RollingPeopleVaccinated
FROM
    CovidDeaths as d
JOIN
    CovidVaccinations as v ON d.location=v.location AND d.date=v.date
WHERE
    d.continent is not null
ORDER BY 2, 3;

SELECT
    *,
    (RollingPeopleVaccinated / Population::numeric) * 100 AS PercentPopulationVaccinated
FROM
    PercentPopulationVaccinated;


CREATE VIEW PercentPopulationVaccinated as 
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations::numeric,
    SUM(v.new_vaccinations::numeric) OVER (PARTITION BY d.location ORDER BY d.date) as RollingPeopleVaccinated
FROM
    CovidDeaths as d
JOIN
    CovidVaccinations as v ON d.location=v.location AND d.date=v.date
WHERE
    d.continent is not null
ORDER BY 2, 3;

SELECT * FROM PercentPopulationVaccinated

	