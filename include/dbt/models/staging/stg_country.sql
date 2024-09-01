{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        country_id,
        country_name
    FROM {{ source('book_store_stage', 'country') }}
)

SELECT 
    country_id,
    country_name
FROM raw_data