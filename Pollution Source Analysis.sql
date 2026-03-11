--Pollution Source Analysis

WITH pollution_source_base AS (
	SELECT *
	FROM AQI_Data
),

pollution_source_aggregates AS (
	SELECT Major_Source_of_Pollution,
		COUNT(*) AS Total_Areas,
		ROUND(AVG(Current_AQI), 2) AS avg_aqi
	FROM pollution_source_base
	WHERE State_UT = 'Andhra Pradesh'
	GROUP BY Major_Source_of_Pollution
),

impact_calculation AS (
	SELECT 
		Major_Source_of_Pollution,
		Total_Areas,
		avg_aqi,
		ROUND(Total_Areas*100.0/(SUM(Total_Areas) OVER()), 2) AS percent_areas_effected,
		ROUND(avg_aqi*(Total_Areas*100.0/SUM(Total_Areas) OVER())/100, 2) AS impact_score
	FROM pollution_source_aggregates
)

SELECT
	Major_Source_of_Pollution,
	Total_Areas,
	avg_aqi,
	percent_areas_effected,
	impact_score,
	RANK() OVER(ORDER BY impact_score DESC) AS impact_Rank
FROM impact_calculation
ORDER BY impact_Rank