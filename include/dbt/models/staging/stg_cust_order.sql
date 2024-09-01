{{ config(
    materialized='view'
) }}

WITH raw_data AS (
    SELECT 
        order_id,
        order_date,
        customer_id,
        shipping_method_id,
        dest_address_id
    FROM {{ source('book_store_stage', 'cust_order') }}
)

SELECT 
    order_id,
    order_date,
    customer_id,
    shipping_method_id,
    dest_address_id
FROM raw_data