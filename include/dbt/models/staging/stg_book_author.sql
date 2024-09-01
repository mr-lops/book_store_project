{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        book_id,
        author_id
    FROM {{ source('book_store_stage', 'book_author') }}
)

SELECT 
    book_id,
    author_id
FROM raw_data