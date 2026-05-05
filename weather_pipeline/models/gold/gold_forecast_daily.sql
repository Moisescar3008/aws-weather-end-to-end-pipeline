{{ config(
    materialized='incremental',
    incremental_strategy='append',
    schema='gold',
    format='parquet'
) }}

SELECT
    forecast_date,
    city,
    country,
    ROUND(AVG(temp_c), 2)                AS temp_avg_c,
    ROUND(MAX(temp_max_c), 2)            AS temp_max_c,
    ROUND(MIN(temp_min_c), 2)            AS temp_min_c,
    ROUND(AVG(feels_like_c), 2)          AS feels_like_avg_c,
    ROUND(AVG(humidity_pct), 2)          AS humidity_avg_pct,
    ROUND(SUM(rain_3h_mm), 2)            AS total_rain_mm,
    ROUND(MAX(rain_probability_pct), 0)  AS max_rain_prob_pct,
    ROUND(AVG(rain_probability_pct), 0)  AS avg_rain_prob_pct,
    ROUND(AVG(wind_speed_ms), 2)         AS wind_avg_ms,
    MAX(clouds_pct)                      AS clouds_max_pct,
    -- condicion mas frecuente del dia
    MAX_BY(weather_main, rain_probability_pct) AS dominant_condition
FROM {{ ref('silver_forecast') }}

{% if is_incremental() %}
WHERE forecast_date > (SELECT MAX(forecast_date) FROM {{ this }})
{% endif %}

GROUP BY forecast_date, city, country
ORDER BY forecast_date