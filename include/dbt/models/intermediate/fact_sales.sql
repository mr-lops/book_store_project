{{ config(
    materialized='incremental',
    unique_key='sk_sale'
) }}


WITH dim_shipping AS (
    SELECT co.order_id,
        co.shipping_method_id,
        co.customer_id,
        co.dest_address_id,
        ol.book_id,
        ol.price
    FROM {{ source('book_store_stage', 'cust_order') }} co
    JOIN {{ source('book_store_stage', 'order_line') }} ol ON co.order_id = ol.order_id
)
,
dim_customer AS (
    SELECT customer_id,
            email
    FROM {{ source('book_store_stage', 'customer') }}
)
,
dim_book AS (
    SELECT book_id,
        language_id,
        publisher_id
    FROM {{ source('book_store_stage', 'book') }}
)
,
sale_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['oh.history_id','oh.order_id', 'oh.status_id']) }} AS sk_sale,
        {{ dbt_utils.generate_surrogate_key(['db.book_id', 'db.language_id', 'db.publisher_id']) }} AS book_id,
        {{ dbt_utils.generate_surrogate_key(['dc.customer_id', 'dc.email']) }} AS customer_id,
        {{ dbt_utils.generate_surrogate_key(['ds.shipping_method_id', 'ds.dest_address_id']) }} AS shipping_id,
        os.status_value AS sale_status,
        oh.status_date,
        ds.price
    FROM {{ source('book_store_stage', 'order_history') }} oh 
    JOIN {{ source('book_store_stage', 'order_status') }} os ON oh.status_id = os.status_id
    JOIN dim_shipping ds ON oh.order_id = ds.order_id
    JOIN dim_customer dc ON ds.customer_id = dc.customer_id
    JOIN dim_book db ON ds.book_id = db.book_id
)

SELECT sk_sale,
       book_id,
       customer_id,
       shipping_id,
       sale_status,
       status_date,
       price,
FROM sale_cte

{% if is_incremental() %}
    WHERE sk_sale NOT IN (
        SELECT sk_sale
        FROM {{ this }}
    )
{% endif %}