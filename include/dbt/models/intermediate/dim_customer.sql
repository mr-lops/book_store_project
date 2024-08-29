{{ config(
    materialized='incremental',
    unique_key='sk_customer'
) }}

WITH customer_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'email']) }} AS sk_customer,
        first_name, 
        last_name, 
        email
    FROM {{ source('book_store_stage', 'customer') }}
)

SELECT sk_customer,
    first_name, 
    last_name, 
    email,
FROM customer_cte

{% if is_incremental() %}
    WHERE sk_customer NOT IN (
        SELECT sk_customer
        FROM {{ this }}
    )
{% endif %}