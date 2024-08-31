{{ config(
    materialized='view',
) }}

SELECT DISTINCT email,
    first_name
FROM {{ ref('dim_customer') }}