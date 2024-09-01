{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        customer_id,
        address_id,
        status_id
    FROM {{ source('book_store_stage', 'customer_address') }}
)

SELECT 
    customer_id,
    address_id,
    status_id
FROM raw_data