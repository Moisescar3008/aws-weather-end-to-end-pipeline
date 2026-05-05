{{ config(
    materialized='incremental',
    incremental_strategy='append',
    schema='silver',
    format='parquet'
) }}

SELECT
    from_unixtime(dt)                    AS ingested_at,
    name                                 AS city,
    country,
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
    rain_1h                              AS rain_1h_mm,
    date_format(from_unixtime(sunrise), '%H:%i:%s') AS sunrise_time,
    date_format(from_unixtime(sunset), '%H:%i:%s')  AS sunset_time,
    lon,
    lat,
    dt                                   AS dt_raw,
    year, month, day, hour
FROM {{ source('weather_pipeline', 'bronze_current') }}

{% if is_incremental() %}
WHERE dt > (SELECT MAX(dt_raw) FROM {{ this }})
{% endif %}