--TOP 10 Highly Polluted Areas of each state
WITH ranked_pollution AS (
    SELECT
        State_UT,
        Area,
        Current_AQI,
        ROW_NUMBER() OVER(PARTITION BY State_UT ORDER BY Current_AQI DESC) AS rn
    FROM AQI_Data
)

SELECT
    State_UT,
    Area,
    Current_AQI
FROM ranked_pollution
WHERE /*State_UT = 'Select State_UT' AND*/ rn<=10
ORDER BY State_UT, rn;


--TOP 10 Cleanest Areas of each state
WITH ranked_pollution AS (
    SELECT
        State_UT,
        Area,
        Current_AQI,
        ROW_NUMBER() OVER(PARTITION BY State_UT ORDER BY Current_AQI ASC) AS rn
    FROM AQI_Data
)

SELECT
    State_UT,
    Area,
    Current_AQI
FROM ranked_pollution
WHERE /*State_UT = 'Select State_UT' AND*/ rn<=10
ORDER BY State_UT, rn;