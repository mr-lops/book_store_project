{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        customer_id,
        first_name,
        last_name,
        email
    FROM {{ source('book_store_stage', 'customer') }}
)

SELECT 
    customer_id,
    first_name,
    last_name,
    email
FROM raw_data