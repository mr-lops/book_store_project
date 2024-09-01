{{ config(
    materialized='incremental',
    unique_key='sk_customer'
) }}

WITH customer_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['customer_id','first_name', 'last_name', 'email']) }} AS sk_customer,
        customer_id,
        first_name, 
        last_name, 
        email
    FROM {{ ref('stg_customer') }}
)

SELECT sk_customer,
    customer_id,
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