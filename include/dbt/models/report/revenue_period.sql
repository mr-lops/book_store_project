{{ config(
    materialized='table',
) }}

SELECT 
    dt.year,
    dt.month,
    SUM(o.total_amount) AS total_revenue
FROM 
    {{ ref('fact_order') }} o
JOIN 
    {{ ref('dim_datetime') }} dt ON o.sk_datetime = dt.sk_datetime
GROUP BY 
    dt.year, dt.month
ORDER BY 
    dt.year ASC, dt.month ASC