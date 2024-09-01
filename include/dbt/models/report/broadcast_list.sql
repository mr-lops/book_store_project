{{ config(
    materialized='view',
) }}

SELECT email,
    first_name
FROM {{ ref('dim_customer') }}