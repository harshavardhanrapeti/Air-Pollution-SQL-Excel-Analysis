CREATE DATABASE AQI_Project;
USE AQI_Project;

IF OBJECT_ID ('AQI_Data', 'U') IS NOT NULL
	DROP TABLE AQI_Data;
CREATE TABLE AQI_Data(
	State_UT VARCHAR(100),
	Area VARCHAR(100),
	Most_AQI_Reached INT,
	Current_AQI INT,
	Major_Source_of_Pollution VARCHAR(100),
	AQI_Difference INT,
	Category VARCHAR(100),
	District_Rank INT);

BULK INSERT AQI_Data
FROM "C:\Users\kavya\Downloads\all_india_districts_aqi(Project).csv"
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

--State-wise Analysis

WITH state_base AS (
    SELECT *
    FROM AQI_Data
),

--1.0 Aggregated KPIs per State
state_aggregates AS (
    SELECT
        State_UT,
        COUNT(*) AS Total_Areas,
        ROUND(AVG(Current_AQI), 2) AS avg_aqi,
        MAX(Current_AQI) AS max_aqi,
        --% Severe
        ROUND(100.0 * SUM(CASE WHEN Category = 'Severe' THEN 1 ELSE 0 END)/COUNT(*), 2) AS percent_Severe,
        --% Good
        ROUND(100.0 * SUM(CASE WHEN Category = 'Good' THEN 1 ELSE 0 END)/COUNT(*), 2) AS percent_Good 
    FROM state_base
    GROUP BY State_UT
),

--2.0 State Ranking (based on Avg AQI)
State_rank AS (
    SELECT
        State_UT,
        RANK() OVER(ORDER BY avg_aqi DESC) AS pollution_rank
    FROM state_aggregates
),

--3.0 Most Polluted Area in each state/UT
most_polluted AS (
    SELECT DISTINCT State_UT,
        Area As most_polluted_area,
        Current_AQI
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(PARTITION BY State_UT ORDER BY Current_AQI DESC) AS rn
        FROM state_base)t
    WHERE rn = 1 
),

--4.0 Cleanest Area in each state/UT
cleanest AS (
    SELECT DISTINCT State_UT,
        Area AS cleanest_area,
        Current_AQI
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(PARTITION BY State_UT ORDER BY Current_AQI ASC) AS rn
        FROM state_base)t
    WHERE rn = 1
),

--5.0 Most Common Pollution Source
common_source AS (
    SELECT DISTINCT State_UT,
        major_source_of_pollution,
        Total
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(PARTITION BY State_UT ORDER BY Total DESC) AS rn
        FROM (
            SELECT State_UT,
                Major_Source_of_Pollution,
                Count(*) AS Total
            FROM state_base
            GROUP BY State_UT, Major_Source_of_Pollution) agg
        ) ranked
    WHERE rn = 1
)

SELECT
    a.State_UT,
    r.pollution_rank,
    a.Total_Areas,
    a.avg_aqi,
    a.max_aqi,
    a.percent_Severe,
    a.percent_Good,
    c.cleanest_area,
    m.most_polluted_area,
    cs.Major_Source_of_Pollution AS most_common_source,
    --Intensity Ratio
    ROUND(a.avg_aqi*1.0 / MAX(a.avg_aqi) OVER(), 2) AS Intensity_Ratio

FROM state_aggregates a
JOIN State_rank r ON a.State_UT = r.State_UT
JOIN most_polluted m ON a.State_UT = m.State_UT
JOIN cleanest c ON a.State_UT = c.State_UT
JOIN common_source cs ON a.State_UT = cs.State_UT
/*WHERE a.State_UT = 'Andhra Pradesh'*/
ORDER BY r.pollution_rank
