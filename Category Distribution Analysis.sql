--Severity Category Distribution Analysis

WITH category_distribution_base AS (
    SELECT *
    FROM AQI_Data
),

category_distribution_aggregates AS (
    SELECT 
        Category,
        COUNT(*) AS Total_Areas,
        AVG(Current_AQI) AS avg_aqi
    FROM category_distribution_base
    /*WHERE State_UT = 'Andhra Pradesh'*/
    GROUP BY Category
),

category_percent_calculations AS (
    SELECT 
        Category,
        Total_Areas,
        ROUND(Total_Areas*100.0/(SUM(Total_Areas) OVER()), 2) AS percent_Areas
    FROM category_distribution_aggregates
)

SELECT
    cda.Category,
    cda.Total_Areas,
    cda.avg_aqi,
    cpc.percent_Areas,
    ROUND(SUM(percent_Areas) OVER(ORDER BY percent_Areas), 2) AS cumulative_percent
FROM category_distribution_aggregates cda
JOIN category_percent_calculations cpc ON cda.Category = cpc.Category
ORDER BY percent_Areas