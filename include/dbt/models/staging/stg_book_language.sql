{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        language_id,
        language_code,
        language_name
    FROM {{ source('book_store_stage', 'book_language') }}
)

SELECT 
    language_id,
    language_code,
    language_name
FROM raw_data