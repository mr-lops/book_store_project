{{ config(
    materialized='incremental',
    unique_key='sk_order'
) }}

WITH order_amount_cte AS (
    SELECT 
        order_id,
        COUNT(book_id) AS qtd_books,
        SUM(price) AS total_amount
    FROM {{ ref('stg_order_line') }}
    GROUP BY order_id
)
,
order_cte AS (
    SELECT 
        cust_order.order_id,
        customer_id,
        shipping_method_id,
        dest_address_id,
        order_date,
        qtd_books,
        total_amount
    FROM {{ ref('stg_cust_order') }} AS cust_order
    LEFT JOIN order_amount_cte
    ON cust_order.order_id = order_amount_cte.order_id
)
,
fact_order_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['order_cte.order_id', 'order_cte.shipping_method_id ', 'order_cte.customer_id', 'order_cte.dest_address_id']) }} AS sk_order,
        order_cte.order_id,
        dim_customer.sk_customer AS sk_customer,
        dim_shipping_method.sk_shipping_method AS sk_shipping_method,
        dim_address.sk_address AS sk_address,
        dim_datetime.sk_datetime AS sk_datetime,
        order_cte.qtd_books,
        order_cte.total_amount,

    FROM order_cte
    LEFT JOIN {{ ref('dim_customer') }} AS dim_customer
    ON order_cte.customer_id = dim_customer.customer_id

    LEFT JOIN {{ ref('dim_shipping_method') }} AS dim_shipping_method
    ON order_cte.shipping_method_id = dim_shipping_method.method_id

    LEFT JOIN {{ ref('dim_address') }} AS dim_address
    ON order_cte.dest_address_id = dim_address.address_id

    LEFT JOIN {{ ref('dim_datetime') }} AS dim_datetime
    ON order_cte.order_date = dim_datetime.datetime
)

SELECT sk_order,
       order_id,
       sk_customer,
       sk_shipping_method,
       sk_address,
       sk_datetime,
       qtd_books,
       total_amount
FROM fact_order_cte

{% if is_incremental() %}
    WHERE sk_order NOT IN (
        SELECT sk_order
        FROM {{ this }}
    )
{% endif %}