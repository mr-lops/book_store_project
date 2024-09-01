{{ config(
    materialized='incremental',
    unique_key='sk_address'
) }}

WITH address_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['a.address_id','a.street_number', 'a.street_name', 'a.city','a.country_id']) }} AS sk_address,
        a.address_id,
        a.street_number,
        a.street_name,
        a.city,
        c.country_name AS country
    FROM {{ ref('stg_address') }} a
    JOIN {{ ref('stg_country') }} c ON a.country_id = c.country_id
)

SELECT sk_address,
       address_id,
       street_number,
       street_name,
       city,
       country
FROM address_cte

{% if is_incremental() %}
    WHERE sk_address NOT IN (
        SELECT sk_address
        FROM {{ this }}
    )
{% endif %}