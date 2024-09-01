{{ config(
    materialized='incremental',
    unique_key='sk_book'
) }}

WITH authors_book AS (
    SELECT b.title,
           LISTAGG(a.author_name, ';') WITHIN GROUP(ORDER BY a.author_name) AS authors
    FROM {{ ref('stg_book_author') }} ba
    JOIN {{ ref('stg_author') }} a ON ba.author_id = a.author_id
    JOIN {{ ref('stg_book') }} b ON ba.book_id = b.book_id
    GROUP BY b.title
)
,
book_cte AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['b.book_id', 'b.title', 'b.isbn13']) }} AS sk_book,
        b.book_id,
        b.title,
        b.isbn13,
        b.num_pages,
        b.publication_date,
        l.language_name,
        p.publisher_name,
        COALESCE(ab.authors, 'unknown') as authors
    FROM {{ ref('stg_book') }} b
    LEFT JOIN {{ ref('stg_book_language') }} l ON b.language_id = l.language_id
    LEFT JOIN {{ ref('stg_publisher') }} p ON b.publisher_id = p.publisher_id
    LEFT JOIN authors_book ab ON b.title = ab.title
)

SELECT sk_book,
       book_id,
       title,
       isbn13,
       num_pages,
       publication_date,
       language_name,
       publisher_name,
       authors
FROM book_cte

{% if is_incremental() %}
    WHERE sk_book NOT IN (
        SELECT sk_book
        FROM {{ this }}
    )
{% endif %}