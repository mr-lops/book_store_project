{{ config(
    materialized='incremental',
    unique_key='sk_shipping'
) }}

WITH shipping_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['co.shipping_method_id', 'co.dest_address_id']) }} AS sk_shipping,
        add.street_number,
        add.street_name,
        add.city,
        ct.country_name AS country,
        sm.method_name AS method,
        sm.cost
    FROM {{ source('book_store_stage', 'cust_order') }} co 
    JOIN {{ source('book_store_stage', 'shipping_method') }} sm ON co.shipping_method_id = sm.method_id
    JOIN {{ source('book_store_stage', 'address') }} add ON co.dest_address_id = add.address_id
    JOIN {{ source('book_store_stage', 'country') }} ct ON add.country_id = ct.country_id
)

SELECT sk_shipping,
       street_number,
       street_name,
       city,
       country,
       method,
       cost
FROM shipping_cte

{% if is_incremental() %}
    WHERE sk_shipping NOT IN (
        SELECT sk_shipping
        FROM {{ this }}
    )
{% endif %}