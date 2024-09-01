{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        line_id,
        order_id,
        book_id,
        price
    FROM {{ source('book_store_stage', 'order_line') }}
)

SELECT 
    line_id,
    order_id,
    book_id,
    price
FROM raw_data