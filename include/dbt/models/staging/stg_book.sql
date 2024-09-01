{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        book_id,
        title,
        isbn13,
        language_id,
        num_pages,
        publication_date,
        publisher_id,
    FROM {{ source('book_store_stage', 'book') }}
)

SELECT 
    book_id,
    title,
    isbn13,
    language_id,
    num_pages,
    publication_date,
    publisher_id,
FROM raw_data