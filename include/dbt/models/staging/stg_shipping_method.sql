{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        method_id,
        LOWER(method_name) AS method_name,
        cost
    FROM {{ source('book_store_stage', 'shipping_method') }}
)

SELECT 
    method_id,
    method_name,
    cost
FROM raw_data