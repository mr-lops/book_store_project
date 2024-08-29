{{ config(
    materialized='incremental',
    unique_key='sk_book'
) }}

WITH book_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['bo.book_id', 'bo.language_id', 'bo.publisher_id']) }} AS sk_book,
        bo.title, 
        bo.isbn13, 
        bo.num_pages,
        bo.publication_date,
        aut.author_name AS author,
        pub.publisher_name AS publisher,
        bol.language_name AS tongue
    FROM {{ source('book_store_stage', 'book') }} bo 
    JOIN {{ source('book_store_stage', 'book_language') }} bol ON bo.language_id = bol.language_id
    JOIN {{ source('book_store_stage', 'publisher') }} pub ON bo.publisher_id = pub.publisher_id
    JOIN {{ source('book_store_stage', 'book_author') }} boa ON bo.book_id = boa.book_id
    JOIN {{ source('book_store_stage', 'author') }} aut ON boa.author_id = aut.author_id
)

SELECT sk_book,
       title,
       isbn13,
       num_pages,
       publication_date,
       author,
       publisher,
       tongue
FROM book_cte

{% if is_incremental() %}
    WHERE sk_book NOT IN (
        SELECT sk_book
        FROM {{ this }}
    )
{% endif %}