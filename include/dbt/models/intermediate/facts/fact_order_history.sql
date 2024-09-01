{{ config(
    materialized='incremental',
    unique_key='sk_order_history'
) }}

WITH order_history_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['history_id', 'order_id ', 'order_history.status_id']) }} AS sk_order_history,
        history_id,
        order_id,
        order_status.status_value AS order_status,
        dim_datetime.sk_datetime AS sk_datetime

    FROM {{ ref('stg_order_history') }} order_history
    LEFT JOIN {{ ref('dim_datetime') }} AS dim_datetime
    ON order_history.status_date = dim_datetime.datetime

    LEFT JOIN {{ ref('stg_order_status') }} AS order_status
    ON order_history.status_id = order_status.status_id
)

SELECT sk_order_history,
       order_id,
       order_status,
       sk_datetime
FROM order_history_cte

{% if is_incremental() %}
    WHERE sk_order_history NOT IN (
        SELECT sk_order_history
        FROM {{ this }}
    )
{% endif %}