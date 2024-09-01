{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        history_id,
        order_id,
        status_id,
        status_date
    FROM {{ source('book_store_stage', 'order_history') }}
)

SELECT 
    history_id,
    order_id,
    status_id,
    status_date
FROM raw_data