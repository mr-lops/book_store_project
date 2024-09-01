{{ config(
    materialized='incremental',
    unique_key='sk_order_line'
) }}

WITH order_line_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['line_id', 'order_id ', 'book_id', 'price']) }} AS sk_order_line,
        line_id,
        order_id,
        book_id,
        price
    FROM {{ ref('stg_order_line') }}
)

SELECT sk_order_line,
       line_id,
       order_id,
       order_line_cte.book_id,
       price,
       dim_book.sk_book AS sk_book
FROM order_line_cte
LEFT JOIN {{ ref('dim_book') }} AS dim_book
ON order_line_cte.book_id = dim_book.book_id

{% if is_incremental() %}
    WHERE sk_order_line NOT IN (
        SELECT sk_order_line
        FROM {{ this }}
    )
{% endif %}