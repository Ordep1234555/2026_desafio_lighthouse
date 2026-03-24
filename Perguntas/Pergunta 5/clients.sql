DROP TABLE IF EXISTS tmp_new_sales;

DROP TABLE IF EXISTS tmp_top_10_clients;

CREATE TEMP TABLE tmp_new_sales AS
SELECT
    s.id_sale,
    s.id_client,
    s.id_product,
    p.product_name,
    p.category,
    s.qtd,
    s.brl_total
FROM
    sales s
    LEFT JOIN products p ON s.id_product = p.id_product;

CREATE TEMP TABLE tmp_top_10_clients AS
SELECT
    id_client,
    SUM(brl_total) AS faturamento,
    COUNT(id_sale) AS frequencia,
    SUM(brl_total) / COUNT(id_sale) AS ticket_medio,
    COUNT(DISTINCT category) AS categorias_unicas
FROM
    tmp_new_sales
GROUP BY
    id_client
HAVING
    COUNT(DISTINCT category) >= 3
ORDER BY
    ticket_medio DESC,
    id_client ASC
LIMIT
    10;

SELECT
    *
FROM
    tmp_top_10_clients;

SELECT
    category,
    SUM(qtd) as qtd_total
FROM
    tmp_new_sales
WHERE
    id_client IN (
        SELECT
            id_client
        FROM
            tmp_top_10_clients
    )
GROUP BY
    category
ORDER BY
    qtd_total DESC
LIMIT
    1;