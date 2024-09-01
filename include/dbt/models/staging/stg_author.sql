{{ config(
    materialized='view',
) }}

WITH raw_data AS (
    SELECT 
        author_id,
        author_name
    FROM {{ source('book_store_stage', 'author') }}
)

SELECT 
    author_id,
    author_name,
FROM raw_data