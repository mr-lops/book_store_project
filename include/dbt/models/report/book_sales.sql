{{ config(
    materialized='table',
) }}

SELECT 
    b.title AS book_title,
    COUNT(fol.order_id) AS total_sales,
    SUM(fol.price) AS total_revenue
FROM 
    {{ ref('fact_order_line') }} fol
JOIN 
    {{ ref('dim_book') }} b ON fol.sk_book = b.sk_book
GROUP BY 
    b.title
ORDER BY 
    total_revenue DESC