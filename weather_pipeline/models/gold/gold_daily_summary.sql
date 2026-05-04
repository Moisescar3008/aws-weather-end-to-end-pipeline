{{ config(
    materialized='incremental',
    incremental_strategy='append',
    schema='gold'
) }}

SELECT
    DATE(ingested_at)                        AS date,
    city,
    country,
    ROUND(AVG(temp_c), 2)                    AS temp_avg_c,
    ROUND(MAX(temp_c), 2)                    AS temp_max_c,
    ROUND(MIN(temp_c), 2)                    AS temp_min_c,
    ROUND(AVG(feels_like_c), 2)              AS feels_like_avg_c,
    ROUND(AVG(humidity_pct), 2)              AS humidity_avg_pct,
    ROUND(AVG(pressure_hpa), 2)              AS pressure_avg_hpa,
    ROUND(SUM(rain_1h_mm), 2)                AS total_rain_mm,
    COUNT(CASE WHEN rain_1h_mm > 0 THEN 1 END) AS rainy_hours,
    ROUND(AVG(wind_speed_ms), 2)             AS wind_avg_ms,
    MAX(clouds_pct)                          AS clouds_max_pct
FROM {{ ref('silver_current_weather') }}

{% if is_incremental() %}
WHERE DATE(ingested_at) > (SELECT MAX(date) FROM {{ this }})
{% endif %}

GROUP BY DATE(ingested_at), city, country