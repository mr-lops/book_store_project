{{ config(
    materialized='incremental',
    unique_key='sk_shipping_method'
) }}

WITH shipping_method_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['method_id','method_name', 'cost']) }} AS sk_shipping_method,
        method_id,
        method_name,
        cost, 
    FROM {{ ref('stg_shipping_method') }}
)

SELECT sk_shipping_method,
    method_id,
    method_name,
    cost
FROM shipping_method_cte

{% if is_incremental() %}
    WHERE sk_shipping_method NOT IN (
        SELECT sk_shipping_method
        FROM {{ this }}
    )
{% endif %}