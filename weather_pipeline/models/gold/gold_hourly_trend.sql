{{ config(
    materialized='incremental',
    incremental_strategy='append',
    schema='gold',
    format='parquet'
) }}

SELECT
    ingested_at,
    DATE(ingested_at)                        AS date,
    HOUR(ingested_at)                        AS hour_of_day,
    city,
    country,
    temp_c,
    feels_like_c,
    humidity_pct,
    wind_speed_ms,
    rain_1h_mm,
    clouds_pct,
    weather_main,
    weather_desc,
    dt_raw
FROM {{ ref('silver_current_weather') }}

{% if is_incremental() %}
WHERE dt_raw > (SELECT MAX(dt_raw) FROM {{ this }})
{% endif %}