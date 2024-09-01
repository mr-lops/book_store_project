{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        status_id,
        LOWER(status_value) AS status_value
    FROM {{ source('book_store_stage', 'order_status') }}
)

SELECT 
    status_id,
    status_value
FROM raw_data