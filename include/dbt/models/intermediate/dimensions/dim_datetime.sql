{{ config(
    materialized='incremental',
    unique_key='sk_datetime'
) }}

WITH datetime_cte AS (
  SELECT DISTINCT
    TO_VARCHAR(status_date) AS sk_datetime,
    status_date::TIMESTAMP AS datetime_content,
  FROM {{ ref('stg_order_history') }}
  WHERE status_date IS NOT NULL
  UNION
  SELECT DISTINCT
    TO_VARCHAR(order_date) AS sk_datetime,
    order_date::TIMESTAMP AS datetime_content,
  FROM {{ ref('stg_cust_order') }}
  WHERE order_date IS NOT NULL
)
SELECT
  sk_datetime,
  TO_TIMESTAMP_NTZ(datetime_content) AS datetime,
  DAY(datetime_content) AS day,
  DAYNAME(datetime_content) AS day_name,
  MONTH(datetime_content) AS month,
  MONTHNAME(datetime_content) AS month_name,
  YEAR(datetime_content) AS year,
  HOUR(datetime_content) AS hour,
  MINUTE(datetime_content) AS minute,
  DAYOFWEEK(datetime_content) AS weekday,
  QUARTER(datetime_content) AS quarter
FROM datetime_cte

{% if is_incremental() %}
    WHERE sk_datetime NOT IN (
        SELECT sk_datetime
        FROM {{ this }}
    )
{% endif %}