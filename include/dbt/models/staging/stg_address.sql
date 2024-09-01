{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        address_id,
        street_number,
        street_name,
        city,
        country_id
    FROM {{ source('book_store_stage', 'address') }}
)

SELECT 
    address_id,
    street_number,
    street_name,
    city,
    country_id
FROM raw_data
