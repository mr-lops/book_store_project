{{ config(
    materialized='incremental',
    unique_key='sk_sale'
) }}


WITH dim_shipping AS (
    SELECT order_id,
        shipping_method_id,
        customer_id,
        dest_address_id,
    FROM {{ source('book_store_stage', 'cust_order') }}
)
,
dim_customer AS (
    SELECT customer_id,
            email
    FROM {{ source('book_store_stage', 'customer') }}
)
,
sale_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['oh.status_id', 'do.sk_order']) }} AS sk_sale,
        do.sk_order AS order_id,
        {{ dbt_utils.generate_surrogate_key(['dc.customer_id', 'dc.email']) }} AS customer_id,
        {{ dbt_utils.generate_surrogate_key(['ds.shipping_method_id', 'ds.dest_address_id']) }} AS shipping_id,
        os.status_value AS sale_status,
        oh.status_date
    FROM {{ source('book_store_stage', 'order_history') }} oh 
    JOIN {{ source('book_store_stage', 'order_status') }} os ON oh.status_id = os.status_id
    JOIN {{ ref('dim_order') }} do ON oh.order_id = do.order_identifier
    JOIN dim_shipping ds ON oh.order_id = ds.order_id
    JOIN dim_customer dc ON ds.customer_id = dc.customer_id
)

SELECT sk_sale,
       order_id,
       customer_id,
       shipping_id,
       sale_status,
       status_date
FROM sale_cte

{% if is_incremental() %}
    WHERE sk_sale NOT IN (
        SELECT sk_sale
        FROM {{ this }}
    )
{% endif %}