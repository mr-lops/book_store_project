{{ config(
    materialized='incremental',
    unique_key='sk_order'
) }}

WITH authors_book AS (
    SELECT ba.book_id,
           LISTAGG(a.author_name, ';') WITHIN GROUP(ORDER BY a.author_name) AS author_names
    FROM {{ source('book_store_stage', 'book_author') }} ba
    JOIN {{ source('book_store_stage', 'author') }} a ON ba.author_id = a.author_id
    GROUP BY ba.book_id
)
,
order_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['ol.order_id', 'ol.book_id', 'price']) }} AS sk_order,
        bo.title AS book_title, 
        bo.isbn13 AS book_isbn13, 
        bo.num_pages AS book_num_pages,
        bo.publication_date AS book_publication_date,
        ab.author_names AS book_author,
        pub.publisher_name AS book_publisher,
        bol.language_name AS book_tongue,
        ol.order_id AS order_identifier,
        co.order_date,
        ol.price
    FROM {{ source('book_store_stage', 'order_line') }} ol
    JOIN {{ source('book_store_stage', 'cust_order') }} co ON ol.order_id = co.order_id
    JOIN {{ source('book_store_stage', 'book') }} bo ON ol.book_id = bo.book_id
    JOIN {{ source('book_store_stage', 'book_language') }} bol ON bo.language_id = bol.language_id
    JOIN {{ source('book_store_stage', 'publisher') }} pub ON bo.publisher_id = pub.publisher_id
    JOIN authors_book ab ON bo.book_id = ab.book_id
)

SELECT sk_order,
        book_title,
        book_isbn13,
        book_num_pages,
        book_publication_date,
        book_author,
        book_publisher,
        book_tongue,
        order_identifier,
        order_date,
        price
FROM order_cte

{% if is_incremental() %}
    WHERE sk_order NOT IN (
        SELECT sk_order
        FROM {{ this }}
    )
{% endif %}