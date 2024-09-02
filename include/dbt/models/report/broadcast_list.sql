{{ config(
    materialized='table',
) }}

SELECT email,
    first_name
FROM {{ ref('dim_customer') }}