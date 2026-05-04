# 🌤️ AWS Weather End-to-End Data Pipeline

An end-to-end serverless data engineering pipeline that ingests, transforms, and visualizes real-time and forecast weather data for Mérida, Yucatán using AWS and dbt.

---

## 🏗️ Architecture

```
OpenWeather API (Current Weather + 5-Day Forecast)
          ↓
AWS Lambda (Python) — ingestion and JSON flattening
          ↓
Amazon S3 — Bronze Layer (raw partitioned data)
          ↓
dbt Core + Amazon Athena — SQL transformations
          ↓
Amazon S3 — Silver Layer (clean, typed data)
          ↓
Amazon S3 — Gold Layer (aggregations and KPIs)
          ↓
Power BI — Visualization Dashboard

Orchestration: EventBridge (Lambda triggers) + GitHub Actions (dbt run every hour)
Monitoring:    Amazon CloudWatch
```

---

## 📦 Tech Stack

| Layer | Tool |
|---|---|
| Source | OpenWeather API |
| Ingestion | AWS Lambda (Python 3.12) |
| Storage | Amazon S3 (Medallion Architecture) |
| Query Engine | Amazon Athena (Serverless) |
| Transformation | dbt Core + dbt-athena-community |
| Orchestration | Amazon EventBridge + GitHub Actions |
| Monitoring | Amazon CloudWatch |
| Visualization | Power BI |

---

## 🥉🥈🥇 Medallion Architecture

```
s3://weather-pipeline-merida/
├── bronze/
│   ├── current/          ← flattened JSON per hour (Current Weather)
│   └── forecast/         ← JSONL with 40 records per call (5 Day Forecast)
├── silver/
│   ├── silver_current_weather/   ← clean data, Kelvin → Celsius
│   └── silver_forecast/          ← clean forecast with rain probability
├── gold/
│   ├── gold_daily_summary/       ← daily weather summary
│   ├── gold_hourly_trend/        ← hourly trend for charts
│   └── gold_forecast_daily/      ← daily aggregated forecast
└── athena-results/       ← Athena query results
```

---

## ⚡ Automation

| Process | Trigger | Frequency |
|---|---|---|
| Lambda Current Weather | EventBridge | Every hour |
| Lambda Forecast | EventBridge | Every 3 hours |
| dbt run | GitHub Actions | Every hour |

---

## 🔧 dbt Models

```
models/
├── silver/
│   ├── sources.yml                  ← bronze table definitions
│   ├── silver_current_weather.sql   ← cleaning and unit conversion
│   └── silver_forecast.sql          ← forecast flattening and conversion
└── gold/
    ├── gold_daily_summary.sql       ← daily averages and totals
    ├── gold_hourly_trend.sql        ← hourly trend for dashboards
    └── gold_forecast_daily.sql      ← daily forecast with rain probability
```

**Transformations applied:**
- Temperature conversion Kelvin → Celsius
- Nested JSON fields extracted to flat columns
- `COALESCE` on rain fields (field missing when no rain)
- Unix timestamp converted to readable datetime
- Rain probability from 0-1 to percentage (0-100%)
- Daily aggregations: avg, max, min, sum

---

## 📊 Dashboard

Built in Power BI connected to Amazon Athena via ODBC driver.

**Current Weather page**
- Current temperature, humidity, feels like, and rainfall cards
- Temperature by hour of day (line chart)
- Hottest day and rainiest day KPIs (DAX measures)
- Weather summary by condition (table)

**5-Day Forecast page**
- Temperature range max/min per day (line chart)
- Rain probability per day (bar chart)
- Expected rainfall per day (bar chart)
- Weather summary by condition (table)

---

## 💰 Estimated Cost

| Service | Cost/month |
|---|---|
| AWS Lambda | $0.00 |
| Amazon S3 | ~$0.01 |
| Amazon Athena | ~$0.50 |
| Amazon EventBridge | $0.00 |
| Amazon CloudWatch | ~$0.01 |
| GitHub Actions | $0.00 |
| **Total** | **~$0.52/month** |

> Without continuous execution the cost is practically $0.00/month.

---

## 🔐 Security

- Dedicated IAM user with least privilege policies per service
- API keys stored as Lambda environment variables (never hardcoded)
- AWS credentials in GitHub Actions via Secrets (never in code)
- dbt `profiles.yml` excluded from repository via `.gitignore`
- S3 bucket with public access blocked

---

## 🚀 Setup

### 1. Prerequisites
- AWS account
- Python 3.11+
- dbt-athena-community
- Power BI Desktop

### 2. Lambda Environment Variables
```
OPENWEATHER_API_KEY  → your OpenWeather API key
S3_BUCKET            → S3 bucket name
CITY                 → Merida
COUNTRY_CODE         → MX
```

### 3. GitHub Secrets
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### 4. Run dbt locally
```bash
python -m venv dbt-env
dbt-env\Scripts\activate
pip install dbt-athena-community
cd weather_pipeline
dbt run
```

---

## 📈 Roadmap

- [ ] Add more cities in southeastern Mexico (Cancún, Campeche, Valladolid)
- [ ] dbt data quality tests (not_null, freshness, accepted_values)
- [ ] CloudWatch alerts if Lambda fails
- [ ] Map dashboard with bubble chart per city in Power BI