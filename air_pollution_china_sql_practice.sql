-- Details of the dataset
SELECT * FROM air_pollution.air_pollution_china;

-- List all distinct cities recorded in the dataset.
SELECT distinct City FROM air_pollution.air_pollution_china;

-- Find the average AQI for each city.
SELECT City, round(avg(AQI),3) as `Average AQI` 
FROM air_pollution.air_pollution_china
group by City;

-- Which city recorded the maximum PM2.5 in the dataset?
SELECT City, round(avg(`PM2.5 (Âµg/mÂ³)`),3) as `Average PM2.5 (Âµg/mÂ³)` 
FROM air_pollution.air_pollution_china
group by City
order by `Average PM2.5 (Âµg/mÂ³)` desc
limit 1;

-- Retrieve the top 3 cities with the worst air quality (highest AQI).
SELECT City, round(avg(AQI),3) as `Average AQI` 
FROM air_pollution.air_pollution_china
group by City
order by `Average AQI` desc
limit 3;

-- How many days had an AQI greater than 300 (extreme pollution) in each city? 
SELECT City, count(`Day of Week`) as `Days with AQI>300` 
FROM air_pollution.air_pollution_china
where AQI>300
group by City;

-- Calculate the monthly average AQI for Beijing.
select Month, round(avg(AQI),3) as "Average AQI"
FROM air_pollution.air_pollution_china
where city="Beijing"
group by Month
order by Month;

-- Which year had the highest average PM2.5 across all cities?
select Year, round(avg(`PM2.5 (Âµg/mÂ³)`),3) as `Highest average PM2.5`
FROM air_pollution.air_pollution_china
group by Year
order by `Highest average PM2.5` desc
limit 1;

-- List all cities where the average wind speed was above 3 m/s.
select City, round(avg(`Wind Speed (m/s)`),3) as "Average wind speed"
FROM air_pollution.air_pollution_china
where `Wind Speed (m/s)`>3
group by City;

-- Find the average AQI per season (Spring, Summer, Autumn, Winter) across all years.
Select Season, round(avg(AQI),3) as `Average AQI`
FROM air_pollution.air_pollution_china
group by Season
order by `Average AQI` desc;


-- Which pollutant (PM2.5, PM10, NO2, etc.) has the strongest presence on average across all cities?
select "PM2.5 (Âµg/mÂ³)" as Pollutant, round(Avg(`PM2.5 (Âµg/mÂ³)`),3) as "Average Pollutant"
FROM air_pollution.air_pollution_china
union all
select "PM10 (Âµg/mÂ³)" as Pollutant, round(Avg(`PM10 (Âµg/mÂ³)`),3) as "Average Pollutant"
FROM air_pollution.air_pollution_china
union all
select "NO2 (Âµg/mÂ³)" as Pollutant, round(Avg(`NO2 (Âµg/mÂ³)`),3) as "Average Pollutant"
FROM air_pollution.air_pollution_china
union all
select "SO2 (Âµg/mÂ³)" as Pollutant, round(Avg(`SO2 (Âµg/mÂ³)`),3) as "Average Pollutant"
FROM air_pollution.air_pollution_china
union all
select "CO (mg/mÂ³)" as Pollutant, round(Avg(`CO (mg/mÂ³)`),3) as "Average Pollutant"
FROM air_pollution.air_pollution_china
union all
select "O3 (Âµg/mÂ³)" as Pollutant, round(Avg(`O3 (Âµg/mÂ³)`),3) as "Average Pollutant"
FROM air_pollution.air_pollution_china;


-- Use a subquery to find the city with the highest yearly AQI in 2020.
SELECT city, AVG(aqi) AS avg_aqi_2020
FROM air_pollution.air_pollution_china
WHERE YEAR= 2020
GROUP BY city
ORDER BY avg_aqi_2020 DESC
LIMIT 1;

-- Write a query that categorizes AQI into bands (e.g., Good, Moderate, Unhealthy) using CASE.
select City, Avg(AQI) as avg_value,
Case    WHEN Avg(AQI) <= 50 THEN 'Good'
        WHEN Avg(AQI) BETWEEN 51 AND 100 THEN 'Moderate'
        WHEN Avg(AQI) BETWEEN 101 AND 150 THEN 'Unhealthy for Sensitive Groups'
        WHEN Avg(AQI) BETWEEN 151 AND 200 THEN 'Unhealthy'
        WHEN Avg(AQI) BETWEEN 201 AND 300 THEN 'Very Unhealthy'
        WHEN Avg(AQI) > 300 THEN 'Hazardous'
        ELSE 'Unknown'
End as Category
FROM air_pollution.air_pollution_china
group by City
ORDER BY avg_value;


-- Identify the top 3 worst months by AQI for each year using a CTE.
with monthly_aqi as (
select Year, Month, AVG(AQI) as AVG_AQI,
Rank() over (Partition by Year order by AVG(AQI) desc) as Ranks
FROM air_pollution.air_pollution_china
group by  Year, Month
)
select Year, Month, AVG_AQI,Ranks
from monthly_aqi
where Ranks<=3
order by Year, Ranks;

-- Use a window function to rank cities by AQI for each year.
with rank_cities as (
select Year, City, Avg(AQI) as avg_aqi,
Rank() over (Partition By Year order by avg(AQI) desc) as Ranks
FROM air_pollution.air_pollution_china
Group by Year, City
)
select Year, City, Ranks
from rank_cities
order by Year, Ranks;


-- Create a view that shows monthly AQI statistics (avg, min, max) for each city.
Use air_pollution;
CREATE VIEW city_monthly_aqi_stats AS
SELECT 
    City,
   Year,
    Month,
    AVG(AQI) AS avg_aqi,
    MIN(AQI) AS min_aqi,
    MAX(AQI) AS max_aqi
FROM air_pollution.air_pollution_china
GROUP BY City, YEAR, MONTH;
SELECT * FROM city_monthly_aqi_stats WHERE City = 'Beijing';


-- Calculate the difference in AQI from the previous day for each city using LAG().
SELECT
    City,
    `Day of Week`,
    AQI,
    LAG(AQI) OVER (PARTITION BY City ORDER BY  `Day of Week`) AS prev_day_aqi,
    AQI - LAG(AQI) OVER (PARTITION BY City ORDER BY  `Day of Week`) AS aqi_diff
FROM air_pollution.air_pollution_china;

-- Find the month-over-month AQI change percentage using window functions.
select City, Year, Month,Avg(AQI) as avg_AQI,
LAG(AVG(AQI)) OVER (PARTITION BY City ORDER BY Year, Month) AS prev_month_aqi,
    ROUND(
        (AVG(AQI) - LAG(AVG(AQI)) OVER (PARTITION BY City ORDER BY Year, Month)) 
        / NULLIF(LAG(AVG(AQI)) OVER (PARTITION BY City ORDER BY Year, Month), 0) * 100, 2
    ) AS aqi_change_pct
FROM air_pollution.air_pollution_china
group by City,Year,Month
order by Year, Month;



