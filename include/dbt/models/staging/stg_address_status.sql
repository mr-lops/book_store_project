{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT status_id,
        address_status
    FROM {{ source('book_store_stage', 'address_status') }}
)

SELECT status_id,
    address_status
FROM raw_data