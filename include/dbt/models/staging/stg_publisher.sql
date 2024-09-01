{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        publisher_id,
        publisher_name,
    FROM {{ source('book_store_stage', 'publisher') }}
)

SELECT 
    publisher_id,
    publisher_name
FROM raw_data