{{ config(
    materialized='incremental',
    incremental_strategy='append',
    schema='silver',
    format='parquet'
) }}

SELECT
    CAST(dt_txt AS TIMESTAMP)            AS forecast_at,
    DATE(CAST(dt_txt AS TIMESTAMP))      AS forecast_date,
    HOUR(CAST(dt_txt AS TIMESTAMP))      AS forecast_hour,
    city,
    country,
    lon,
    lat,
    ROUND(temp - 273.15, 2)              AS temp_c,
    ROUND(feels_like - 273.15, 2)        AS feels_like_c,
    ROUND(temp_min - 273.15, 2)          AS temp_min_c,
    ROUND(temp_max - 273.15, 2)          AS temp_max_c,
    humidity                             AS humidity_pct,
    pressure                             AS pressure_hpa,
    weather_main,
    weather_desc,
    wind_speed                           AS wind_speed_ms,
    clouds_all                           AS clouds_pct,
    rain_3h                              AS rain_3h_mm,
    ROUND(pop * 100, 0)                  AS rain_probability_pct,
    visibility,
    dt                                   AS dt_raw,
    year, month, day, hour
FROM {{ source('weather_pipeline', 'bronze_forecast') }}

{% if is_incremental() %}
WHERE dt > (SELECT MAX(dt_raw) FROM {{ this }})
{% endif %}